// ==UserScript==
// @name         Sovereign
// @namespace    Callum.Architect.Sovereign
// @version      5.0.0
// @description  Passive Recon + Network Inspection Toolkit
// @author       Callum
// @match        *://*/*
// @run-at       document-start
// @grant        none
// ==/UserScript==

(function () {
    'use strict';

    /**
     * SOVEREIGN V5 — PASSIVE RECON + INSPECTION KERNEL
     * Modules: Networking -> Recon -> DOM Inspector -> ESP -> UI -> Commands
     * Designed to mirror Lua executor workflow for browser-side auditing.
     */

    const Sovereign = {
        Visible: true,
        Config: {
            ESPEnabled: false,
            ESPColor: "#ff0055",
            Speed: 1.0,
            FilterKeywords: ['admin', 'role', 'auth', 'token', 'priv', 'isStaff', 'userType', 'permission']
        },

        State: {
            Logs: [],
            History: [],
            HistoryPos: -1,
            NetworkLog: [],
            Discovery: {
                Routes: new Set(),
                Variables: [],
                Cookies: [],
                LocalStorage: {}
            }
        },

        // ── MODULE: NETWORK SNIFFER (Read-Only) ──────────────────────────────
        Networking: {
            Initialize() {
                // Hook Fetch
                const rawFetch = window.fetch;
                window.fetch = async (...args) => {
                    const url = (typeof args[0] === 'string' ? args[0] : args[0]?.url) ?? '?';
                    const method = args[1]?.method ?? 'GET';
                    const entry = { type: 'fetch', method, url, time: Date.now() };
                    Sovereign.State.NetworkLog.push(entry);
                    Sovereign.log(`[FETCH] ${method} ${Sovereign._trimUrl(url)}`, 'net');

                    const response = await rawFetch.apply(window, args);
                    const clone = response.clone();
                    clone.text().then(body => {
                        if (body.length > 0) {
                            entry.preview = body.slice(0, 200);
                            Sovereign.log(`[RESP]  ${Sovereign._trimUrl(url)} — ${body.length} bytes`, 'info');
                        }
                    }).catch(() => {});
                    return response;
                };

                // Hook XHR
                const rawOpen = XMLHttpRequest.prototype.open;
                const rawSend = XMLHttpRequest.prototype.send;

                XMLHttpRequest.prototype.open = function (method, url, ...rest) {
                    this._sov = { method, url, time: Date.now() };
                    return rawOpen.apply(this, [method, url, ...rest]);
                };

                XMLHttpRequest.prototype.send = function (body) {
                    if (this._sov) {
                        const entry = { type: 'xhr', ...this._sov, body: body ? String(body).slice(0, 200) : null };
                        Sovereign.State.NetworkLog.push(entry);
                        Sovereign.log(`[XHR]   ${this._sov.method} ${Sovereign._trimUrl(this._sov.url)}`, 'net');

                        this.addEventListener('load', () => {
                            entry.status = this.status;
                            entry.responsePreview = this.responseText?.slice(0, 200);
                            Sovereign.log(`[XHR✓]  ${this.status} — ${Sovereign._trimUrl(this._sov.url)}`, 'info');
                        });
                    }
                    return rawSend.apply(this, arguments);
                };
            }
        },

        // ── MODULE: RECON ─────────────────────────────────────────────────────
        Recon: {
            ScanRoutes() {
                Sovereign.log('── Route Discovery ──', 'exploit');
                const pattern = /["'`](\/[a-zA-Z0-9_\-/.]*(?:admin|api|dashboard|v\d)[a-zA-Z0-9_\-/.]*)["'`]/gi;
                let count = 0;
                document.querySelectorAll('script').forEach(s => {
                    const src = s.innerText || '';
                    let m;
                    while ((m = pattern.exec(src)) !== null) {
                        if (!Sovereign.State.Discovery.Routes.has(m[1])) {
                            Sovereign.State.Discovery.Routes.add(m[1]);
                            Sovereign.log(`  Route: ${m[1]}`, 'warn');
                            count++;
                        }
                    }
                });
                Sovereign.log(`Found ${count} route(s).`, 'info');
                return count;
            },

            ScanGlobals() {
                Sovereign.log('── Global Variable Scan ──', 'exploit');
                const kw = Sovereign.Config.FilterKeywords;
                let count = 0;
                for (const p in window) {
                    try {
                        if (kw.some(k => p.toLowerCase().includes(k)) && typeof window[p] !== 'function') {
                            const val = JSON.stringify(window[p])?.slice(0, 80) ?? String(window[p]);
                            Sovereign.State.Discovery.Variables.push({ key: p, value: val });
                            Sovereign.log(`  window.${p} = ${val}`, 'warn');
                            count++;
                        }
                    } catch (_) {}
                }
                Sovereign.log(`Found ${count} interesting global(s).`, 'info');
                return count;
            },

            ScanStorage() {
                Sovereign.log('── Storage Dump ──', 'exploit');
                // Cookies (read-only)
                const cookies = document.cookie.split(';').map(c => c.trim()).filter(Boolean);
                cookies.forEach(c => {
                    Sovereign.State.Discovery.Cookies.push(c);
                    Sovereign.log(`  Cookie: ${c.split('=')[0]}`, 'warn');
                });
                // LocalStorage keys
                try {
                    for (let i = 0; i < localStorage.length; i++) {
                        const key = localStorage.key(i);
                        const val = localStorage.getItem(key)?.slice(0, 80);
                        Sovereign.State.Discovery.LocalStorage[key] = val;
                        Sovereign.log(`  LS[${key}]: ${val}`, 'warn');
                    }
                } catch (_) {}
                Sovereign.log(`Found ${cookies.length} cookie(s), ${localStorage.length} LS key(s).`, 'info');
            },

            ScanLinks() {
                Sovereign.log('── Link Harvest ──', 'exploit');
                const seen = new Set();
                document.querySelectorAll('a[href]').forEach(a => {
                    const h = a.href;
                    if (!seen.has(h)) {
                        seen.add(h);
                        Sovereign.log(`  ${h}`, 'info');
                    }
                });
                Sovereign.log(`${seen.size} unique link(s).`, 'info');
            },

            ScanForms() {
                Sovereign.log('── Form Inspector ──', 'exploit');
                document.querySelectorAll('form').forEach((form, i) => {
                    const action = form.action || '(none)';
                    const method = form.method || 'GET';
                    Sovereign.log(`  Form[${i}]: ${method.toUpperCase()} → ${action}`, 'warn');
                    form.querySelectorAll('input, textarea, select').forEach(field => {
                        Sovereign.log(`    Field: name="${field.name}" type="${field.type}" id="${field.id}"`, 'info');
                    });
                });
            }
        },

        // ── MODULE: ESP (Visual DOM Highlighter) ──────────────────────────────
        ESP: {
            Toggle() {
                Sovereign.Config.ESPEnabled = !Sovereign.Config.ESPEnabled;
                const color = Sovereign.Config.ESPColor;
                document.querySelectorAll('button, a, input, select, textarea, [role="button"], [onclick]').forEach(el => {
                    el.style.outline = Sovereign.Config.ESPEnabled ? `2px solid ${color}` : '';
                    el.style.boxShadow = Sovereign.Config.ESPEnabled ? `0 0 6px ${color}55` : '';
                });
                Sovereign.log(`ESP: ${Sovereign.Config.ESPEnabled ? 'ON' : 'OFF'} [${color}]`, 'warn');
            },

            SetColor(hex) {
                if (/^#[0-9a-fA-F]{3,6}$/.test(hex)) {
                    Sovereign.Config.ESPColor = hex;
                    if (Sovereign.Config.ESPEnabled) { this.Toggle(); this.Toggle(); }
                    Sovereign.log(`ESP color → ${hex}`, 'warn');
                } else {
                    Sovereign.log('Invalid hex. Use #rrggbb', 'exploit');
                }
            }
        },

        // ── MODULE: COMMAND REGISTRY ─────────────────────────────────────────
        Commands: {
            help(args) {
                const page = args[0] ? parseInt(args[0]) : 1;
                const pages = {
                    1: [
                        'help [2]      — Show page 2 commands',
                        'scan          — Full recon (routes + globals + storage + forms)',
                        'routes        — Route discovery only',
                        'globals       — Global variable scan only',
                        'storage       — Cookie & localStorage dump',
                        'forms         — Form field inspector',
                        'links         — Harvest all page links',
                    ],
                    2: [
                        'net           — Dump captured network log',
                        'esp           — Toggle visual element highlight',
                        'espcolor #hex — Change ESP color',
                        'speed [n]     — Set video playback speed (e.g. speed 2)',
                        'ip            — Fetch your public IP',
                        'filter [kw]   — Add keyword to global scanner',
                        'export        — Copy full log to clipboard',
                        'clear         — Clear console output',
                    ]
                };
                (pages[page] || pages[1]).forEach(l => Sovereign.log(l, 'info'));
            },

            scan() {
                Sovereign.Recon.ScanRoutes();
                Sovereign.Recon.ScanGlobals();
                Sovereign.Recon.ScanStorage();
                Sovereign.Recon.ScanForms();
            },

            routes()  { Sovereign.Recon.ScanRoutes(); },
            globals() { Sovereign.Recon.ScanGlobals(); },
            storage() { Sovereign.Recon.ScanStorage(); },
            forms()   { Sovereign.Recon.ScanForms(); },
            links()   { Sovereign.Recon.ScanLinks(); },

            net() {
                Sovereign.log(`── Network Log (${Sovereign.State.NetworkLog.length} entries) ──`, 'exploit');
                Sovereign.State.NetworkLog.slice(-30).forEach((e, i) => {
                    Sovereign.log(`  [${i}] ${e.type.toUpperCase()} ${e.method} ${Sovereign._trimUrl(e.url)}${e.status ? ' → ' + e.status : ''}`, 'info');
                });
            },

            esp()           { Sovereign.ESP.Toggle(); },
            espcolor(args)  { Sovereign.ESP.SetColor(args[0]); },

            speed(args) {
                const s = parseFloat(args[0]) || 1.0;
                Sovereign.Config.Speed = s;
                document.querySelectorAll('video, audio').forEach(m => m.playbackRate = s);
                Sovereign.log(`Playback speed → ${s}x`, 'warn');
            },

            ip() {
                fetch('https://api.ipify.org?format=json')
                    .then(r => r.json())
                    .then(d => Sovereign.log(`Public IP: ${d.ip}`, 'exploit'))
                    .catch(() => Sovereign.log('IP fetch blocked or failed.', 'exploit'));
            },

            filter(args) {
                if (!args[0]) { Sovereign.log('Keywords: ' + Sovereign.Config.FilterKeywords.join(', '), 'info'); return; }
                Sovereign.Config.FilterKeywords.push(args[0].toLowerCase());
                Sovereign.log(`Added filter keyword: ${args[0]}`, 'warn');
            },

            export() {
                const text = Sovereign.State.Logs.map(l => l.text).join('\n');
                navigator.clipboard?.writeText(text)
                    .then(() => Sovereign.log('Log copied to clipboard.', 'exploit'))
                    .catch(() => Sovereign.log('Clipboard blocked — try manual copy.', 'exploit'));
            },

            clear() {
                Sovereign.UI.Console.innerHTML = '';
                Sovereign.State.Logs = [];
            }
        },

        // ── MODULE: UI TERMINAL ───────────────────────────────────────────────
        UI: {
            CSS: `
                @import url('https://fonts.googleapis.com/css2?family=JetBrains+Mono:wght@400;700&display=swap');
                #sov-hud {
                    position: fixed; top: 20px; right: 20px;
                    width: 480px; height: 380px;
                    background: #080808;
                    border: 1px solid #ff0055;
                    z-index: 2147483647;
                    display: flex; flex-direction: column;
                    font-family: 'JetBrains Mono', 'Consolas', monospace;
                    color: #ccc;
                    box-shadow: 0 0 30px rgba(255,0,85,0.25), inset 0 0 60px rgba(255,0,85,0.03);
                    border-radius: 3px;
                    resize: both; overflow: hidden;
                    min-width: 300px; min-height: 200px;
                }
                #sov-header {
                    background: linear-gradient(90deg, #ff0055, #cc0033);
                    padding: 7px 12px;
                    cursor: move;
                    font-size: 10px;
                    font-weight: 700;
                    display: flex;
                    justify-content: space-between;
                    align-items: center;
                    user-select: none;
                    letter-spacing: 0.12em;
                    text-transform: uppercase;
                    flex-shrink: 0;
                }
                #sov-header span:last-child { opacity: 0.7; font-size: 9px; }
                #sov-tabs {
                    display: flex;
                    background: #0d0d0d;
                    border-bottom: 1px solid #1a1a1a;
                    flex-shrink: 0;
                }
                .sov-tab {
                    padding: 5px 14px;
                    font-size: 10px;
                    cursor: pointer;
                    color: #555;
                    border-right: 1px solid #1a1a1a;
                    letter-spacing: 0.08em;
                    transition: color 0.15s, background 0.15s;
                }
                .sov-tab:hover { color: #aaa; }
                .sov-tab.active { color: #ff0055; background: #0a0a0a; border-bottom: 1px solid #ff0055; margin-bottom: -1px; }
                #sov-console {
                    flex: 1; overflow-y: auto; padding: 10px 12px;
                    font-size: 10.5px; line-height: 1.6;
                    background: #080808;
                    border-bottom: 1px solid #111;
                    scrollbar-width: thin; scrollbar-color: #ff0055 #0d0d0d;
                }
                #sov-statusbar {
                    padding: 3px 12px;
                    font-size: 9px;
                    color: #333;
                    background: #050505;
                    display: flex;
                    justify-content: space-between;
                    flex-shrink: 0;
                    letter-spacing: 0.06em;
                }
                #sov-input-row {
                    display: flex;
                    background: #050505;
                    border-top: 1px solid #1a1a1a;
                    flex-shrink: 0;
                    align-items: center;
                    padding: 0 0 0 8px;
                }
                #sov-prompt { color: #ff0055; font-size: 11px; font-weight: bold; user-select: none; }
                #sov-input {
                    flex: 1;
                    background: transparent; border: none;
                    color: #00ffcc; padding: 9px 8px;
                    outline: none; font-size: 11px;
                    font-family: inherit; caret-color: #ff0055;
                }
                .log-info    { color: #4a4a4a; }
                .log-warn    { color: #00ffcc; }
                .log-exploit { color: #ff0055; font-weight: 700; letter-spacing: 0.05em; }
                .log-net     { color: #f0a500; }
                .log-exec    { color: #eee; border-left: 2px solid #ff0055; padding-left: 8px; margin: 2px 0; }
                .log-entry   { margin-bottom: 1px; white-space: pre-wrap; word-break: break-all; }
            `,

            Initialize() {
                if (document.getElementById('sov-hud')) return;
                const style = document.createElement('style');
                style.innerHTML = this.CSS;
                (document.head || document.documentElement).appendChild(style);

                this.Main = document.createElement('div');
                this.Main.id = 'sov-hud';
                this.Main.innerHTML = `
                    <div id="sov-header">
                        <span>SOVEREIGN V5</span>
                        <span>R-SHIFT toggle | resize corner</span>
                    </div>
                    <div id="sov-tabs">
                        <div class="sov-tab active" data-tab="console">Console</div>
                        <div class="sov-tab" data-tab="net">Network</div>
                        <div class="sov-tab" data-tab="recon">Recon</div>
                    </div>
                    <div id="sov-console"></div>
                    <div id="sov-statusbar">
                        <span id="sov-stat-net">NET: 0</span>
                        <span id="sov-stat-routes">ROUTES: 0</span>
                        <span id="sov-stat-esp">ESP: OFF</span>
                    </div>
                    <div id="sov-input-row">
                        <span id="sov-prompt">›</span>
                        <input type="text" id="sov-input" placeholder="type a command... (help)" autocomplete="off" spellcheck="false">
                    </div>
                `;
                (document.body || document.documentElement).appendChild(this.Main);

                this.Console = this.Main.querySelector('#sov-console');
                this.Input   = this.Main.querySelector('#sov-input');
                this.Header  = this.Main.querySelector('#sov-header');

                this._setupTabs();
                this._setupDrag();
                this._setupInput();
                this._setupHotkey();
                this._startStatusTick();

                Sovereign.log('Sovereign V5 booted. Type help for commands.', 'exploit');
            },

            _setupTabs() {
                this.Main.querySelectorAll('.sov-tab').forEach(tab => {
                    tab.addEventListener('click', () => {
                        this.Main.querySelectorAll('.sov-tab').forEach(t => t.classList.remove('active'));
                        tab.classList.add('active');
                        const view = tab.dataset.tab;
                        Sovereign.UI.Console.innerHTML = '';
                        if (view === 'net') {
                            Sovereign.Commands.net();
                        } else if (view === 'recon') {
                            const d = Sovereign.State.Discovery;
                            Sovereign.log(`Routes: ${d.Routes.size} | Globals: ${d.Variables.length} | Cookies: ${d.Cookies.length}`, 'exploit');
                            d.Routes.forEach(r => Sovereign.log(`  ${r}`, 'warn'));
                            d.Variables.forEach(v => Sovereign.log(`  window.${v.key} = ${v.value}`, 'warn'));
                        } else {
                            Sovereign.State.Logs.slice(-200).forEach(l => {
                                const el = document.createElement('div');
                                el.className = `log-entry log-${l.type}`;
                                el.innerText = l.text;
                                Sovereign.UI.Console.appendChild(el);
                            });
                            Sovereign.UI.Console.scrollTop = Sovereign.UI.Console.scrollHeight;
                        }
                    });
                });
            },

            _setupInput() {
                this.Input.addEventListener('keydown', e => {
                    const hist = Sovereign.State.History;
                    if (e.key === 'Enter' && this.Input.value.trim()) {
                        Sovereign.Execute(this.Input.value.trim());
                        this.Input.value = '';
                    }
                    if (e.key === 'ArrowUp') {
                        Sovereign.State.HistoryPos = Math.max(0, Sovereign.State.HistoryPos - 1);
                        this.Input.value = hist[Sovereign.State.HistoryPos] ?? '';
                        e.preventDefault();
                    }
                    if (e.key === 'ArrowDown') {
                        Sovereign.State.HistoryPos = Math.min(hist.length, Sovereign.State.HistoryPos + 1);
                        this.Input.value = hist[Sovereign.State.HistoryPos] ?? '';
                        e.preventDefault();
                    }
                    if (e.key === 'Tab') {
                        e.preventDefault();
                        const partial = this.Input.value.toLowerCase();
                        const match = Object.keys(Sovereign.Commands).find(c => c.startsWith(partial));
                        if (match) this.Input.value = match;
                    }
                });
            },

            _setupHotkey() {
                window.addEventListener('keydown', e => {
                    if (e.code === 'ShiftRight') {
                        Sovereign.Visible = !Sovereign.Visible;
                        this.Main.style.display = Sovereign.Visible ? 'flex' : 'none';
                    }
                });
            },

            _setupDrag() {
                let drag = false, dx = 0, dy = 0;
                this.Header.addEventListener('mousedown', e => {
                    drag = true;
                    dx = e.clientX - this.Main.offsetLeft;
                    dy = e.clientY - this.Main.offsetTop;
                });
                window.addEventListener('mousemove', e => {
                    if (!drag) return;
                    this.Main.style.left  = (e.clientX - dx) + 'px';
                    this.Main.style.top   = (e.clientY - dy) + 'px';
                    this.Main.style.right = 'auto';
                    this.Main.style.bottom = 'auto';
                });
                window.addEventListener('mouseup', () => drag = false);
            },

            _startStatusTick() {
                setInterval(() => {
                    const statNet    = document.getElementById('sov-stat-net');
                    const statRoutes = document.getElementById('sov-stat-routes');
                    const statESP    = document.getElementById('sov-stat-esp');
                    if (statNet)    statNet.innerText    = `NET: ${Sovereign.State.NetworkLog.length}`;
                    if (statRoutes) statRoutes.innerText = `ROUTES: ${Sovereign.State.Discovery.Routes.size}`;
                    if (statESP)    statESP.innerText    = `ESP: ${Sovereign.Config.ESPEnabled ? 'ON' : 'OFF'}`;
                }, 1000);
            }
        },

        // ── HELPERS ───────────────────────────────────────────────────────────
        _trimUrl(url) {
            try { const u = new URL(url); return u.pathname + (u.search ? '?' + u.search.slice(1, 30) : ''); }
            catch (_) { return url.slice(0, 60); }
        },

        log(msg, type = 'info') {
            const entry = { text: `> ${msg}`, type };
            this.State.Logs.push(entry);
            if (!this.UI.Console) return;
            const el = document.createElement('div');
            el.className = `log-entry log-${type}`;
            el.innerText = entry.text;
            this.UI.Console.appendChild(el);
            this.UI.Console.scrollTop = this.UI.Console.scrollHeight;
        },

        Execute(val) {
            this.log(val, 'exec');
            this.State.History.push(val);
            this.State.HistoryPos = this.State.History.length;
            const parts = val.trim().split(/\s+/);
            const cmd   = parts[0].toLowerCase();
            const args  = parts.slice(1);
            if (this.Commands[cmd]) {
                try { this.Commands[cmd](args); }
                catch (e) { this.log(e.message, 'exploit'); }
            } else {
                try {
                    // Allow raw JS eval as fallback (executor-style)
                    const r = eval(val);  // jshint ignore:line
                    if (r !== undefined) this.log(String(r), 'warn');
                } catch (e) {
                    this.log(e.message, 'exploit');
                }
            }
        },

        Boot() {
            this.Networking.Initialize();
            const inject = () => {
                if (document.body || document.documentElement) {
                    this.UI.Initialize();
                    return true;
                }
                return false;
            };
            if (!inject()) {
                const obs = new MutationObserver(() => { if (inject()) obs.disconnect(); });
                obs.observe(document.documentElement, { childList: true, subtree: true });
            }
        }
    };

    Sovereign.Boot();
})();
