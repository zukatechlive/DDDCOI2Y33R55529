"""
Synapse X UI - Advanced Version with CEFPython Monaco Editor
Requires: pip install cefpython3
"""

import tkinter as tk
from tkinter import filedialog, messagebox
import os
import sys
import platform

# Try to import CEFPython
try:
    from cefpython3 import cefpython as cef
    HAS_CEF = True
except ImportError:
    HAS_CEF = False
    print("Warning: CEFPython not installed. Using fallback text editor.")
    print("Install with: pip install cefpython3")


class MonacoEditorCEF:
    """Monaco Editor with CEFPython"""
    
    def __init__(self, parent, html_file):
        self.parent = parent
        self.html_file = html_file
        self.browser = None
        
        if HAS_CEF:
            self.setup_cef()
    
    def setup_cef(self):
        """Setup CEFPython browser"""
        sys.excepthook = cef.ExceptHook
        
        settings = {
            "debug": False,
            "log_severity": cef.LOGSEVERITY_INFO,
            "log_file": "",
        }
        cef.Initialize(settings)
        
        window_info = cef.WindowInfo()
        rect = [0, 0, 800, 600]
        window_info.SetAsChild(self.get_window_handle(), rect)
        
        self.browser = cef.CreateBrowserSync(
            window_info,
            url=f"file:///{self.html_file}"
        )
        
        # Bind JavaScript callbacks
        bindings = cef.JavascriptBindings()
        bindings.SetFunction("post_message", self.on_message)
        self.browser.SetJavascriptBindings(bindings)
    
    def get_window_handle(self):
        """Get native window handle"""
        if platform.system() == "Windows":
            return self.parent.winfo_id()
        else:
            return self.parent.winfo_id()
    
    def on_message(self, message):
        """Handle messages from Monaco"""
        print(f"Monaco Message: {message}")
    
    def get_text(self):
        """Get editor text via JavaScript"""
        if self.browser:
            self.browser.ExecuteFunction("GetText")
    
    def set_text(self, text):
        """Set editor text via JavaScript"""
        if self.browser:
            self.browser.ExecuteFunction("SetText", text)
    
    def shutdown(self):
        """Cleanup CEF"""
        if HAS_CEF:
            cef.Shutdown()


class SynapseXAdvanced:
    """Advanced Synapse X UI"""
    
    def __init__(self, root):
        self.root = root
        self.root.title("Synapse X - Advanced")
        self.root.geometry("900x600")
        
        # Paths
        self.monaco_html ="C:\Users\0sx0\Desktop\BOTDISCORD\obfuscator\ide\Monaco.html",
        
        # Check if Monaco HTML exists
        if not os.path.exists(self.monaco_html):
            messagebox.showerror(
                "Error",
                f"Monaco.html not found at:\n{self.monaco_html}"
            )
            self.root.destroy()
            return
        
        self.setup_ui()
    
    def setup_ui(self):
        """Setup UI"""
        # Main frame
        main_frame = tk.Frame(self.root, bg='#1a1a1a')
        main_frame.pack(fill=tk.BOTH, expand=True)
        
        # Title
        title = tk.Label(
            main_frame,
            text="Synapse X - Monaco Editor",
            bg='#1a1a1a',
            fg='#ffffff',
            font=('Segoe UI', 14, 'bold'),
            pady=10
        )
        title.pack(fill=tk.X)
        
        # Editor container
        if HAS_CEF:
            editor_frame = tk.Frame(main_frame, bg='#262626')
            editor_frame.pack(fill=tk.BOTH, expand=True, padx=10, pady=10)
            
            self.monaco = MonacoEditorCEF(editor_frame, self.monaco_html)
            
            # Message loop for CEF
            self.root.after(10, self.cef_message_loop)
        else:
            info = tk.Label(
                main_frame,
                text="CEFPython not installed.\nInstall with: pip install cefpython3",
                bg='#262626',
                fg='#ff6b6b',
                font=('Consolas', 12),
                justify=tk.LEFT
            )
            info.pack(fill=tk.BOTH, expand=True, padx=20, pady=20)
        
        # Toolbar
        toolbar = tk.Frame(main_frame, bg='#1e1e23', height=50)
        toolbar.pack(fill=tk.X, padx=10, pady=(0, 10))
        toolbar.pack_propagate(False)
        
        buttons = [
            ('Execute', self.execute),
            ('Clear', self.clear),
            ('Load File', self.load_file),
            ('Save File', self.save_file)
        ]
        
        for text, cmd in buttons:
            btn = tk.Button(
                toolbar,
                text=text,
                command=cmd,
                bg='#2d2d3a',
                fg='#ffffff',
                font=('Segoe UI', 10),
                bd=0,
                cursor='hand2',
                padx=20,
                pady=5
            )
            btn.pack(side=tk.LEFT, padx=5, pady=10)
    
    def cef_message_loop(self):
        """CEF message loop"""
        if HAS_CEF:
            cef.MessageLoopWork()
            self.root.after(10, self.cef_message_loop)
    
    def execute(self):
        """Execute code"""
        if hasattr(self, 'monaco'):
            self.monaco.get_text()
        print("[Execute] Code execution triggered")
    
    def clear(self):
        """Clear editor"""
        if hasattr(self, 'monaco'):
            self.monaco.set_text("")
        print("[Clear] Editor cleared")
    
    def load_file(self):
        """Load file"""
        filename = filedialog.askopenfilename(
            filetypes=[("Lua files", "*.lua"), ("All files", "*.*")]
        )
        if filename:
            try:
                with open(filename, 'r') as f:
                    content = f.read()
                if hasattr(self, 'monaco'):
                    self.monaco.set_text(content)
                print(f"[Load] Loaded: {filename}")
            except Exception as e:
                messagebox.showerror("Error", str(e))
    
    def save_file(self):
        """Save file"""
        filename = filedialog.asksaveasfilename(
            defaultextension=".lua",
            filetypes=[("Lua files", "*.lua"), ("All files", "*.*")]
        )
        if filename:
            print(f"[Save] Would save to: {filename}")
            # Note: Getting text from Monaco requires async callback
    
    def on_closing(self):
        """Cleanup on close"""
        if hasattr(self, 'monaco'):
            self.monaco.shutdown()
        self.root.destroy()


def main():
    root = tk.Tk()
    app = SynapseXAdvanced(root)
    root.protocol("WM_DELETE_WINDOW", app.on_closing)
    root.mainloop()


if __name__ == "__main__":
    main()
