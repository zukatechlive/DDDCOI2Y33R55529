import tkinter as tk
from tkinter import ttk, filedialog, messagebox
import os
import sys
import threading
import json
import time
from pathlib import Path

# Named Pipe Communication Module
class NamedPipeClient:
    """Handles communication with the C++ DLL via Named Pipes"""
    
    def __init__(self, pipe_name=r'\\.\pipe\SynapseXPipe'):
        self.pipe_name = pipe_name
        self.pipe = None
        self.connected = False
        self.response_callbacks = {}
        self.listener_thread = None
        self.running = False
        
    def connect(self):
        """Connect to the named pipe server (DLL)"""
        try:
            import win32file
            import win32pipe
            import pywintypes
            
            # Try to connect to the pipe
            self.pipe = win32file.CreateFile(
                self.pipe_name,
                win32file.GENERIC_READ | win32file.GENERIC_WRITE,
                0,
                None,
                win32file.OPEN_EXISTING,
                0,
                None
            )
            
            # Set pipe to message mode
            win32pipe.SetNamedPipeHandleState(
                self.pipe,
                win32pipe.PIPE_READMODE_MESSAGE,
                None,
                None
            )
            
            self.connected = True
            self.running = True
            
            # Start listener thread
            self.listener_thread = threading.Thread(target=self._listen_for_responses, daemon=True)
            self.listener_thread.start()
            
            return True
            
        except Exception as e:
            print(f"[Pipe] Connection failed: {e}")
            self.connected = False
            return False
    
    def disconnect(self):
        """Disconnect from the pipe"""
        self.running = False
        if self.pipe:
            try:
                import win32file
                win32file.CloseHandle(self.pipe)
            except:
                pass
        self.connected = False
        self.pipe = None
    
    def send_command(self, command_type, data=None, callback=None):
        """Send a command to the DLL
        
        Args:
            command_type: Type of command ('execute', 'attach', 'inject', etc.)
            data: Command data (e.g., Lua script code)
            callback: Optional callback for response
        """
        if not self.connected:
            print("[Pipe] Not connected to DLL")
            return False
        
        try:
            import win32file
            
            # Create JSON message
            message = {
                'type': command_type,
                'data': data,
                'timestamp': time.time()
            }
            
            message_bytes = (json.dumps(message) + '\n').encode('utf-8')
            
            # Write to pipe
            win32file.WriteFile(self.pipe, message_bytes)
            
            # Register callback if provided
            if callback:
                self.response_callbacks[command_type] = callback
            
            return True
            
        except Exception as e:
            print(f"[Pipe] Send failed: {e}")
            self.connected = False
            return False
    
    def _listen_for_responses(self):
        """Listen for responses from the DLL (runs in background thread)"""
        import win32file
        
        buffer_size = 4096
        
        while self.running and self.connected:
            try:
                # Read from pipe
                result, data = win32file.ReadFile(self.pipe, buffer_size)
                
                if data:
                    message_str = data.decode('utf-8').strip()
                    
                    # Parse JSON response
                    try:
                        response = json.loads(message_str)
                        self._handle_response(response)
                    except json.JSONDecodeError:
                        print(f"[Pipe] Invalid JSON received: {message_str}")
                
            except Exception as e:
                if self.running:
                    print(f"[Pipe] Listen error: {e}")
                    self.connected = False
                break
    
    def _handle_response(self, response):
        """Handle response from DLL"""
        response_type = response.get('type')
        
        # Call registered callback if exists
        if response_type in self.response_callbacks:
            callback = self.response_callbacks[response_type]
            callback(response)
            # Remove one-time callback
            del self.response_callbacks[response_type]
        else:
            # Default handling
            print(f"[Pipe] Response: {response}")


class AnimationHelper:
    """Animation helper class"""
    
    @staticmethod
    def fade_in(widget, duration=300, steps=20):
        current = 0.0
        increment = 1.0 / steps
        delay = duration // steps
        
        def animate():
            nonlocal current
            if current < 1.0:
                current += increment
                try:
                    widget.attributes('-alpha', min(current, 1.0))
                except:
                    pass
                widget.after(delay, animate)
        
        animate()
    
    @staticmethod
    def fade_out(widget, duration=300, steps=20, callback=None):
        current = 1.0
        decrement = 1.0 / steps
        delay = duration // steps
        
        def animate():
            nonlocal current
            if current > 0.0:
                current -= decrement
                try:
                    widget.attributes('-alpha', max(current, 0.0))
                except:
                    pass
                widget.after(delay, animate)
            elif callback:
                callback()
        
        animate()


class MonacoEditor(tk.Frame):
    """Monaco-style editor"""
    
    def __init__(self, parent, **kwargs):
        super().__init__(parent, **kwargs)
        self.config(bg='#262626')
        self.setup_editor()
        
    def setup_editor(self):
        # Line numbers
        self.line_frame = tk.Frame(self, bg='#1a1a1a', width=50)
        self.line_frame.pack(side=tk.LEFT, fill=tk.Y)
        
        self.line_numbers = tk.Text(
            self.line_frame,
            width=4,
            bg='#1a1a1a',
            fg='#7A7A7A',
            font=('JetBrains Mono', 13),
            bd=0,
            state=tk.DISABLED,
            cursor='arrow',
            selectbackground='#1a1a1a',
            highlightthickness=0
        )
        self.line_numbers.pack(fill=tk.BOTH, expand=True, padx=(10, 5), pady=(24, 0))
        
        # Editor
        editor_frame = tk.Frame(self, bg='#262626')
        editor_frame.pack(side=tk.LEFT, fill=tk.BOTH, expand=True)
        
        scrollbar = tk.Scrollbar(editor_frame, bg='#1a1a1a', troughcolor='#262626')
        scrollbar.pack(side=tk.RIGHT, fill=tk.Y)
        
        self.editor = tk.Text(
            editor_frame,
            bg='#262626',
            fg='#C3CCDB',
            insertbackground='#7AA2F7',
            font=('JetBrains Mono', 11),
            bd=0,
            wrap=tk.NONE,
            undo=True,
            selectbackground='#404040',
            insertwidth=3,
            highlightthickness=0,
            yscrollcommand=scrollbar.set
        )
        self.editor.pack(fill=tk.BOTH, expand=True, pady=(24, 0), padx=(10, 5))
        scrollbar.config(command=self.editor.yview)
        
        # Configure syntax
        self.configure_syntax_tags()
        self.editor.insert('1.0', '-- Ready to execute via Named Pipe\nprint("Hello from Synapse X!")')
        
        # Bindings
        self.editor.bind('<KeyRelease>', self.on_text_change)
        self.editor.bind('<MouseWheel>', self.sync_scroll)
        
        self.update_line_numbers()
        self.apply_syntax_highlighting()
    
    def configure_syntax_tags(self):
        self.editor.tag_config('keyword', foreground='#BB9AF7', font=('JetBrains Mono', 10, 'bold'))
        self.editor.tag_config('string', foreground='#9ECE6A')
        self.editor.tag_config('comment', foreground='#666666', font=('JetBrains Mono', 10, 'italic'))
        self.editor.tag_config('number', foreground='#FF9E64')
        self.editor.tag_config('builtin', foreground='#0DB9D7')
    
    def sync_scroll(self, event):
        self.line_numbers.yview_moveto(self.editor.yview()[0])
        return "break"
    
    def on_text_change(self, event=None):
        self.update_line_numbers()
        self.apply_syntax_highlighting()
    
    def update_line_numbers(self):
        line_count = int(self.editor.index('end-1c').split('.')[0])
        line_numbers_text = '\n'.join(str(i) for i in range(1, line_count + 1))
        
        self.line_numbers.config(state=tk.NORMAL)
        self.line_numbers.delete('1.0', tk.END)
        self.line_numbers.insert('1.0', line_numbers_text)
        self.line_numbers.config(state=tk.DISABLED)
    
    def apply_syntax_highlighting(self):
        content = self.editor.get('1.0', tk.END)
        
        for tag in ['keyword', 'string', 'comment', 'number', 'builtin']:
            self.editor.tag_remove(tag, '1.0', tk.END)
        
        keywords = ['local', 'function', 'end', 'if', 'then', 'else', 'for', 'while', 
                   'do', 'return', 'break', 'and', 'or', 'not']
        for keyword in keywords:
            start = '1.0'
            while True:
                pos = self.editor.search(r'\m' + keyword + r'\M', start, tk.END, regexp=True)
                if not pos:
                    break
                end = f"{pos}+{len(keyword)}c"
                self.editor.tag_add('keyword', pos, end)
                start = end
    
    def get_text(self):
        return self.editor.get('1.0', 'end-1c')
    
    def set_text(self, text):
        self.editor.delete('1.0', tk.END)
        self.editor.insert('1.0', text)
        self.update_line_numbers()
        self.apply_syntax_highlighting()
    
    def clear(self):
        self.set_text('')


class SynapseXUI:
    """Main Synapse X UI with Named Pipe integration"""
    
    def __init__(self, root):
        self.root = root
        self.animator = AnimationHelper()
        self.is_minimized = False
        self.is_attached = False
        
        # Initialize Named Pipe Client
        self.pipe_client = NamedPipeClient()
        
        # Color scheme
        self.colors = {
            'bg_main': '#1a1a1a',
            'bg_mid': '#262626',
            'bg_btn': '#2a2a2a',
            'bg_btn_hov': '#353535',
            'text_main': '#D5D5D5',
            'text_dim': '#7A7A7A',
            'accent_purple': '#BB9AF7',
            'accent_blue': '#7AA2F7',
            'stroke_inner': '#333333',
            'stroke_btn': '#404040',
            'attach_on': '#4CAF50',
            'attach_off': '#F44336'
        }
        
        self.setup_window()
        self.create_ui()
        self.bind_events()
        
        # Try to connect to DLL on startup
        self.root.after(500, self.auto_connect)
    
    def setup_window(self):
        self.root.title("Synapse X - Enhanced")
        self.root.geometry("820x550")
        self.root.configure(bg=self.colors['bg_main'])
        self.root.overrideredirect(True)
        self.root.attributes('-alpha', 0.0)
        
        # Fade in
        self.root.after(100, lambda: self.animator.fade_in(self.root))
    
    def create_ui(self):
        # Main frame
        self.main_frame = tk.Frame(
            self.root,
            bg=self.colors['bg_main'],
            highlightbackground=self.colors['accent_purple'],
            highlightthickness=2
        )
        self.main_frame.pack(fill=tk.BOTH, expand=True)
        
        self.create_title_bar()
        self.create_editor()
        self.create_toolbar()
        self.create_status_bar()
    
    def create_title_bar(self):
        self.title_bar = tk.Frame(
            self.main_frame,
            bg=self.colors['bg_mid'],
            height=32,
            highlightbackground=self.colors['stroke_inner'],
            highlightthickness=1
        )
        self.title_bar.pack(fill=tk.X)
        self.title_bar.pack_propagate(False)
        
        # Title
        title = tk.Label(
            self.title_bar,
            text="⚡ Synapse X - Pipe Bridge",
            bg=self.colors['bg_mid'],
            fg=self.colors['accent_purple'],
            font=('Segoe UI', 10, 'bold')
        )
        title.pack(side=tk.LEFT, padx=10)
        
        # Connection status indicator
        self.status_indicator = tk.Label(
            self.title_bar,
            text="● Disconnected",
            bg=self.colors['bg_mid'],
            fg=self.colors['attach_off'],
            font=('Segoe UI', 8)
        )
        self.status_indicator.pack(side=tk.LEFT, padx=5)
        
        # Window controls
        close_btn = tk.Button(
            self.title_bar,
            text="✕",
            bg=self.colors['bg_mid'],
            fg=self.colors['text_main'],
            font=('Segoe UI', 12),
            bd=0,
            command=self.close_window,
            cursor='hand2'
        )
        close_btn.pack(side=tk.RIGHT, padx=5)
        
        min_btn = tk.Button(
            self.title_bar,
            text="─",
            bg=self.colors['bg_mid'],
            fg=self.colors['text_main'],
            font=('Segoe UI', 12),
            bd=0,
            command=self.toggle_minimize,
            cursor='hand2'
        )
        min_btn.pack(side=tk.RIGHT, padx=5)
        
        self.enable_dragging()
    
    def create_editor(self):
        self.monaco_editor = MonacoEditor(self.main_frame)
        self.monaco_editor.pack(fill=tk.BOTH, expand=True, padx=1, pady=0)
    
    def create_toolbar(self):
        toolbar = tk.Frame(
            self.main_frame,
            bg=self.colors['bg_mid'],
            height=40,
            highlightbackground=self.colors['stroke_inner'],
            highlightthickness=1
        )
        toolbar.pack(fill=tk.X, side=tk.BOTTOM)
        toolbar.pack_propagate(False)
        
        buttons_config = [
            ('Execute', self.execute_code, self.colors['accent_purple'], True),
            ('Clear', self.clear_editor, self.colors['stroke_btn'], False),
            ('Open File', self.open_file, self.colors['stroke_btn'], False),
            ('Save File', self.save_file, self.colors['stroke_btn'], False),
            ('Connect DLL', self.connect_to_dll, self.colors['accent_blue'], False),
            ('Attach', self.attach, self.colors['stroke_btn'], False),
        ]
        
        x_pos = 10
        self.buttons = {}
        
        for text, command, accent, is_primary in buttons_config:
            btn = tk.Button(
                toolbar,
                text=text,
                bg=self.colors['bg_btn'],
                fg=self.colors['text_main'],
                font=('Segoe UI', 9),
                bd=0,
                cursor='hand2',
                command=command,
                relief=tk.FLAT,
                highlightbackground=accent,
                highlightthickness=1 if is_primary else 0
            )
            btn.place(x=x_pos, y=8, width=90, height=24)
            self.buttons[text] = btn
            x_pos += 95
    
    def create_status_bar(self):
        """Create status bar for messages"""
        self.status_bar = tk.Label(
            self.main_frame,
            text="Ready",
            bg=self.colors['bg_main'],
            fg=self.colors['text_dim'],
            font=('Segoe UI', 8),
            anchor='w'
        )
        self.status_bar.pack(fill=tk.X, side=tk.BOTTOM, padx=5, pady=2)
    
    def enable_dragging(self):
        self.drag_data = {'x': 0, 'y': 0}
        
        def start_drag(event):
            self.drag_data['x'] = event.x
            self.drag_data['y'] = event.y
        
        def do_drag(event):
            x = self.root.winfo_x() + (event.x - self.drag_data['x'])
            y = self.root.winfo_y() + (event.y - self.drag_data['y'])
            self.root.geometry(f"+{x}+{y}")
        
        self.title_bar.bind('<Button-1>', start_drag)
        self.title_bar.bind('<B1-Motion>', do_drag)
    
    def bind_events(self):
        self.root.bind('<Control-o>', lambda e: self.open_file())
        self.root.bind('<Control-s>', lambda e: self.save_file())
        self.root.bind('<Control-e>', lambda e: self.execute_code())
        self.root.bind('<F5>', lambda e: self.execute_code())
    
    def update_status(self, message, color=None):
        """Update status bar message"""
        self.status_bar.config(text=message)
        if color:
            self.status_bar.config(fg=color)
    
    def auto_connect(self):
        """Automatically try to connect to DLL"""
        if self.pipe_client.connect():
            self.update_connection_status(True)
            self.update_status("Connected to DLL", self.colors['attach_on'])
        else:
            self.update_status("DLL not found - Click 'Connect DLL' to retry", self.colors['attach_off'])
    
    def connect_to_dll(self):
        """Manually connect to DLL"""
        if self.pipe_client.connected:
            messagebox.showinfo("Info", "Already connected to DLL")
            return
        
        if self.pipe_client.connect():
            self.update_connection_status(True)
            self.update_status("Connected to DLL", self.colors['attach_on'])
            messagebox.showinfo("Success", "Connected to Synapse X DLL!")
        else:
            messagebox.showerror("Error", 
                "Failed to connect to DLL.\n\n"
                "Make sure:\n"
                "1. The Synapse X DLL is running\n"
                "2. The named pipe server is active\n"
                "3. You have proper permissions"
            )
    
    def update_connection_status(self, connected):
        """Update connection status indicator"""
        if connected:
            self.status_indicator.config(
                text="● Connected",
                fg=self.colors['attach_on']
            )
        else:
            self.status_indicator.config(
                text="● Disconnected",
                fg=self.colors['attach_off']
            )
    
    def execute_code(self):
        """Execute code via Named Pipe"""
        code = self.monaco_editor.get_text()
        
        if not code or not code.strip():
            self.update_status("No code to execute", self.colors['attach_off'])
            return
        
        if not self.pipe_client.connected:
            messagebox.showerror("Error", "Not connected to DLL!\nClick 'Connect DLL' first.")
            return
        
        # Send execute command via pipe
        def on_response(response):
            success = response.get('success', False)
            message = response.get('message', 'Unknown response')
            
            if success:
                self.update_status(f"✓ Executed successfully", self.colors['attach_on'])
                print(f"[Synapse X] Execution successful: {message}")
            else:
                self.update_status(f"✗ Execution failed: {message}", self.colors['attach_off'])
                print(f"[Synapse X] Execution failed: {message}")
        
        success = self.pipe_client.send_command('execute', code, callback=on_response)
        
        if success:
            self.update_status("Sending script to DLL...", self.colors['accent_blue'])
            # Flash execute button
            original_bg = self.buttons['Execute'].cget('bg')
            self.buttons['Execute'].config(bg=self.colors['accent_blue'])
            self.root.after(150, lambda: self.buttons['Execute'].config(bg=original_bg))
        else:
            self.update_status("Failed to send command", self.colors['attach_off'])
    
    def attach(self):
        """Attach to Roblox via DLL"""
        if not self.pipe_client.connected:
            messagebox.showerror("Error", "Not connected to DLL!")
            return
        
        def on_attach_response(response):
            success = response.get('success', False)
            
            if success:
                self.is_attached = True
                self.buttons['Attach'].config(
                    highlightbackground=self.colors['attach_on'],
                    highlightthickness=2
                )
                self.update_status("✓ Attached to Roblox", self.colors['attach_on'])
            else:
                self.is_attached = False
                self.update_status("✗ Attach failed", self.colors['attach_off'])
        
        if not self.is_attached:
            self.pipe_client.send_command('attach', None, callback=on_attach_response)
            self.update_status("Attaching to Roblox...", self.colors['accent_blue'])
        else:
            # Detach
            self.pipe_client.send_command('detach')
            self.is_attached = False
            self.buttons['Attach'].config(highlightthickness=0)
            self.update_status("Detached from Roblox", self.colors['text_dim'])
    
    def clear_editor(self):
        self.monaco_editor.clear()
        self.update_status("Editor cleared", self.colors['text_dim'])
    
    def open_file(self):
        filename = filedialog.askopenfilename(
            title="Open Script",
            filetypes=[
                ("Lua files", "*.lua"),
                ("Text files", "*.txt"),
                ("All files", "*.*")
            ]
        )
        if filename:
            try:
                with open(filename, 'r', encoding='utf-8') as f:
                    content = f.read()
                self.monaco_editor.set_text(content)
                self.update_status(f"Opened: {Path(filename).name}", self.colors['attach_on'])
            except Exception as e:
                messagebox.showerror("Error", f"Failed to open file:\n{str(e)}")
    
    def save_file(self):
        filename = filedialog.asksaveasfilename(
            title="Save Script",
            defaultextension=".lua",
            filetypes=[
                ("Lua files", "*.lua"),
                ("Text files", "*.txt"),
                ("All files", "*.*")
            ]
        )
        if filename:
            try:
                with open(filename, 'w', encoding='utf-8') as f:
                    f.write(self.monaco_editor.get_text())
                self.update_status(f"Saved: {Path(filename).name}", self.colors['attach_on'])
            except Exception as e:
                messagebox.showerror("Error", f"Failed to save file:\n{str(e)}")
    
    def toggle_minimize(self):
        if not self.is_minimized:
            self.monaco_editor.pack_forget()
            self.root.geometry(f"820x32")
            self.is_minimized = True
        else:
            self.monaco_editor.pack(fill=tk.BOTH, expand=True, padx=1, pady=0)
            self.root.geometry("820x550")
            self.is_minimized = False
    
    def close_window(self):
        """Close window and cleanup"""
        def destroy():
            self.pipe_client.disconnect()
            self.root.destroy()
        
        self.animator.fade_out(self.root, duration=200, callback=destroy)


def main():
    # Check for pywin32
    try:
        import win32file
        import win32pipe
    except ImportError:
        print("ERROR: pywin32 is required for Named Pipe communication")
        print("Install with: pip install pywin32")
        sys.exit(1)
    
    root = tk.Tk()
    app = SynapseXUI(root)
    
    # Center window
    root.update_idletasks()
    width = root.winfo_width()
    height = root.winfo_height()
    x = (root.winfo_screenwidth() // 2) - (width // 2)
    y = (root.winfo_screenheight() // 2) - (height // 2)
    root.geometry(f'{width}x{height}+{x}+{y}')
    
    root.mainloop()


if __name__ == "__main__":
    main()
