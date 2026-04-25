import tkinter as tk
from tkinter import ttk, scrolledtext
import re

class SynapseXUI:
    def __init__(self, root):
        self.root = root
        self.root.title("Synapse X")
        self.root.geometry("706x289")
        self.root.resizable(False, False)
        
        # Color theme
        self.colors = {
            'bg_deep': '#16161a',
            'bg_mid': '#1e1e23',
            'bg_panel': '#1a1a1f',
            'bg_editor': '#121216',
            'bg_btn': '#26262d',
            'bg_btn_hov': '#34343e',
            'stroke_outer': '#3c3c4b',
            'stroke_inner': '#2d2d3a',
            'stroke_btn': '#373744',
            'stroke_accent': '#5050b4',
            'text_main': '#dcdce6',
            'text_dim': '#828296',
            'text_tab': '#c8c8d7',
            'icon_tint': '#b4b4c8',
            'close_hov': '#b43232',
            'attach_on': '#32b450'
        }
        
        # Syntax colors
        self.syntax = {
            'text': '#cccccc',
            'operator': '#cccccc',
            'number': '#ffc600',
            'string': '#adf195',
            'comment': '#666666',
            'keyword': '#f86d7c',
            'builtin': '#84d6f7',
            'method': '#fdfbac',
            'property': '#61a1f1',
            'nil': '#ffc600',
            'bool': '#ffc600',
            'function': '#f86d7c',
            'bracket': '#cccccc'
        }
        
        self.setup_ui()
        self.bind_events()
        
    def setup_ui(self):
        # Main frame
        self.root.configure(bg=self.colors['bg_deep'])
        
        # Title bar
        title_frame = tk.Frame(self.root, bg=self.colors['bg_mid'], height=28)
        title_frame.pack(fill=tk.X)
        title_frame.pack_propagate(False)
        
        # Title label
        title_label = tk.Label(
            title_frame, 
            text="Synapse X", 
            bg=self.colors['bg_mid'],
            fg=self.colors['text_main'],
            font=('Arial', 10, 'bold'),
            anchor='w'
        )
        title_label.pack(side=tk.LEFT, padx=32, fill=tk.Y)
        
        # Close button
        self.close_btn = tk.Button(
            title_frame,
            text="X",
            bg=self.colors['bg_mid'],
            fg=self.colors['text_dim'],
            font=('Arial', 9, 'bold'),
            bd=0,
            width=3,
            cursor='hand2',
            command=self.root.quit
        )
        self.close_btn.pack(side=tk.RIGHT, padx=2, pady=4)
        
        # Minimize button
        self.min_btn = tk.Button(
            title_frame,
            text="─",
            bg=self.colors['bg_mid'],
            fg=self.colors['text_dim'],
            font=('Arial', 9, 'bold'),
            bd=0,
            width=3,
            cursor='hand2',
            command=self.root.iconify
        )
        self.min_btn.pack(side=tk.RIGHT, pady=4)
        
        # Accent line
        accent_line = tk.Frame(self.root, bg=self.colors['stroke_accent'], height=1)
        accent_line.pack(fill=tk.X)
        
        # Tab bar
        tab_frame = tk.Frame(self.root, bg=self.colors['bg_panel'], height=22)
        tab_frame.pack(fill=tk.X)
        tab_frame.pack_propagate(False)
        
        # Active tab
        active_tab = tk.Frame(tab_frame, bg=self.colors['bg_deep'], width=88)
        active_tab.pack(side=tk.LEFT, fill=tk.Y)
        
        tab_label = tk.Label(
            active_tab,
            text="Script 1",
            bg=self.colors['bg_deep'],
            fg=self.colors['text_tab'],
            font=('Arial', 9)
        )
        tab_label.pack(side=tk.LEFT, padx=6)
        
        tab_close = tk.Button(
            active_tab,
            text="✕",
            bg=self.colors['bg_deep'],
            fg=self.colors['text_dim'],
            font=('Arial', 7),
            bd=0,
            cursor='hand2',
            command=self.clear_editor
        )
        tab_close.pack(side=tk.RIGHT, padx=4)
        
        # New tab button
        new_tab = tk.Button(
            tab_frame,
            text="+",
            bg=self.colors['bg_panel'],
            fg=self.colors['text_dim'],
            font=('Arial', 11, 'bold'),
            bd=0,
            width=2,
            cursor='hand2',
            command=self.new_tab
        )
        new_tab.pack(side=tk.LEFT)
        
        # Editor container
        editor_container = tk.Frame(self.root, bg=self.colors['bg_editor'])
        editor_container.pack(fill=tk.BOTH, expand=True, padx=0, pady=0)
        
        # Line numbers frame
        line_frame = tk.Frame(editor_container, bg=self.colors['bg_panel'], width=38)
        line_frame.pack(side=tk.LEFT, fill=tk.Y)
        line_frame.pack_propagate(False)
        
        self.line_numbers = tk.Text(
            line_frame,
            width=3,
            bg=self.colors['bg_panel'],
            fg=self.colors['text_dim'],
            font=('Consolas', 10),
            bd=0,
            state=tk.DISABLED,
            cursor='arrow'
        )
        self.line_numbers.pack(fill=tk.BOTH, expand=True, padx=4, pady=4)
        
        # Code editor
        self.code_editor = scrolledtext.ScrolledText(
            editor_container,
            bg=self.colors['bg_editor'],
            fg=self.colors['text_main'],
            insertbackground=self.colors['text_main'],
            font=('Consolas', 10),
            bd=0,
            wrap=tk.NONE,
            undo=True,
            maxundo=-1
        )
        self.code_editor.pack(side=tk.LEFT, fill=tk.BOTH, expand=True, padx=6, pady=4)
        self.code_editor.insert('1.0', '-- paste or type your script here')
        
        # Toolbar
        toolbar = tk.Frame(self.root, bg=self.colors['bg_mid'], height=34)
        toolbar.pack(fill=tk.X, side=tk.BOTTOM)
        toolbar.pack_propagate(False)
        
        # Toolbar buttons
        buttons_config = [
            ('Execute', self.execute_code, self.colors['stroke_accent']),
            ('Clear', self.clear_editor, self.colors['stroke_btn']),
            ('Open File', self.open_file, self.colors['stroke_btn']),
            ('Execute File', self.execute_file, self.colors['stroke_btn']),
            ('Save File', self.save_file, self.colors['stroke_btn']),
            ('Options', self.options, self.colors['stroke_btn']),
            ('Attach', self.attach, self.colors['stroke_btn']),
            ('Script Hub', self.script_hub, self.colors['stroke_btn'])
        ]
        
        x_pos = 6
        for text, command, border_color in buttons_config:
            btn = tk.Button(
                toolbar,
                text=text,
                bg=self.colors['bg_btn'],
                fg=self.colors['text_main'],
                font=('Arial', 9),
                bd=1,
                relief=tk.SOLID,
                cursor='hand2',
                command=command,
                width=10,
                highlightbackground=border_color,
                highlightthickness=1
            )
            btn.place(x=x_pos, y=6, width=86, height=22)
            self.bind_hover(btn)
            x_pos += 92
        
        self.update_line_numbers()
        
    def bind_events(self):
        self.code_editor.bind('<KeyRelease>', self.on_text_change)
        self.code_editor.bind('<Button-1>', lambda e: self.update_line_numbers())
        
        # Hover effects for title bar buttons
        self.close_btn.bind('<Enter>', lambda e: self.close_btn.config(bg=self.colors['close_hov']))
        self.close_btn.bind('<Leave>', lambda e: self.close_btn.config(bg=self.colors['bg_mid']))
        self.min_btn.bind('<Enter>', lambda e: self.min_btn.config(bg=self.colors['bg_btn_hov']))
        self.min_btn.bind('<Leave>', lambda e: self.min_btn.config(bg=self.colors['bg_mid']))
        
    def bind_hover(self, button):
        button.bind('<Enter>', lambda e: button.config(bg=self.colors['bg_btn_hov']))
        button.bind('<Leave>', lambda e: button.config(bg=self.colors['bg_btn']))
        
    def on_text_change(self, event=None):
        self.update_line_numbers()
        
    def update_line_numbers(self):
        line_count = int(self.code_editor.index('end-1c').split('.')[0])
        line_numbers_text = '\n'.join(str(i) for i in range(1, line_count + 1))
        
        self.line_numbers.config(state=tk.NORMAL)
        self.line_numbers.delete('1.0', tk.END)
        self.line_numbers.insert('1.0', line_numbers_text)
        self.line_numbers.config(state=tk.DISABLED)
        
    def execute_code(self):
        code = self.code_editor.get('1.0', tk.END).strip()
        if code and code != '-- paste or type your script here':
            print(f"[SynapseUI] Executing code:\n{code}")
            # In a real implementation, you would execute the Lua code here
        else:
            print("[SynapseUI] No code to execute")
            
    def clear_editor(self):
        self.code_editor.delete('1.0', tk.END)
        self.update_line_numbers()
        
    def open_file(self):
        from tkinter import filedialog
        filename = filedialog.askopenfilename(
            title="Open Script",
            filetypes=[("Lua files", "*.lua"), ("Text files", "*.txt"), ("All files", "*.*")]
        )
        if filename:
            try:
                with open(filename, 'r') as f:
                    content = f.read()
                self.code_editor.delete('1.0', tk.END)
                self.code_editor.insert('1.0', content)
                print(f"[SynapseUI] Opened: {filename}")
            except Exception as e:
                print(f"[SynapseUI] Error opening file: {e}")
                
    def execute_file(self):
        from tkinter import filedialog
        filename = filedialog.askopenfilename(
            title="Execute Script",
            filetypes=[("Lua files", "*.lua"), ("All files", "*.*")]
        )
        if filename:
            try:
                with open(filename, 'r') as f:
                    code = f.read()
                print(f"[SynapseUI] Executing file: {filename}")
                print(f"Code:\n{code}")
            except Exception as e:
                print(f"[SynapseUI] Error executing file: {e}")
                
    def save_file(self):
        from tkinter import filedialog
        filename = filedialog.asksaveasfilename(
            title="Save Script",
            defaultextension=".lua",
            filetypes=[("Lua files", "*.lua"), ("Text files", "*.txt"), ("All files", "*.*")]
        )
        if filename:
            try:
                with open(filename, 'w') as f:
                    f.write(self.code_editor.get('1.0', tk.END))
                print(f"[SynapseUI] Saved to: {filename}")
            except Exception as e:
                print(f"[SynapseUI] Error saving file: {e}")
                
    def options(self):
        print("[SynapseUI] Options clicked")
        
    def attach(self):
        print("[SynapseUI] Attach clicked")
        
    def script_hub(self):
        print("[SynapseUI] Script Hub clicked")
        
    def new_tab(self):
        self.clear_editor()
        print("[SynapseUI] New tab created")

def main():
    root = tk.Tk()
    app = SynapseXUI(root)
    root.mainloop()

if __name__ == "__main__":
    main()