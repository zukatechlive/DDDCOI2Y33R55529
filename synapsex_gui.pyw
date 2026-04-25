import tkinter as tk
from tkinter import ttk, filedialog, messagebox
import os
import sys
import threading
import json
import time
import uuid
import base64
from pathlib import Path

# ─────────────────────────────────────────────────────────────────────────────
# Named Pipe Communication Module
# ─────────────────────────────────────────────────────────────────────────────

class NamedPipeClient:
    """Handles communication with the C++ DLL via Named Pipes.

    Protocol
    --------
    Every message is a JSON object terminated by a newline (\\n).

    Client → Server
        { "id": "<uuid4>", "type": "execute|attach|detach|inject|upload|ping|status",
          "data": <str|null>, "filename": <str|null>, "timestamp": <float> }

    Server → Client (normal response)
        { "id": "<uuid4>", "type": "<same>", "success": true|false,
          "message": "<text>", "data": <optional> }

    Server → Client (progress update)
        { "id": "<uuid4>", "type": "progress", "percent": 0-100, "message": "..." }
    """

    PIPE_NAME          = r'\\.\pipe\SynapseXPipe'
    BUFFER_SIZE        = 65536       # 64 KB – large enough for sizable Lua scripts
    RECONNECT_DELAY    = 3.0         # seconds between auto-reconnect tries
    HEARTBEAT_INTERVAL = 5.0         # seconds between ping messages

    def __init__(self, pipe_name: str = PIPE_NAME):
        self.pipe_name = pipe_name
        self.pipe      = None
        self.connected = False

        # Callbacks keyed by command id (uuid)  –  fire once then removed
        self._id_callbacks: dict   = {}
        self._lock = threading.Lock()

        self._listener_thread:  threading.Thread | None = None
        self._heartbeat_thread: threading.Thread | None = None
        self._running = False

        # Optional UI hook called on any connect/disconnect event
        self.on_connection_changed = None   # callable(bool) | None

    # ── public API ────────────────────────────────────────────────────────────

    def connect(self) -> bool:
        """Connect to the named pipe server (DLL). Returns True on success."""
        try:
            import win32file, win32pipe

            self.pipe = win32file.CreateFile(
                self.pipe_name,
                win32file.GENERIC_READ | win32file.GENERIC_WRITE,
                0, None,
                win32file.OPEN_EXISTING,
                0, None,
            )
            win32pipe.SetNamedPipeHandleState(
                self.pipe, win32pipe.PIPE_READMODE_MESSAGE, None, None,
            )
            self.connected = True
            self._running  = True
            self._start_background_threads()
            self._fire_connection_changed(True)
            return True

        except Exception as exc:
            print(f"[Pipe] Connection failed: {exc}")
            self.connected = False
            return False

    def disconnect(self):
        """Cleanly disconnect from the pipe."""
        self._running  = False
        self.connected = False
        if self.pipe is not None:
            try:
                import win32file
                win32file.CloseHandle(self.pipe)
            except Exception:
                pass
            self.pipe = None
        self._fire_connection_changed(False)

    def reconnect_loop(self):
        """Background: keep trying to connect until successful."""
        print("[Pipe] Starting reconnect loop…")
        while True:
            time.sleep(self.RECONNECT_DELAY)
            if self.connected:
                break
            print("[Pipe] Attempting reconnect…")
            if self.connect():
                print("[Pipe] Reconnected successfully.")
                break

    def send_command(
        self,
        command_type: str,
        data=None,
        *,
        callback=None,
        filename: str = None,
    ):
        """Send a command to the DLL.

        Parameters
        ----------
        command_type : str
            One of: execute, attach, detach, inject, upload, ping, status
        data : str | None
            Script text (execute) or base64 bytes (upload).
        callback : callable(dict) | None
            Invoked with the server response dict when it arrives.
        filename : str | None
            Required for upload commands.

        Returns
        -------
        str | None  –  command id on success, None on failure.
        """
        if not self.connected:
            print("[Pipe] Not connected to DLL.")
            return None

        cmd_id  = str(uuid.uuid4())
        message = {
            "id":        cmd_id,
            "type":      command_type,
            "data":      data,
            "filename":  filename,
            "timestamp": time.time(),
        }

        if callback is not None:
            with self._lock:
                self._id_callbacks[cmd_id] = callback

        try:
            import win32file
            raw = (json.dumps(message) + "\n").encode("utf-8")
            win32file.WriteFile(self.pipe, raw)
            return cmd_id
        except Exception as exc:
            print(f"[Pipe] Send failed: {exc}")
            self._on_broken_pipe()
            return None

    def send_file(self, filepath: str, callback=None):
        """Read a file, base64-encode it, and upload it to the DLL."""
        try:
            with open(filepath, "rb") as fh:
                encoded = base64.b64encode(fh.read()).decode("ascii")
            return self.send_command(
                "upload",
                data=encoded,
                filename=os.path.basename(filepath),
                callback=callback,
            )
        except Exception as exc:
            print(f"[Pipe] File read failed: {exc}")
            return None

    # ── private helpers ───────────────────────────────────────────────────────

    def _start_background_threads(self):
        self._listener_thread = threading.Thread(
            target=self._listen_for_responses, daemon=True, name="PipeListener"
        )
        self._listener_thread.start()

        self._heartbeat_thread = threading.Thread(
            target=self._heartbeat_loop, daemon=True, name="PipeHeartbeat"
        )
        self._heartbeat_thread.start()

    def _listen_for_responses(self):
        """Read newline-delimited JSON from the pipe (background thread)."""
        import win32file
        buf = ""
        while self._running and self.connected:
            try:
                _result, raw = win32file.ReadFile(self.pipe, self.BUFFER_SIZE)
                buf += raw.decode("utf-8")
                while "\n" in buf:
                    line, buf = buf.split("\n", 1)
                    line = line.strip()
                    if not line:
                        continue
                    try:
                        self._handle_response(json.loads(line))
                    except json.JSONDecodeError:
                        print(f"[Pipe] Invalid JSON: {line!r}")
            except Exception as exc:
                if self._running:
                    print(f"[Pipe] Listen error: {exc}")
                    self._on_broken_pipe()
                break

    def _heartbeat_loop(self):
        """Send periodic pings to detect dead connections."""
        while self._running:
            time.sleep(self.HEARTBEAT_INTERVAL)
            if not self.connected:
                break
            self.send_command("ping")

    def _handle_response(self, response: dict):
        cmd_id    = response.get("id")
        resp_type = response.get("type")

        # Progress updates call the callback but don't consume it
        if resp_type == "progress":
            with self._lock:
                cb = self._id_callbacks.get(cmd_id)
            if cb:
                try:
                    cb(response)
                except Exception as exc:
                    print(f"[Pipe] Progress callback error: {exc}")
            return

        with self._lock:
            cb = self._id_callbacks.pop(cmd_id, None)

        if cb:
            try:
                cb(response)
            except Exception as exc:
                print(f"[Pipe] Callback error: {exc}")
        elif resp_type not in ("ping", "pong"):
            print(f"[Pipe] Unhandled response: {response}")

    def _on_broken_pipe(self):
        was = self.connected
        self.connected = False
        self.pipe      = None
        if was:
            self._fire_connection_changed(False)
            threading.Thread(target=self.reconnect_loop, daemon=True).start()

    def _fire_connection_changed(self, state: bool):
        if self.on_connection_changed is not None:
            try:
                self.on_connection_changed(state)
            except Exception as exc:
                print(f"[Pipe] on_connection_changed error: {exc}")


# ─────────────────────────────────────────────────────────────────────────────
# Animation helper
# ─────────────────────────────────────────────────────────────────────────────

class AnimationHelper:
    @staticmethod
    def fade_in(widget, duration=300, steps=20):
        current   = 0.0
        increment = 1.0 / steps
        delay     = max(1, duration // steps)
        def _step():
            nonlocal current
            current = min(current + increment, 1.0)
            try:
                widget.attributes("-alpha", current)
            except tk.TclError:
                pass
            if current < 1.0:
                widget.after(delay, _step)
        _step()

    @staticmethod
    def fade_out(widget, duration=300, steps=20, callback=None):
        current   = 1.0
        decrement = 1.0 / steps
        delay     = max(1, duration // steps)
        def _step():
            nonlocal current
            current = max(current - decrement, 0.0)
            try:
                widget.attributes("-alpha", current)
            except tk.TclError:
                pass
            if current > 0.0:
                widget.after(delay, _step)
            elif callback:
                callback()
        _step()


# ─────────────────────────────────────────────────────────────────────────────
# Monaco-style Lua editor widget
# ─────────────────────────────────────────────────────────────────────────────

class MonacoEditor(tk.Frame):
    LUA_KEYWORDS = [
        "local", "function", "end", "if", "then", "else", "elseif",
        "for", "while", "do", "return", "break", "and", "or", "not",
        "true", "false", "nil", "in", "repeat", "until",
    ]
    LUA_BUILTINS = [
        "print", "pairs", "ipairs", "next", "type", "tostring", "tonumber",
        "pcall", "xpcall", "error", "assert", "require", "loadstring",
        "rawget", "rawset", "select", "unpack", "setmetatable", "getmetatable",
        "math", "string", "table", "os", "io",
    ]

    def __init__(self, parent, **kwargs):
        super().__init__(parent, **kwargs)
        self.configure(bg="#262626")
        self._debounce_id = None
        self._setup_editor()

    def _setup_editor(self):
        # Line-number panel
        ln_frame = tk.Frame(self, bg="#1a1a1a", width=50)
        ln_frame.pack(side=tk.LEFT, fill=tk.Y)

        self.line_numbers = tk.Text(
            ln_frame, width=4, bg="#1a1a1a", fg="#7A7A7A",
            font=("JetBrains Mono", 13), bd=0, state=tk.DISABLED,
            cursor="arrow", selectbackground="#1a1a1a", highlightthickness=0,
        )
        self.line_numbers.pack(fill=tk.BOTH, expand=True, padx=(10, 5), pady=(24, 0))

        # Code area
        code_frame = tk.Frame(self, bg="#262626")
        code_frame.pack(side=tk.LEFT, fill=tk.BOTH, expand=True)

        vscroll = tk.Scrollbar(code_frame, bg="#1a1a1a", troughcolor="#262626")
        vscroll.pack(side=tk.RIGHT, fill=tk.Y)

        hscroll = tk.Scrollbar(
            code_frame, orient=tk.HORIZONTAL, bg="#1a1a1a", troughcolor="#262626"
        )
        hscroll.pack(side=tk.BOTTOM, fill=tk.X)

        self.editor = tk.Text(
            code_frame,
            bg="#262626", fg="#C3CCDB", insertbackground="#7AA2F7",
            font=("JetBrains Mono", 11), bd=0, wrap=tk.NONE,
            undo=True, maxundo=-1, selectbackground="#404040",
            insertwidth=3, highlightthickness=0,
            yscrollcommand=vscroll.set, xscrollcommand=hscroll.set,
            tabs=("4c",),
        )
        self.editor.pack(fill=tk.BOTH, expand=True, pady=(24, 0), padx=(10, 5))

        vscroll.config(command=self._on_vscroll)
        hscroll.config(command=self.editor.xview)

        self._configure_tags()
        self.editor.insert("1.0", '-- Ready to execute via Named Pipe\nprint("Hello from Synapse X!")')

        self.editor.bind("<KeyRelease>",    self._on_text_change)
        self.editor.bind("<MouseWheel>",    self._on_wheel)
        self.editor.bind("<Button-4>",      self._on_wheel)
        self.editor.bind("<Button-5>",      self._on_wheel)
        self.editor.bind("<Tab>",           self._on_tab)
        self.editor.bind("<Control-z>",     lambda e: self.editor.edit_undo())
        self.editor.bind("<Control-y>",     lambda e: self.editor.edit_redo())

        self._refresh_line_numbers()
        self._highlight()

    # ── tag / highlighting ────────────────────────────────────────────────────

    def _configure_tags(self):
        self.editor.tag_config("keyword", foreground="#BB9AF7",
                               font=("JetBrains Mono", 11, "bold"))
        self.editor.tag_config("builtin", foreground="#0DB9D7")
        self.editor.tag_config("string",  foreground="#9ECE6A")
        self.editor.tag_config("comment", foreground="#666666",
                               font=("JetBrains Mono", 11, "italic"))
        self.editor.tag_config("number",  foreground="#FF9E64")

    def _highlight(self):
        import re
        for tag in ("keyword", "builtin", "string", "comment", "number"):
            self.editor.tag_remove(tag, "1.0", tk.END)

        content = self.editor.get("1.0", tk.END)
        for li, line in enumerate(content.split("\n"), start=1):
            # Comments
            dash = line.find("--")
            if dash != -1:
                self.editor.tag_add("comment", f"{li}.{dash}", f"{li}.{len(line)}")
                line = line[:dash]

            # Strings
            for q in ('"', "'"):
                i = 0
                while True:
                    s = line.find(q, i)
                    if s == -1:
                        break
                    e = line.find(q, s + 1)
                    if e == -1:
                        break
                    self.editor.tag_add("string", f"{li}.{s}", f"{li}.{e + 1}")
                    i = e + 1

            # Numbers
            for m in re.finditer(r"\b\d+\.?\d*\b", line):
                self.editor.tag_add("number", f"{li}.{m.start()}", f"{li}.{m.end()}")

            # Keywords + builtins
            for group, words in (("keyword", self.LUA_KEYWORDS), ("builtin", self.LUA_BUILTINS)):
                for word in words:
                    i = 0
                    while True:
                        pos = line.find(word, i)
                        if pos == -1:
                            break
                        bef = line[pos - 1] if pos > 0 else " "
                        aft = line[pos + len(word)] if pos + len(word) < len(line) else " "
                        if not (bef.isalnum() or bef == "_") and \
                           not (aft.isalnum() or aft == "_"):
                            self.editor.tag_add(group, f"{li}.{pos}", f"{li}.{pos + len(word)}")
                        i = pos + 1

    # ── event handlers ────────────────────────────────────────────────────────

    def _on_vscroll(self, *args):
        self.editor.yview(*args)
        self.line_numbers.yview_moveto(self.editor.yview()[0])

    def _on_wheel(self, event):
        delta = -1 if event.num == 4 else (1 if event.num == 5 else -int(event.delta / 120))
        self.editor.yview_scroll(delta, "units")
        self.line_numbers.yview_moveto(self.editor.yview()[0])
        return "break"

    def _on_tab(self, _event):
        self.editor.insert(tk.INSERT, "    ")
        return "break"

    def _on_text_change(self, _event=None):
        self._refresh_line_numbers()
        if self._debounce_id:
            self.after_cancel(self._debounce_id)
        self._debounce_id = self.after(80, self._highlight)

    def _refresh_line_numbers(self):
        lc   = int(self.editor.index("end-1c").split(".")[0])
        text = "\n".join(str(i) for i in range(1, lc + 1))
        self.line_numbers.config(state=tk.NORMAL)
        self.line_numbers.delete("1.0", tk.END)
        self.line_numbers.insert("1.0", text)
        self.line_numbers.config(state=tk.DISABLED)
        self.line_numbers.yview_moveto(self.editor.yview()[0])

    # ── public interface ──────────────────────────────────────────────────────

    def get_text(self) -> str:
        return self.editor.get("1.0", "end-1c")

    def set_text(self, text: str):
        self.editor.delete("1.0", tk.END)
        self.editor.insert("1.0", text)
        self._refresh_line_numbers()
        self._highlight()

    def clear(self):
        self.set_text("")


# ─────────────────────────────────────────────────────────────────────────────
# Main application
# ─────────────────────────────────────────────────────────────────────────────

class SynapseXUI:
    C = {   # colour palette
        "bg_main":       "#1a1a1a",
        "bg_mid":        "#262626",
        "bg_btn":        "#2a2a2a",
        "text_main":     "#D5D5D5",
        "text_dim":      "#7A7A7A",
        "accent_purple": "#BB9AF7",
        "accent_blue":   "#7AA2F7",
        "stroke_inner":  "#333333",
        "stroke_btn":    "#404040",
        "green":         "#4CAF50",
        "red":           "#F44336",
    }

    def __init__(self, root: tk.Tk):
        self.root          = root
        self.animator      = AnimationHelper()
        self.is_minimized  = False
        self.is_attached   = False

        self.pipe_client   = NamedPipeClient()
        self.pipe_client.on_connection_changed = self._on_connection_changed

        self._setup_window()
        self._create_ui()
        self._bind_keys()
        self.root.after(500, self._auto_connect)

    # ── window ────────────────────────────────────────────────────────────────

    def _setup_window(self):
        self.root.title("Synapse X – Pipe Bridge")
        self.root.geometry("820x570")
        self.root.configure(bg=self.C["bg_main"])
        self.root.overrideredirect(True)
        self.root.attributes("-alpha", 0.0)
        self.root.after(100, lambda: self.animator.fade_in(self.root))

    # ── UI ────────────────────────────────────────────────────────────────────

    def _create_ui(self):
        self.main_frame = tk.Frame(
            self.root, bg=self.C["bg_main"],
            highlightbackground=self.C["accent_purple"], highlightthickness=2,
        )
        self.main_frame.pack(fill=tk.BOTH, expand=True)
        self._create_title_bar()
        self._create_editor()
        self._create_status_bar()
        self._create_toolbar()

    def _create_title_bar(self):
        bar = tk.Frame(
            self.main_frame, bg=self.C["bg_mid"], height=32,
            highlightbackground=self.C["stroke_inner"], highlightthickness=1,
        )
        bar.pack(fill=tk.X)
        bar.pack_propagate(False)
        self.title_bar = bar

        tk.Label(bar, text="⚡ Synapse X – Pipe Bridge",
                 bg=self.C["bg_mid"], fg=self.C["accent_purple"],
                 font=("Segoe UI", 10, "bold")).pack(side=tk.LEFT, padx=10)

        self.conn_label = tk.Label(
            bar, text="● Disconnected",
            bg=self.C["bg_mid"], fg=self.C["red"], font=("Segoe UI", 8),
        )
        self.conn_label.pack(side=tk.LEFT, padx=5)

        for symbol, cmd in [("✕", self._close), ("─", self._toggle_minimize)]:
            tk.Button(bar, text=symbol, bg=self.C["bg_mid"], fg=self.C["text_main"],
                      font=("Segoe UI", 12), bd=0, cursor="hand2",
                      command=cmd).pack(side=tk.RIGHT, padx=5)

        self._enable_drag()

    def _create_editor(self):
        self.editor = MonacoEditor(self.main_frame)
        self.editor.pack(fill=tk.BOTH, expand=True, padx=1)

    def _create_toolbar(self):
        bar = tk.Frame(
            self.main_frame, bg=self.C["bg_mid"], height=44,
            highlightbackground=self.C["stroke_inner"], highlightthickness=1,
        )
        bar.pack(fill=tk.X, side=tk.BOTTOM)
        bar.pack_propagate(False)

        cfg = [
            # label,          handler,              accent,                  primary
            ("Execute",       self._execute,        self.C["accent_purple"], True),
            ("Clear",         self._clear,          self.C["stroke_btn"],    False),
            ("Open File",     self._open_file,      self.C["stroke_btn"],    False),
            ("Save File",     self._save_file,      self.C["stroke_btn"],    False),
            ("Upload File",   self._upload_file,    self.C["stroke_btn"],    False),
            ("Connect DLL",   self._connect,        self.C["accent_blue"],   False),
            ("Attach",        self._attach,         self.C["stroke_btn"],    False),
            ("Status",        self._req_status,     self.C["stroke_btn"],    False),
        ]
        self.buttons: dict = {}
        x = 10
        for label, cmd, accent, primary in cfg:
            btn = tk.Button(
                bar, text=label, bg=self.C["bg_btn"], fg=self.C["text_main"],
                font=("Segoe UI", 9), bd=0, cursor="hand2", command=cmd,
                relief=tk.FLAT,
                highlightbackground=accent, highlightthickness=1 if primary else 0,
            )
            btn.place(x=x, y=10, width=92, height=24)
            self.buttons[label] = btn
            x += 97

    def _create_status_bar(self):
        self.status_bar = tk.Label(
            self.main_frame, text="Ready",
            bg=self.C["bg_main"], fg=self.C["text_dim"],
            font=("Segoe UI", 8), anchor="w",
        )
        self.status_bar.pack(fill=tk.X, side=tk.BOTTOM, padx=5, pady=2)

    def _enable_drag(self):
        self._drag = {"x": 0, "y": 0}
        def start(e):
            self._drag["x"], self._drag["y"] = e.x, e.y
        def move(e):
            x = self.root.winfo_x() + (e.x - self._drag["x"])
            y = self.root.winfo_y() + (e.y - self._drag["y"])
            self.root.geometry(f"+{x}+{y}")
        self.title_bar.bind("<Button-1>",  start)
        self.title_bar.bind("<B1-Motion>", move)

    def _bind_keys(self):
        self.root.bind("<Control-o>",      lambda _: self._open_file())
        self.root.bind("<Control-s>",      lambda _: self._save_file())
        self.root.bind("<Control-Return>", lambda _: self._execute())
        self.root.bind("<F5>",             lambda _: self._execute())

    # ── status helpers ────────────────────────────────────────────────────────

    def _set_status(self, msg: str, color: str = None):
        self.status_bar.config(text=msg)
        if color:
            self.status_bar.config(fg=color)

    def _set_conn_label(self, connected: bool):
        if connected:
            self.conn_label.config(text="● Connected",    fg=self.C["green"])
        else:
            self.conn_label.config(text="● Disconnected", fg=self.C["red"])

    def _on_connection_changed(self, state: bool):
        """Called from a background thread – reschedule on main thread."""
        self.root.after(0, self._set_conn_label, state)
        if state:
            self.root.after(0, self._set_status, "Connected to DLL", self.C["green"])
        else:
            self.root.after(0, self._set_status,
                            "Disconnected – auto-reconnecting…", self.C["red"])

    # ── pipe actions ──────────────────────────────────────────────────────────

    def _auto_connect(self):
        if self.pipe_client.connect():
            self._set_conn_label(True)
            self._set_status("Connected to DLL", self.C["green"])
        else:
            self._set_status("DLL not found – click 'Connect DLL' to retry", self.C["red"])

    def _connect(self):
        if self.pipe_client.connected:
            messagebox.showinfo("Info", "Already connected to DLL.")
            return
        if self.pipe_client.connect():
            self._set_conn_label(True)
            self._set_status("Connected to DLL", self.C["green"])
            messagebox.showinfo("Success", "Connected to Synapse X DLL!")
        else:
            messagebox.showerror(
                "Error",
                "Failed to connect to DLL.\n\n"
                "Make sure:\n"
                "1. The DLL is injected and running\n"
                "2. The named pipe server is active\n"
                "3. You have proper permissions",
            )

    def _execute(self):
        code = self.editor.get_text().strip()
        if not code:
            self._set_status("No code to execute", self.C["red"])
            return
        if not self.pipe_client.connected:
            messagebox.showerror("Error", "Not connected to DLL!\nClick 'Connect DLL' first.")
            return

        def on_response(resp: dict):
            if resp.get("type") == "progress":
                pct = resp.get("percent", "?")
                self.root.after(0, self._set_status,
                                f"⟳ Executing… {pct}%", self.C["accent_blue"])
                return
            ok   = resp.get("success", False)
            msg  = resp.get("message", "Unknown response")
            col  = self.C["green"] if ok else self.C["red"]
            icon = "✓" if ok else "✗"
            self.root.after(0, self._set_status, f"{icon} {msg}", col)

        cmd_id = self.pipe_client.send_command("execute", code, callback=on_response)
        if cmd_id:
            self._set_status("Sending script to DLL…", self.C["accent_blue"])
            btn = self.buttons["Execute"]
            orig = btn.cget("bg")
            btn.config(bg=self.C["accent_blue"])
            self.root.after(150, lambda: btn.config(bg=orig))
        else:
            self._set_status("Failed to send command", self.C["red"])

    def _attach(self):
        if not self.pipe_client.connected:
            messagebox.showerror("Error", "Not connected to DLL!")
            return

        if not self.is_attached:
            def on_attach(resp: dict):
                ok = resp.get("success", False)
                self.is_attached = ok
                if ok:
                    self.root.after(0, self.buttons["Attach"].config,
                                    {"highlightbackground": self.C["green"], "highlightthickness": 2})
                    self.root.after(0, self._set_status, "✓ Attached to process", self.C["green"])
                else:
                    msg = resp.get("message", "")
                    self.root.after(0, self._set_status, f"✗ Attach failed: {msg}", self.C["red"])

            self.pipe_client.send_command("attach", callback=on_attach)
            self._set_status("Attaching to process…", self.C["accent_blue"])
        else:
            def on_detach(resp: dict):
                self.is_attached = False
                self.root.after(0, self.buttons["Attach"].config, {"highlightthickness": 0})
                self.root.after(0, self._set_status, "Detached from process", self.C["text_dim"])

            self.pipe_client.send_command("detach", callback=on_detach)
            self._set_status("Detaching…", self.C["accent_blue"])

    def _req_status(self):
        if not self.pipe_client.connected:
            messagebox.showerror("Error", "Not connected to DLL!")
            return

        def on_status(resp: dict):
            data = resp.get("data") or resp.get("message", "No data returned.")
            self.root.after(0, messagebox.showinfo, "DLL Status", str(data))

        self.pipe_client.send_command("status", callback=on_status)
        self._set_status("Requesting status…", self.C["accent_blue"])

    def _upload_file(self):
        if not self.pipe_client.connected:
            messagebox.showerror("Error", "Not connected to DLL!")
            return
        fp = filedialog.askopenfilename(
            title="Upload File to DLL",
            filetypes=[("Lua files", "*.lua"), ("All files", "*.*")],
        )
        if not fp:
            return

        def on_upload(resp: dict):
            ok   = resp.get("success", False)
            msg  = resp.get("message", "")
            col  = self.C["green"] if ok else self.C["red"]
            icon = "✓" if ok else "✗"
            self.root.after(0, self._set_status, f"{icon} Upload: {msg}", col)

        if self.pipe_client.send_file(fp, callback=on_upload):
            self._set_status(f"Uploading {Path(fp).name}…", self.C["accent_blue"])
        else:
            self._set_status("Upload failed", self.C["red"])

    # ── editor helpers ────────────────────────────────────────────────────────

    def _clear(self):
        self.editor.clear()
        self._set_status("Editor cleared", self.C["text_dim"])

    def _open_file(self):
        fp = filedialog.askopenfilename(
            title="Open Script",
            filetypes=[("Lua files", "*.lua"), ("Text files", "*.txt"), ("All files", "*.*")],
        )
        if not fp:
            return
        try:
            with open(fp, "r", encoding="utf-8") as fh:
                self.editor.set_text(fh.read())
            self._set_status(f"Opened: {Path(fp).name}", self.C["green"])
        except Exception as exc:
            messagebox.showerror("Error", f"Failed to open file:\n{exc}")

    def _save_file(self):
        fp = filedialog.asksaveasfilename(
            title="Save Script",
            defaultextension=".lua",
            filetypes=[("Lua files", "*.lua"), ("Text files", "*.txt"), ("All files", "*.*")],
        )
        if not fp:
            return
        try:
            with open(fp, "w", encoding="utf-8") as fh:
                fh.write(self.editor.get_text())
            self._set_status(f"Saved: {Path(fp).name}", self.C["green"])
        except Exception as exc:
            messagebox.showerror("Error", f"Failed to save file:\n{exc}")

    # ── window controls ───────────────────────────────────────────────────────

    def _toggle_minimize(self):
        if not self.is_minimized:
            self.editor.pack_forget()
            self.root.geometry("820x32")
            self.is_minimized = True
        else:
            self.editor.pack(fill=tk.BOTH, expand=True, padx=1)
            self.root.geometry("820x570")
            self.is_minimized = False

    def _close(self):
        def destroy():
            self.pipe_client.disconnect()
            self.root.destroy()
        self.animator.fade_out(self.root, duration=200, callback=destroy)


# ─────────────────────────────────────────────────────────────────────────────
# Entry point
# ─────────────────────────────────────────────────────────────────────────────

def main():
    try:
        import win32file  # noqa: F401
        import win32pipe  # noqa: F401
    except ImportError:
        print("ERROR: pywin32 is required.")
        print("Install:  pip install pywin32")
        sys.exit(1)

    root = tk.Tk()
    app  = SynapseXUI(root)  # noqa: F841
    root.update_idletasks()
    w, h = root.winfo_width(), root.winfo_height()
    x = (root.winfo_screenwidth()  // 2) - (w // 2)
    y = (root.winfo_screenheight() // 2) - (h // 2)
    root.geometry(f"{w}x{h}+{x}+{y}")
    root.mainloop()


if __name__ == "__main__":
    main()
