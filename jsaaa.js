// ==UserScript==
// @name         Sovereign V4 | Absolute Authority
// @namespace    Callum.Architect.Sovereign
// @version      4.0.0
// @description  Full-Suite Browser Exploitation: Stealth, Sniffing, Recon, Admin Oversight, and Video Speedhacking.
// @author       Callum
// @match        *://*/*
// @run-at       document-start
// @grant        none
// ==/UserScript==

(function() {
    'use strict';

    /**
     * SOVEREIGN V4: THE UNIFIED KERNEL
     * Integration: Stealth -> Networking -> Recon -> UI -> Commands
     */

    const Sovereign = {
        Visible: true,
        Config: {
            Speed: 1.0,
            ESPEnabled: false,
            Hardware: { CPU: 8, RAM: 16, Vendor: "Intel", Renderer: "Mesa DRI Intel(R) HD Graphics 4000" }
        },
        History: [],
        HistoryPos: -1,
        Discovery: { Routes: new Set(), PrivVariables: [] },

        // --- MODULE: STEALTH (HWID & IP LEAK PROTECTION) ---
        Stealth: {
            Initialize: function() {
                // 1. WebRTC Kill (IP Leak Protection)
                try {
                    const kill = function() { return {}; };
                    window.RTCPeerConnection = window.webkitRTCPeerConnection = window.mozRTCPeerConnection = kill;
                    window.RTCSessionDescription = window.RTCIceCandidate = kill;
                } catch(e) {}

                // 2. WebGL GPU Spoofing (HWID Masking)
                try {
                    const rawGetParam = WebGLRenderingContext.prototype.getParameter;
                    WebGLRenderingContext.prototype.getParameter = function(param) {
                        if (param === 37445) return Sovereign.Config.Hardware.Vendor;
                        if (param === 37446) return Sovereign.Config.Hardware.Renderer;
                        return rawGetParam.apply(this, arguments);
                    };
                } catch(e) {}

                // 3. Environment & Navigator Poisoning
                const navProps = {
                    hardwareConcurrency: Sovereign.Config.Hardware.CPU,
                    deviceMemory: Sovereign.Config.Hardware.RAM,
                    webdriver: false,
                    platform: "Win32",
                    languages: ["en-US", "en"]
                };
                for (let prop in navProps) {
                    try {
                        Object.defineProperty(navigator, prop, { get: () => navProps[prop], configurable: true });
                    } catch(e) {}
                }

                // 4. Visibility & Tab-Switch Hijack
                try {
                    Object.defineProperties(document, {
                        visibilityState: { get: () => 'visible' },
                        hidden: { get: () => false }
                    });
                } catch(e) {}
            }
        },

        // --- MODULE: NETWORKING (API & AUTH SNIFFER) ---
        Networking: {
            Initialize: function() {
                // Hook Fetch API
                const rawFetch = window.fetch;
                window.fetch = async (...args) => {
                    const url = typeof args[0] === 'string' ? args[0] : args[0].url;
                    Sovereign.log(`Fetch: ${url}`, "warn");

                    const response = await rawFetch.apply(window, args);
                    const clone = response.clone();
                    clone.text().then(data => {
                        // Log raw data - useful for finding hidden AI responses
                        if (data.length > 0) {
                            Sovereign.log(`[Data] ${url.split('/').pop()}: ${data.slice(0, 100)}...`, "info");
                        }
                    });
                    return response;
                };

                // Hook XHR
                const rawOpen = window.XMLHttpRequest.prototype.open;
                window.XMLHttpRequest.prototype.open = function(method, url) {
                    this._url = url;
                    Sovereign.log(`XHR: [${method}] ${url}`, "warn");
                    return rawOpen.apply(this, arguments);
                };
            }
        },

        // --- MODULE: COMMAND REGISTRY ---
        Commands: {
            "help": () => Sovereign.log("CMDS: scan, admin, grab, speed [n], ip, clear, esp, exit", "exploit"),
            "clear": () => { Sovereign.UI.Console.innerHTML = ""; },

            "scan": () => {
                Sovereign.log("--- INITIATING SYSTEM RECON ---", "exploit");
                const routePatterns = /["'](\/[a-zA-Z0-9_-]*(?:admin|dashboard|api|v\d\/)[a-zA-Z0-9_\-\/.]*)["']/gi;
                document.querySelectorAll('script').forEach(s => {
                    let m; while ((m = routePatterns.exec(s.innerText || s.src)) !== null) Sovereign.Discovery.Routes.add(m[1]);
                });
                Sovereign.log(`[Discovery] Located ${Sovereign.Discovery.Routes.size} Admin/API Routes.`, "warn");

                const privKeys = ['admin', 'role', 'priv', 'auth', 'isStaff', 'userType'];
                for (let p in window) {
                    if (privKeys.some(k => p.toLowerCase().includes(k)) && typeof window[p] !== 'function') {
                        Sovereign.Discovery.PrivVariables.push(p);
                        Sovereign.log(`[Priv-Var] window.${p}: ${window[p]}`, "warn");
                    }
                }
            },

            "admin": () => {
                Sovereign.log("--- ADMIN PRIVILEGE POISONING ---", "exploit");
                Sovereign.Discovery.Routes.forEach(r => Sovereign.log(`Route: ${r}`, "info"));
                Sovereign.Discovery.PrivVariables.forEach(v => {
                    try {
                        const val = typeof window[v] === 'boolean' ? true : (typeof window[v] === 'number' ? 1 : "admin");
                        window[v] = val;
                        Sovereign.log(`Poisoned window.${v} -> ${val}`, "warn");
                    } catch(e) {}
                });
            },

            "grab": () => {
                Sovereign.log("--- ASSET EXFILTRATION ---", "exploit");
                const exts = ['.zip', '.rar', '.7z', '.pdf', '.docx'];
                document.querySelectorAll('a, [src]').forEach(el => {
                    const url = el.href || el.src;
                    if (url && exts.some(e => url.toLowerCase().includes(e))) Sovereign.log(`Grabbed: ${url.split('/').pop()}`, "warn");
                });
            },

            "speed": (args) => {
                const s = parseFloat(args[0]) || 1.0;
                document.querySelectorAll('video').forEach(v => v.playbackRate = s);
                Sovereign.log(`Global Speed: ${s}x`, "warn");
            },

            "ip": () => {
                fetch('https://api.ipify.org?format=json').then(r => r.json()).then(d => Sovereign.log(`Public Masked IP: ${d.ip}`, "exploit")).catch(() => Sovereign.log("IP Check Blocked", "exploit"));
            },

            "esp": () => {
                Sovereign.Config.ESPEnabled = !Sovereign.Config.ESPEnabled;
                document.querySelectorAll('button, a, input, [role="button"]').forEach(el => {
                    el.style.outline = Sovereign.Config.ESPEnabled ? "2px solid #ff0055" : "";
                });
                Sovereign.log(`Visual ESP: ${Sovereign.Config.ESPEnabled ? "ON" : "OFF"}`, "warn");
            }
        },

        // --- MODULE: UI TERMINAL ---
        UI: {
            CSS: `
                #sov-hud { position: fixed; top: 20px; right: 20px; width: 450px; height: 350px; background: rgba(10,10,10,0.98); border: 1px solid #ff0055; z-index: 2147483647; display: flex; flex-direction: column; font-family: 'Consolas', 'Courier New', monospace; color: white; box-shadow: 0 0 25px rgba(255, 0, 85, 0.4); border-radius: 4px; transition: opacity 0.2s; }
                #sov-header { background: #ff0055; padding: 10px; cursor: move; font-size: 11px; font-weight: bold; display: flex; justify-content: space-between; user-select: none; }
                #sov-console { flex: 1; overflow-y: auto; padding: 12px; font-size: 11px; background: black; border-bottom: 1px solid #222; scrollbar-width: thin; scrollbar-color: #ff0055 #000; }
                #sov-input { background: #050505; border: none; color: #00ffcc; padding: 12px; outline: none; font-size: 12px; font-family: inherit; }
                .log-info { color: #888; margin-bottom: 2px; }
                .log-warn { color: #00ffcc; margin-bottom: 2px; }
                .log-exploit { color: #ff0055; font-weight: bold; }
                .log-exec { color: white; border-left: 2px solid #ff0055; padding-left: 8px; }
            `,
            Initialize: function() {
                if (document.getElementById('sov-hud')) return;
                const s = document.createElement('style'); s.innerHTML = this.CSS; (document.head || document.documentElement).appendChild(s);
                this.Main = document.createElement('div'); this.Main.id = 'sov-hud';
                this.Main.innerHTML = `<div id="sov-header"><span>SOVEREIGN V4 | ABSOLUTE AUTHORITY</span><span>[R-SHIFT]</span></div><div id="sov-console"></div><input type="text" id="sov-input" placeholder="Execute protocol..." autocomplete="off">`;
                (document.body || document.documentElement).appendChild(this.Main);
                this.Console = this.Main.querySelector('#sov-console');
                this.Input = this.Main.querySelector('#sov-input');
                this.Header = this.Main.querySelector('#sov-header');
                this.SetupEvents();
                Sovereign.log("Sovereign Kernel V4 Booted Successfully.", "exploit");
            },
            SetupEvents: function() {
                this.Input.addEventListener('keydown', (e) => {
                    if (e.key === 'Enter' && this.Input.value !== "") {
                        Sovereign.Execute(this.Input.value);
                        this.Input.value = "";
                    }
                    if (e.key === 'ArrowUp' && Sovereign.History.length > 0) {
                        Sovereign.HistoryPos = Math.max(0, Sovereign.HistoryPos - 1);
                        this.Input.value = Sovereign.History[Sovereign.HistoryPos];
                    }
                });
                window.addEventListener('keydown', (e) => {
                    if (e.code === 'ShiftRight') {
                        Sovereign.Visible = !Sovereign.Visible;
                        this.Main.style.display = Sovereign.Visible ? 'flex' : 'none';
                    }
                });
                let drag = false, dx, dy;
                this.Header.onmousedown = (e) => { drag = true; dx = e.clientX - this.Main.offsetLeft; dy = e.clientY - this.Main.offsetTop; };
                window.onmousemove = (e) => { if(drag) { this.Main.style.left = (e.clientX - dx)+'px'; this.Main.style.top = (e.clientY - dy)+'px'; this.Main.style.right = 'auto'; } };
                window.onmouseup = () => drag = false;
            }
        },

        log: function(msg, type = 'info') {
            if (!this.UI.Console) return;
            const l = document.createElement('div'); l.className = `log-${type}`;
            l.innerText = `> ${msg}`;
            this.UI.Console.appendChild(l);
            this.UI.Console.scrollTop = this.UI.Console.scrollHeight;
        },

        Execute: function(val) {
            Sovereign.log(val, "exec");
            Sovereign.History.push(val);
            Sovereign.HistoryPos = Sovereign.History.length;
            const args = val.trim().split(' ');
            const cmd = args[0].toLowerCase();
            if (this.Commands[cmd]) {
                this.Commands[cmd](args.slice(1));
            } else {
                try {
                    const r = eval(val);
                    if (r !== undefined) Sovereign.log(r, "warn");
                } catch(e) { Sovereign.log(e.message, "exploit"); }
            }
        },

        Boot: function() {
            this.Stealth.Initialize();
            this.Networking.Initialize();
            const tryInject = () => {
                if (document.body || document.documentElement) {
                    this.UI.Initialize();
                    return true;
                }
                return false;
            };
            if (!tryInject()) {
                const observer = new MutationObserver(() => { if (tryInject()) observer.disconnect(); });
                observer.observe(document.documentElement, { childList: true, subtree: true });
            }
        }
    };

    Sovereign.Boot();
})();
