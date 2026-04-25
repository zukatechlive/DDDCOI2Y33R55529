import re
import tkinter as tk
from tkinter import filedialog, messagebox
import customtkinter as ctk

ctk.set_appearance_mode("dark")
ctk.set_default_color_theme("green")

# ─────────────────────────────────────────────
#  CONVERSION ENGINE
# ─────────────────────────────────────────────

def strip_luau_types(code: str) -> str:
    """Remove Luau type annotations to produce Lua 5.1."""
    lines = code.split("\n")
    out = []
    for line in lines:
        # Strip type alias declarations  (type Foo = Bar)
        if re.match(r"^\s*type\s+\w+\s*=\s*.+", line):
            out.append("-- [converted] " + line.strip())
            continue
        # Remove return type on function declarations:  ): ReturnType
        line = re.sub(r"\)\s*:\s*[\w\?\|\{\}\[\]<>, ]+(?=\s*$|\s*--)", ")", line)
        # Remove inline type annotations:  varname: Type  (in local declarations)
        # handles  local x: number = ...  and  local x: Type? = ...
        line = re.sub(r"(\blocal\s+\w+)\s*:\s*[\w\?\|\{\}\[\]<>, ]+(\s*=)", r"\1\2", line)
        # Remove param type annotations:  (a: number, b: string?)
        # We do this carefully inside function signatures
        line = re.sub(r"(\w+)\s*:\s*[\w\?\|\{\}\[\]<>, ]+(?=\s*[,\)])", r"\1", line)
        # Remove remaining standalone nullable markers from types already partially cleaned
        line = re.sub(r":\s*[\w\?\|\{\}\[\]<>]+\s*(?=[\),])", "", line)
        out.append(line)

    result = "\n".join(out)

    # Remove `::` type cast expressions  (value :: Type)
    result = re.sub(r"\s*::\s*[\w\?\|\{\}<>\[\] ,]+", "", result)

    # Replace //  (Luau floor division) with math.floor(a/b) - best effort single op
    result = re.sub(r"(\w+)\s*\/\/\s*(\w+)", r"math.floor(\1 / \2)", result)

    # Remove compound assignment operators (Luau only)
    result = re.sub(r"(\w+)\s*\+=\s*(.+)", r"\1 = \1 + \2", result)
    result = re.sub(r"(\w+)\s*-=\s*(.+)", r"\1 = \1 - \2", result)
    result = re.sub(r"(\w+)\s*\*=\s*(.+)", r"\1 = \1 * \2", result)
    result = re.sub(r"(\w+)\s*\/=\s*(.+)", r"\1 = \1 / \2", result)
    result = re.sub(r"(\w+)\s*\.\.=\s*(.+)", r"\1 = \1 .. \2", result)

    # Replace  string.format  with  tostring  where Luau uses `\`{expr}\``  (template literals)
    result = re.sub(r"`([^`]*)`", lambda m: '"' + m.group(1).replace("{", '" .. tostring(').replace("}", ') .. "') + '"', result)

    # Replace continue (not in Lua 5.1) with a goto pattern
    result = replace_continue(result)

    # Replace Luau's `if expr then` single-line ternary-style expressions (if/then/else as expr)
    result = re.sub(r"\bif\s+(.+?)\s+then\s+(.+?)\s+else\s+(.+?)(?=[\)\],;\n])", r"(\1 and \2 or \3)", result)

    return result


def replace_continue(code: str) -> str:
    """Replace continue statements with goto continue + label in each loop."""
    lines = code.split("\n")
    out = []
    loop_depth = 0
    for i, line in enumerate(lines):
        stripped = line.strip()
        # Detect loop starts
        if re.match(r"^\s*(for|while|repeat)\b", line):
            loop_depth += 1
        # Detect end (rough heuristic)
        if stripped == "end" and loop_depth > 0:
            out.append(line.replace("end", "    ::continue::\nend", 1) if any(
                "goto continue" in l for l in out[-20:]
            ) else line)
            loop_depth = max(0, loop_depth - 1)
            continue
        # Replace continue
        if stripped == "continue":
            indent = len(line) - len(line.lstrip())
            out.append(" " * indent + "goto continue")
            continue
        out.append(line)
    return "\n".join(out)


def add_luau_types(code: str) -> str:
    """Add basic Luau-style improvements to Lua 5.1 code."""
    lines = code.split("\n")
    out = []
    for line in lines:
        # math.floor(a / b)  →  a // b
        line = re.sub(r"math\.floor\(\s*(\w+)\s*\/\s*(\w+)\s*\)", r"\1 // \2", line)

        # Expand compound ops  x = x + y  →  x += y
        line = re.sub(r"(\w+)\s*=\s*\1\s*\+\s*(.+)", r"\1 += \2", line)
        line = re.sub(r"(\w+)\s*=\s*\1\s*-\s*(.+)", r"\1 -= \2", line)
        line = re.sub(r"(\w+)\s*=\s*\1\s*\*\s*(.+)", r"\1 *= \2", line)
        line = re.sub(r"(\w+)\s*=\s*\1\s*\/\s*(.+)", r"\1 /= \2", line)
        line = re.sub(r"(\w+)\s*=\s*\1\s*\.\.\s*(.+)", r"\1 ..= \2", line)

        # Infer simple local variable types from literals
        # local x = 0  →  local x: number = 0
        line = re.sub(
            r"^(\s*local\s+(\w+))\s*=\s*(\d+(?:\.\d+)?)(\s*(?:$|--))",
            r"\1: number = \3\4", line
        )
        # local x = ""  or  local x = ''  →  local x: string = ""
        line = re.sub(
            r'^(\s*local\s+(\w+))\s*=\s*(["\'])',
            r"\1: string = \3", line
        )
        # local x = true/false  →  local x: boolean = true/false
        line = re.sub(
            r"^(\s*local\s+(\w+))\s*=\s*(true|false)(\s*(?:$|--))",
            r"\1: boolean = \3\4", line
        )
        # local x = nil  →  local x: any? = nil
        line = re.sub(
            r"^(\s*local\s+(\w+))\s*=\s*nil(\s*(?:$|--))",
            r"\1: any? = nil\3", line
        )

        out.append(line)

    result = "\n".join(out)

    # goto continue  →  continue
    result = re.sub(r"\bgoto continue\b", "continue", result)
    # Remove ::continue:: labels
    result = re.sub(r"\s*::continue::\n?", "\n", result)

    return result


def convert(code: str, direction: str) -> str:
    if direction == "luau_to_51":
        return strip_luau_types(code)
    else:
        return add_luau_types(code)


# ─────────────────────────────────────────────
#  GUI
# ─────────────────────────────────────────────

class ConverterApp(ctk.CTk):
    def __init__(self):
        super().__init__()
        self.title("Lua Converter  //  5.1 ↔ Luau")
        self.geometry("1100x720")
        self.minsize(900, 600)
        self.configure(fg_color="#0f0f0f")

        self.direction = tk.StringVar(value="luau_to_51")

        self._build_header()
        self._build_toolbar()
        self._build_editors()
        self._build_footer()

    def _build_header(self):
        header = ctk.CTkFrame(self, fg_color="#111111", corner_radius=0, height=56)
        header.pack(fill="x", side="top")
        header.pack_propagate(False)

        ctk.CTkLabel(
            header,
            text="⬡  LUA CONVERTER",
            font=ctk.CTkFont(family="Courier New", size=18, weight="bold"),
            text_color="#00ff41",
        ).pack(side="left", padx=20, pady=14)

        ctk.CTkLabel(
            header,
            text="Lua 5.1  ↔  Luau",
            font=ctk.CTkFont(family="Courier New", size=12),
            text_color="#555555",
        ).pack(side="left", padx=0)

    def _build_toolbar(self):
        bar = ctk.CTkFrame(self, fg_color="#181818", corner_radius=0, height=52)
        bar.pack(fill="x")
        bar.pack_propagate(False)

        # Direction selector
        ctk.CTkLabel(bar, text="MODE:", font=ctk.CTkFont(family="Courier New", size=11),
                     text_color="#888888").pack(side="left", padx=(16, 6), pady=14)

        rb1 = ctk.CTkRadioButton(
            bar, text="Luau → Lua 5.1", variable=self.direction,
            value="luau_to_51", font=ctk.CTkFont(family="Courier New", size=12),
            fg_color="#00ff41", border_color="#00ff41", hover_color="#00cc33",
            command=self._update_labels
        )
        rb1.pack(side="left", padx=8)

        rb2 = ctk.CTkRadioButton(
            bar, text="Lua 5.1 → Luau", variable=self.direction,
            value="51_to_luau", font=ctk.CTkFont(family="Courier New", size=12),
            fg_color="#00ff41", border_color="#00ff41", hover_color="#00cc33",
            command=self._update_labels
        )
        rb2.pack(side="left", padx=8)

        # Buttons right side
        ctk.CTkButton(bar, text="⇄  CONVERT", width=130, height=34,
                      font=ctk.CTkFont(family="Courier New", size=13, weight="bold"),
                      fg_color="#00aa2b", hover_color="#00cc33", text_color="#000000",
                      command=self.run_convert).pack(side="right", padx=8, pady=9)

        ctk.CTkButton(bar, text="↑  LOAD FILE", width=110, height=34,
                      font=ctk.CTkFont(family="Courier New", size=12),
                      fg_color="#1e1e1e", hover_color="#2a2a2a", border_width=1,
                      border_color="#333333",
                      command=self.load_file).pack(side="right", padx=4)

        ctk.CTkButton(bar, text="↓  SAVE OUTPUT", width=130, height=34,
                      font=ctk.CTkFont(family="Courier New", size=12),
                      fg_color="#1e1e1e", hover_color="#2a2a2a", border_width=1,
                      border_color="#333333",
                      command=self.save_file).pack(side="right", padx=4)

        ctk.CTkButton(bar, text="✕  CLEAR", width=90, height=34,
                      font=ctk.CTkFont(family="Courier New", size=12),
                      fg_color="#1e1e1e", hover_color="#2a0000", border_width=1,
                      border_color="#333333", text_color="#ff4444",
                      command=self.clear_all).pack(side="right", padx=4)

    def _build_editors(self):
        pane = ctk.CTkFrame(self, fg_color="#0f0f0f", corner_radius=0)
        pane.pack(fill="both", expand=True, padx=0, pady=0)
        pane.columnconfigure(0, weight=1)
        pane.columnconfigure(2, weight=1)
        pane.rowconfigure(1, weight=1)

        # Labels
        self.lbl_in = ctk.CTkLabel(pane, text="INPUT  (Luau)",
                                   font=ctk.CTkFont(family="Courier New", size=11, weight="bold"),
                                   text_color="#00ff41", anchor="w")
        self.lbl_in.grid(row=0, column=0, sticky="w", padx=16, pady=(10, 2))

        self.lbl_out = ctk.CTkLabel(pane, text="OUTPUT  (Lua 5.1)",
                                    font=ctk.CTkFont(family="Courier New", size=11, weight="bold"),
                                    text_color="#888888", anchor="w")
        self.lbl_out.grid(row=0, column=2, sticky="w", padx=16, pady=(10, 2))

        # Divider
        div = ctk.CTkFrame(pane, fg_color="#222222", width=2, corner_radius=0)
        div.grid(row=0, column=1, rowspan=2, sticky="ns", padx=0, pady=8)

        # Input textbox
        self.input_box = tk.Text(
            pane,
            bg="#141414", fg="#d4d4d4", insertbackground="#00ff41",
            font=("Courier New", 12), relief="flat", bd=0,
            wrap="none", undo=True, padx=12, pady=10,
            selectbackground="#00441a", selectforeground="#ffffff"
        )
        self.input_box.grid(row=1, column=0, sticky="nsew", padx=(12, 6), pady=(0, 12))
        self._add_scrollbar(pane, self.input_box, row=1, col=0)

        # Output textbox
        self.output_box = tk.Text(
            pane,
            bg="#0d1a12", fg="#b8d4be", insertbackground="#00ff41",
            font=("Courier New", 12), relief="flat", bd=0,
            wrap="none", padx=12, pady=10,
            selectbackground="#00441a", selectforeground="#ffffff",
            state="normal"
        )
        self.output_box.grid(row=1, column=2, sticky="nsew", padx=(6, 12), pady=(0, 12))
        self._add_scrollbar(pane, self.output_box, row=1, col=2)

        # Line numbers look
        self.input_box.configure(tabs="4c")
        self.output_box.configure(tabs="4c")

    def _add_scrollbar(self, parent, text_widget, row, col):
        sb = tk.Scrollbar(parent, command=text_widget.yview, bg="#1a1a1a",
                          troughcolor="#111111", activebackground="#00ff41")
        sb.grid(row=row, column=col, sticky="nse", padx=(0, 0), pady=(0, 12))
        text_widget.configure(yscrollcommand=sb.set)

    def _build_footer(self):
        footer = ctk.CTkFrame(self, fg_color="#111111", corner_radius=0, height=32)
        footer.pack(fill="x", side="bottom")
        footer.pack_propagate(False)

        self.status_var = tk.StringVar(value="Ready.")
        ctk.CTkLabel(footer, textvariable=self.status_var,
                     font=ctk.CTkFont(family="Courier New", size=11),
                     text_color="#555555").pack(side="left", padx=16, pady=6)

        ctk.CTkLabel(footer,
                     text="Handles: type annotations · // · += -= *= /= ..= · continue · if-then-else exprs · string templates",
                     font=ctk.CTkFont(family="Courier New", size=10),
                     text_color="#333333").pack(side="right", padx=16)

    def _update_labels(self):
        d = self.direction.get()
        if d == "luau_to_51":
            self.lbl_in.configure(text="INPUT  (Luau)")
            self.lbl_out.configure(text="OUTPUT  (Lua 5.1)")
        else:
            self.lbl_in.configure(text="INPUT  (Lua 5.1)")
            self.lbl_out.configure(text="OUTPUT  (Luau)")

    def run_convert(self):
        src = self.input_box.get("1.0", "end-1c")
        if not src.strip():
            self.status_var.set("⚠  Nothing to convert.")
            return
        try:
            result = convert(src, self.direction.get())
            self.output_box.configure(state="normal")
            self.output_box.delete("1.0", "end")
            self.output_box.insert("1.0", result)
            lines_in = src.count("\n") + 1
            lines_out = result.count("\n") + 1
            self.status_var.set(f"✓  Converted  {lines_in} lines in → {lines_out} lines out")
        except Exception as e:
            messagebox.showerror("Conversion Error", str(e))
            self.status_var.set(f"✗  Error: {e}")

    def load_file(self):
        path = filedialog.askopenfilename(filetypes=[("Lua files", "*.lua"), ("All files", "*.*")])
        if path:
            with open(path, "r", encoding="utf-8") as f:
                content = f.read()
            self.input_box.delete("1.0", "end")
            self.input_box.insert("1.0", content)
            self.status_var.set(f"✓  Loaded: {path}")

    def save_file(self):
        content = self.output_box.get("1.0", "end-1c")
        if not content.strip():
            self.status_var.set("⚠  Output is empty.")
            return
        path = filedialog.asksaveasfilename(defaultextension=".lua",
                                            filetypes=[("Lua files", "*.lua"), ("All files", "*.*")])
        if path:
            with open(path, "w", encoding="utf-8") as f:
                f.write(content)
            self.status_var.set(f"✓  Saved: {path}")

    def clear_all(self):
        self.input_box.delete("1.0", "end")
        self.output_box.delete("1.0", "end")
        self.status_var.set("Cleared.")


if __name__ == "__main__":
    app = ConverterApp()
    app.mainloop()
