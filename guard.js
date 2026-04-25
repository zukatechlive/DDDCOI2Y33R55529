// ==UserScript==
// @name         Sovereign Shield
// @namespace    Callum.Architect.Shield
// @version      2.0.0
// @description  Advanced browser defense layer — multi-module threat detection, smart blocking, live HUD
// @author       Callum
// @match        *://*/*
// @run-at       document-start
// @grant        none
// ==/UserScript==

(function () {
    'use strict';

    // ═══════════════════════════════════════════════════════════════════
    //  SOVEREIGN SHIELD V2.0
    //  Modules:
    //    · Firewall         — fetch/XHR domain blocking w/ wildcard support
    //    · ScriptScanner    — miner + keylogger + obfuscation signatures
    //    · EvalGuard        — eval / Function() interception + payload scan
    //    · PopupGuard       — window.open / location hijack prevention
    //    · ClipboardGuard   — read/write clipboard intercept
    //    · FingerprintGuard — canvas/WebGL/AudioContext fingerprint spoofing
    //    · StorageGuard     — suspicious localStorage/sessionStorage writes
    //    · FormGuard        — detects forms exfiltrating to off-origin targets
    //    · BeaconGuard      — sendBeacon intercept
    //    · PageCheck        — HTTP / mixed-content / iframe sandboxing check
    //    · HUD              — sleek collapsible threat console
    // ═══════════════════════════════════════════════════════════════════

    // ── RATE LIMITER — prevents HUD spam from noisy sites ─────────────
    const _rateMap  = new Map();
    function _rateLimit(key, windowMs = 3000) {
        const now = Date.now();
        const last = _rateMap.get(key) || 0;
        if (now - last < windowMs) return true; // throttled
        _rateMap.set(key, now);
        return false;
    }

    // ── TRIE-BASED DOMAIN LOOKUP — O(k) vs O(n) linear scan ──────────
    class DomainTrie {
        constructor() { this._root = {}; }

        add(domain) {
            const parts = domain.split('.').reverse();
            let node = this._root;
            for (const p of parts) {
                if (!node[p]) node[p] = {};
                node = node[p];
            }
            node['$'] = true;
        }

        match(hostname) {
            const parts = hostname.split('.').reverse();
            let node = this._root;
            for (const p of parts) {
                if (node['$']) return true;
                if (!node[p]) return false;
                node = node[p];
            }
            return !!node['$'];
        }
    }

    const Shield = {
        Warns:   0,
        Blocked: 0,

        // ── BLOCKLIST / SUSPECTLIST ──────────────────────────────────
        Config: {
            BlockedDomains: [
                // Cryptominers
                'coinhive.com','coin-hive.com','minero.cc','cryptoloot.pro',
                'miner.pr0gramm.com','jsecoin.com','crypto-loot.com',
                'authedmine.com','monerominer.rocks','coinnebula.com',
                // Malvertising / aggressive trackers
                'doubleclick.net','googlesyndication.com','adnxs.com',
                'outbrain.com','taboola.com','revcontent.com','mgid.com',
                // Session recording (PII)
                'hotjar.com','fullstory.com','mouseflow.com',
                'logrocket.com','sessioncam.com','smartlook.com',
                'inspectlet.com','rrweb.io',
                // Known malware C2 / phishing infra
                'malware-traffic-analysis.net','fraudscore.io','evil.com',
                // Device fingerprinting SDKs
                'fingerprint.com','fingerprintjs.com','threatmetrix.com',
                'iovation.com','deviceatlas.com','seon.io',
                // Aggressive data brokers
                'data.ai','appsflyer.com','adjust.com','kochava.com',
            ],

            SuspiciousDomains: [
                'track.','tracking.','analytics.','pixel.','beacon.',
                'telemetry.','stats.','log.','metrics.','collect.',
                'event.','signal.','spy.','monitor.',
            ],

            // Script payload signatures
            MinerSignatures: [
                'CoinHive.Anonymous','CryptoLoot.Anonymous','Coinhive.User',
                'miner.start(','wasm-miner','wasmMiner','CryptoNoter',
                'minero.cc/m/','cryptonight(','cryptonight_hash',
            ],
            KeyloggerSignatures: [
                'keydown','keypress','keyup',
                'document.onkeydown','document.onkeypress',
            ],
            ObfuscationSignatures: [
                // Common obfuscation tells
                '\\x68\\x74\\x74\\x70', // "http" hex-encoded
                'atob(','btoa(',
                'String.fromCharCode(',
                'unescape(',
                '\\u0068\\u0074\\u0074\\u0070', // "http" unicode-encoded
            ],
            DangerousEvalPatterns: [
                /fetch\s*\(/,
                /XMLHttpRequest/,
                /document\.cookie/,
                /localStorage/,
                /sessionStorage/,
                /window\.location/,
                /eval\s*\(/,
            ],
        },

        // Internal fast lookup structures
        _blockedTrie: null,
        _suspiciousPatterns: [],

        _buildIndexes() {
            this._blockedTrie = new DomainTrie();
            this.Config.BlockedDomains.forEach(d => this._blockedTrie.add(d));
            this._suspiciousPatterns = this.Config.SuspiciousDomains.map(p => p);
        },

        // ── MODULE: FIREWALL ─────────────────────────────────────────
        Firewall: {
            Initialize() {
                // ── Fetch hook
                const _fetch = window.fetch;
                window.fetch = async (...args) => {
                    const url = (typeof args[0] === 'string' ? args[0] : args[0]?.url) ?? '';
                    const verdict = Shield.Firewall._check(url);
                    if (verdict === 'block') {
                        Shield._threat(`Blocked fetch → ${Shield._domain(url)}`, 'block', 'Firewall');
                        return new Response(null, { status: 0, statusText: 'Blocked by Sovereign Shield' });
                    }
                    if (verdict === 'warn') Shield._threat(`Suspicious fetch → ${Shield._domain(url)}`, 'warn', 'Firewall');
                    return _fetch.apply(window, args);
                };

                // ── XHR hook
                const _open = XMLHttpRequest.prototype.open;
                XMLHttpRequest.prototype.open = function (method, url, ...rest) {
                    const verdict = Shield.Firewall._check(String(url));
                    if (verdict === 'block') {
                        Shield._threat(`Blocked XHR → ${Shield._domain(url)}`, 'block', 'Firewall');
                        return _open.apply(this, [method, 'about:blank', ...rest]);
                    }
                    if (verdict === 'warn') Shield._threat(`Suspicious XHR → ${Shield._domain(url)}`, 'warn', 'Firewall');
                    return _open.apply(this, [method, url, ...rest]);
                };
            },

            _check(url) {
                let hostname = '';
                try { hostname = new URL(url, location.href).hostname.toLowerCase(); }
                catch (_) { return 'ok'; }
                if (!hostname) return 'ok';
                if (Shield._blockedTrie.match(hostname)) return 'block';
                if (Shield._suspiciousPatterns.some(p => hostname.includes(p))) return 'warn';
                return 'ok';
            }
        },

        // ── MODULE: SCRIPT SCANNER ───────────────────────────────────
        ScriptScanner: {
            Initialize() {
                document.addEventListener('DOMContentLoaded', () => {
                    document.querySelectorAll('script').forEach(s =>
                        Shield.ScriptScanner._scan(s.textContent, s.src || '[inline]'));
                });

                const obs = new MutationObserver(mutations => {
                    for (const mut of mutations) {
                        for (const node of mut.addedNodes) {
                            if (node.nodeType !== 1) continue;
                            if (node.tagName === 'SCRIPT') {
                                if (node.src) {
                                    if (Shield.Firewall._check(node.src) === 'block') {
                                        Shield._threat(`Blocked injected script → ${Shield._domain(node.src)}`, 'block', 'ScriptScan');
                                        node.remove(); continue;
                                    }
                                }
                                Shield.ScriptScanner._scan(node.textContent || '', node.src || '[dynamic-inline]');
                            }
                            // Also scan iframes for sandboxing
                            if (node.tagName === 'IFRAME' && !node.hasAttribute('sandbox')) {
                                Shield._threat(`Unsandboxed iframe injected: ${node.src || '[no src]'}`, 'warn', 'ScriptScan');
                            }
                        }
                    }
                });
                obs.observe(document.documentElement, { childList: true, subtree: true });
            },

            _scan(text, source) {
                if (!text || text.length < 8) return;
                const src = source.slice(0, 50);

                Shield.Config.MinerSignatures.forEach(sig => {
                    if (text.includes(sig))
                        Shield._threat(`Miner signature in script [${src}]: "${sig}"`, 'block', 'ScriptScan');
                });

                // Only warn on keyloggers — could be legitimate
                let klHits = 0;
                Shield.Config.KeyloggerSignatures.forEach(sig => { if (text.includes(sig)) klHits++; });
                if (klHits >= 2)
                    Shield._threat(`Possible keylogger pattern in [${src}] (${klHits} hits)`, 'warn', 'ScriptScan');

                // Obfuscation — only flag if multiple indicators
                let obfHits = 0;
                Shield.Config.ObfuscationSignatures.forEach(sig => { if (text.includes(sig)) obfHits++; });
                if (obfHits >= 2)
                    Shield._threat(`Heavy obfuscation detected in [${src}] (${obfHits} indicators)`, 'warn', 'ScriptScan');
            }
        },

        // ── MODULE: EVAL GUARD ───────────────────────────────────────
        EvalGuard: {
            Initialize() {
                const _eval = window.eval;
                window.eval = function (code) {
                    const str    = String(code);
                    const key    = str.slice(0, 40);
                    const danger = Shield.Config.DangerousEvalPatterns.some(r => r.test(str));
                    if (!_rateLimit('eval:' + key, 5000)) {
                        const preview = str.slice(0, 100).replace(/\n/g, ' ');
                        Shield._threat(
                            `eval() intercepted${danger ? ' [⚠ DANGEROUS PATTERN]' : ''}: ${preview}…`,
                            danger ? 'warn' : 'info',
                            'EvalGuard'
                        );
                    }
                    return _eval.apply(this, arguments);
                };

                // Also hook new Function()
                const _Function = Function;
                // eslint-disable-next-line no-global-assign
                try {
                    const _Fn = window.Function;
                    window.Function = function (...args) {
                        const body = args[args.length - 1] || '';
                        const danger = Shield.Config.DangerousEvalPatterns.some(r => r.test(body));
                        if (danger && !_rateLimit('fn:' + body.slice(0, 40), 5000))
                            Shield._threat(`new Function() with dangerous pattern: ${String(body).slice(0,80)}…`, 'warn', 'EvalGuard');
                        return _Fn(...args);
                    };
                    window.Function.prototype = _Function.prototype;
                } catch (_) {}
            }
        },

        // ── MODULE: POPUP GUARD ──────────────────────────────────────
        PopupGuard: {
            Initialize() {
                const _open = window.open;
                window.open = function (url, name, features) {
                    // Allow blank/undefined (used by legitimate apps)
                    if (!url || url === 'about:blank') return _open.apply(this, arguments);
                    Shield._threat(`Popup blocked → ${url}`, 'block', 'PopupGuard');
                    return null;
                };

                // Intercept navigation via setTimeout/requestAnimationFrame tricks
                const _setTimeout = window.setTimeout;
                window.setTimeout = function (fn, delay, ...args) {
                    if (typeof fn === 'string' && fn.includes('location')) {
                        Shield._threat(`setTimeout with location string: ${fn.slice(0,80)}`, 'warn', 'PopupGuard');
                    }
                    return _setTimeout.apply(this, [fn, delay, ...args]);
                };

                try {
                    const _assign  = window.location.assign.bind(window.location);
                    const _replace = window.location.replace.bind(window.location);
                    Object.defineProperty(window.location, 'assign', {
                        get: () => (url) => {
                            if (!_rateLimit('nav:assign', 1000))
                                Shield._threat(`location.assign → ${url}`, 'warn', 'PopupGuard');
                            _assign(url);
                        }
                    });
                    Object.defineProperty(window.location, 'replace', {
                        get: () => (url) => {
                            if (!_rateLimit('nav:replace', 1000))
                                Shield._threat(`location.replace → ${url}`, 'warn', 'PopupGuard');
                            _replace(url);
                        }
                    });
                } catch (_) {}
            }
        },

        // ── MODULE: CLIPBOARD GUARD ──────────────────────────────────
        ClipboardGuard: {
            Initialize() {
                if (navigator.clipboard?.readText) {
                    const _read = navigator.clipboard.readText.bind(navigator.clipboard);
                    navigator.clipboard.readText = function () {
                        Shield._threat('Clipboard read attempt intercepted.', 'warn', 'Clipboard');
                        return _read();
                    };
                }
                if (navigator.clipboard?.read) {
                    const _read = navigator.clipboard.read.bind(navigator.clipboard);
                    navigator.clipboard.read = function () {
                        Shield._threat('Clipboard.read() attempt intercepted.', 'warn', 'Clipboard');
                        return _read();
                    };
                }
                // Warn on unsolicited writeText (hijacking clipboard)
                if (navigator.clipboard?.writeText) {
                    const _write = navigator.clipboard.writeText.bind(navigator.clipboard);
                    navigator.clipboard.writeText = function (text) {
                        if (!_rateLimit('clipboard:write', 2000))
                            Shield._threat(`Clipboard write: "${String(text).slice(0,60)}"`, 'warn', 'Clipboard');
                        return _write(text);
                    };
                }
                document.addEventListener('copy',  () => { if (!_rateLimit('copy', 2000)) Shield._threat('copy event triggered.', 'info', 'Clipboard'); }, true);
                document.addEventListener('paste', () => { if (!_rateLimit('paste', 2000)) Shield._threat('paste event triggered.', 'info', 'Clipboard'); }, true);
            }
        },

        // ── MODULE: FINGERPRINT GUARD ────────────────────────────────
        FingerprintGuard: {
            Initialize() {
                // Canvas fingerprinting — add subtle noise so hash changes per session
                try {
                    const _toDataURL = HTMLCanvasElement.prototype.toDataURL;
                    HTMLCanvasElement.prototype.toDataURL = function (...args) {
                        Shield._fuzzCanvas(this);
                        Shield._threat('Canvas fingerprint attempt → spoofed.', 'warn', 'FPGuard');
                        return _toDataURL.apply(this, args);
                    };
                    const _getImageData = CanvasRenderingContext2D.prototype.getImageData;
                    CanvasRenderingContext2D.prototype.getImageData = function (...args) {
                        const data = _getImageData.apply(this, args);
                        // Flip a handful of low-order bits
                        for (let i = 0; i < data.data.length; i += 97) {
                            data.data[i] ^= (Math.random() * 2) | 0;
                        }
                        if (!_rateLimit('getImageData', 3000))
                            Shield._threat('getImageData fingerprint → spoofed.', 'warn', 'FPGuard');
                        return data;
                    };
                } catch (_) {}

                // AudioContext fingerprinting
                try {
                    const _AC = window.AudioContext || window.webkitAudioContext;
                    if (_AC) {
                        const _getFloat = AnalyserNode?.prototype?.getFloatFrequencyData;
                        if (_getFloat) {
                            AnalyserNode.prototype.getFloatFrequencyData = function (arr) {
                                _getFloat.apply(this, [arr]);
                                for (let i = 0; i < arr.length; i++) arr[i] += (Math.random() - 0.5) * 0.01;
                                if (!_rateLimit('audiofp', 5000))
                                    Shield._threat('AudioContext fingerprint → noise injected.', 'warn', 'FPGuard');
                            };
                        }
                    }
                } catch (_) {}
            }
        },

        // ── MODULE: STORAGE GUARD ────────────────────────────────────
        StorageGuard: {
            _SENSITIVE: [/token/i, /session/i, /auth/i, /password/i, /pass/i, /secret/i, /key/i, /credit/i, /card/i],
            Initialize() {
                ['localStorage','sessionStorage'].forEach(storeName => {
                    try {
                        const store = window[storeName];
                        const _set = store.setItem.bind(store);
                        store.setItem = function (k, v) {
                            if (Shield.StorageGuard._SENSITIVE.some(r => r.test(k) || r.test(String(v).slice(0,40)))) {
                                if (!_rateLimit(`store:${k}`, 5000))
                                    Shield._threat(`${storeName}.setItem('${k}') — possible sensitive data write.`, 'warn', 'Storage');
                            }
                            return _set(k, v);
                        };
                    } catch (_) {}
                });
            }
        },

        // ── MODULE: FORM GUARD ───────────────────────────────────────
        FormGuard: {
            Initialize() {
                document.addEventListener('submit', e => {
                    const form   = e.target;
                    const action = form?.action || '';
                    if (!action) return;
                    try {
                        const dest = new URL(action, location.href);
                        if (dest.hostname && dest.hostname !== location.hostname) {
                            Shield._threat(`Form submitting to off-origin: ${dest.hostname}`, 'warn', 'FormGuard');
                        }
                        if (Shield._blockedTrie.match(dest.hostname)) {
                            Shield._threat(`Form blocked — destination on blocklist: ${dest.hostname}`, 'block', 'FormGuard');
                            e.preventDefault();
                        }
                    } catch (_) {}
                }, true);
            }
        },

        // ── MODULE: BEACON GUARD ─────────────────────────────────────
        BeaconGuard: {
            Initialize() {
                if (!navigator.sendBeacon) return;
                const _beacon = navigator.sendBeacon.bind(navigator);
                navigator.sendBeacon = function (url, data) {
                    const verdict = Shield.Firewall._check(String(url));
                    if (verdict === 'block') {
                        Shield._threat(`sendBeacon blocked → ${Shield._domain(url)}`, 'block', 'Beacon');
                        return false;
                    }
                    if (verdict === 'warn') Shield._threat(`Suspicious beacon → ${Shield._domain(url)}`, 'warn', 'Beacon');
                    return _beacon(url, data);
                };
            }
        },

        // ── MODULE: PAGE CHECK ───────────────────────────────────────
        PageCheck: {
            Initialize() {
                if (location.protocol === 'http:' && location.hostname !== 'localhost')
                    Shield._threat(`Page over HTTP (unencrypted): ${location.hostname}`, 'warn', 'PageCheck');

                // Warn if no referrer policy
                const meta = document.querySelector('meta[name="referrer"]');
                if (!meta && document.readyState !== 'loading')
                    Shield._threat('No Referrer-Policy meta tag found.', 'info', 'PageCheck');

                // iFrame detection
                try {
                    if (window.top !== window.self)
                        Shield._threat(`Page running inside an iframe: ${document.referrer || 'unknown parent'}`, 'warn', 'PageCheck');
                } catch (_) {
                    Shield._threat('Cross-origin iframe detected (top !== self, access denied).', 'warn', 'PageCheck');
                }
            }
        },

        // ── CANVAS FUZZ HELPER ───────────────────────────────────────
        _fuzzCanvas(canvas) {
            try {
                const ctx = canvas.getContext('2d');
                if (!ctx) return;
                const pixel = ctx.getImageData(0, 0, 1, 1);
                pixel.data[0] ^= (Math.random() * 3) | 0;
                pixel.data[1] ^= (Math.random() * 3) | 0;
                ctx.putImageData(pixel, 0, 0);
            } catch (_) {}
        },

        // ── HUD ──────────────────────────────────────────────────────
        HUD: {
            el:    null,
            log:   null,
            open:  false,

            CSS: `
                @import url('https://fonts.googleapis.com/css2?family=Share+Tech+Mono&family=Rajdhani:wght@500;700&display=swap');

                :root {
                    --shld-bg:       #06090f;
                    --shld-bg2:      #0c1220;
                    --shld-border:   #1a2a40;
                    --shld-accent:   #00e5ff;
                    --shld-warn:     #ffb300;
                    --shld-block:    #ff1744;
                    --shld-info:     #455a64;
                    --shld-text:     #b0bec5;
                    --shld-glow:     rgba(0,229,255,0.12);
                    --shld-w:        400px;
                    --shld-radius:   6px;
                }

                #shld-root * { box-sizing: border-box; margin: 0; padding: 0; }

                #shld-root {
                    position: fixed;
                    bottom: 18px;
                    right: 18px;
                    width: var(--shld-w);
                    z-index: 2147483647;
                    font-family: 'Share Tech Mono', 'Consolas', monospace;
                    font-size: 11px;
                    pointer-events: none;
                }

                #shld-panel {
                    background: var(--shld-bg);
                    border: 1px solid var(--shld-border);
                    border-radius: var(--shld-radius);
                    overflow: hidden;
                    box-shadow: 0 8px 32px rgba(0,0,0,0.6), inset 0 1px 0 rgba(255,255,255,0.03);
                    pointer-events: all;
                    transition: border-color 0.3s, box-shadow 0.3s;
                }

                #shld-panel.state-warn {
                    border-color: var(--shld-warn);
                    box-shadow: 0 0 20px rgba(255,179,0,0.15), 0 8px 32px rgba(0,0,0,0.6);
                }
                #shld-panel.state-block {
                    border-color: var(--shld-block);
                    box-shadow: 0 0 24px rgba(255,23,68,0.25), 0 8px 32px rgba(0,0,0,0.6);
                }

                /* ── TOP BAR ── */
                #shld-topbar {
                    display: flex;
                    align-items: center;
                    gap: 8px;
                    padding: 7px 12px;
                    background: var(--shld-bg2);
                    border-bottom: 1px solid var(--shld-border);
                    cursor: pointer;
                    user-select: none;
                    position: relative;
                }
                #shld-topbar::after {
                    content: '';
                    position: absolute;
                    left: 0; top: 0; right: 0; bottom: 0;
                    background: linear-gradient(90deg, transparent 60%, rgba(0,229,255,0.03) 100%);
                    pointer-events: none;
                }

                #shld-icon {
                    width: 20px; height: 20px;
                    flex-shrink: 0;
                }
                #shld-icon path { transition: fill 0.3s; }

                #shld-title {
                    font-family: 'Rajdhani', sans-serif;
                    font-weight: 700;
                    font-size: 13px;
                    letter-spacing: 0.18em;
                    color: var(--shld-accent);
                    text-transform: uppercase;
                    flex: 1;
                }
                #shld-panel.state-warn  #shld-title { color: var(--shld-warn); }
                #shld-panel.state-block #shld-title { color: var(--shld-block); }

                #shld-stats {
                    display: flex;
                    gap: 6px;
                    align-items: center;
                }
                .shld-badge {
                    padding: 2px 7px;
                    border-radius: 3px;
                    font-size: 9px;
                    font-family: 'Rajdhani', sans-serif;
                    font-weight: 700;
                    letter-spacing: 0.1em;
                    text-transform: uppercase;
                }
                #shld-badge-warn  { background: rgba(255,179,0,0.12); color: var(--shld-warn); border: 1px solid rgba(255,179,0,0.3); }
                #shld-badge-block { background: rgba(255,23,68,0.12);  color: var(--shld-block); border: 1px solid rgba(255,23,68,0.3); }

                #shld-toggle {
                    color: var(--shld-info);
                    font-size: 9px;
                    letter-spacing: 0.06em;
                    transition: color 0.2s;
                }
                #shld-topbar:hover #shld-toggle { color: var(--shld-accent); }

                /* ── BODY ── */
                #shld-body {
                    max-height: 0;
                    overflow: hidden;
                    transition: max-height 0.28s cubic-bezier(0.4, 0, 0.2, 1);
                }
                #shld-root.open #shld-body { max-height: 320px; }

                /* ── TOOLBAR ── */
                #shld-toolbar {
                    display: flex;
                    gap: 4px;
                    padding: 6px 10px;
                    background: #080d16;
                    border-bottom: 1px solid var(--shld-border);
                    flex-wrap: wrap;
                }
                .shld-filter-btn {
                    padding: 2px 8px;
                    border-radius: 3px;
                    border: 1px solid var(--shld-border);
                    background: transparent;
                    color: var(--shld-info);
                    font-family: 'Share Tech Mono', monospace;
                    font-size: 9px;
                    cursor: pointer;
                    transition: all 0.15s;
                    text-transform: uppercase;
                    letter-spacing: 0.08em;
                }
                .shld-filter-btn:hover { border-color: var(--shld-accent); color: var(--shld-accent); }
                .shld-filter-btn.active { background: rgba(0,229,255,0.08); border-color: var(--shld-accent); color: var(--shld-accent); }
                .shld-filter-btn.f-warn.active   { background: rgba(255,179,0,0.08); border-color: var(--shld-warn); color: var(--shld-warn); }
                .shld-filter-btn.f-block.active  { background: rgba(255,23,68,0.08); border-color: var(--shld-block); color: var(--shld-block); }
                #shld-clear-btn {
                    margin-left: auto;
                    border-color: rgba(255,23,68,0.3);
                    color: rgba(255,23,68,0.5);
                }
                #shld-clear-btn:hover { border-color: var(--shld-block); color: var(--shld-block); background: rgba(255,23,68,0.06); }

                /* ── LOG ── */
                #shld-log {
                    max-height: 260px;
                    overflow-y: auto;
                    padding: 6px 0;
                    scrollbar-width: thin;
                    scrollbar-color: #1a2a40 transparent;
                }
                #shld-log::-webkit-scrollbar { width: 3px; }
                #shld-log::-webkit-scrollbar-thumb { background: var(--shld-border); border-radius: 2px; }

                .shld-entry {
                    display: flex;
                    align-items: flex-start;
                    gap: 8px;
                    padding: 4px 12px;
                    border-left: 2px solid transparent;
                    transition: background 0.1s;
                    animation: shld-slide-in 0.18s ease;
                    font-size: 10px;
                    line-height: 1.55;
                }
                .shld-entry:hover { background: rgba(255,255,255,0.02); }

                @keyframes shld-slide-in {
                    from { opacity: 0; transform: translateX(6px); }
                    to   { opacity: 1; transform: translateX(0); }
                }

                .shld-entry.lvl-block { border-color: var(--shld-block); }
                .shld-entry.lvl-warn  { border-color: var(--shld-warn); }
                .shld-entry.lvl-info  { border-color: var(--shld-info); }

                .shld-dot {
                    width: 5px; height: 5px;
                    border-radius: 50%;
                    flex-shrink: 0;
                    margin-top: 5px;
                }
                .lvl-block .shld-dot { background: var(--shld-block); box-shadow: 0 0 6px var(--shld-block); }
                .lvl-warn  .shld-dot { background: var(--shld-warn);  box-shadow: 0 0 6px var(--shld-warn); }
                .lvl-info  .shld-dot { background: var(--shld-info); }

                .shld-msg-wrap { flex: 1; min-width: 0; }
                .shld-mod-tag {
                    font-size: 8px;
                    letter-spacing: 0.12em;
                    color: var(--shld-info);
                    text-transform: uppercase;
                    margin-bottom: 1px;
                }
                .shld-msg {
                    color: var(--shld-text);
                    word-break: break-all;
                }
                .lvl-block .shld-msg { color: #ef9a9a; }
                .lvl-warn  .shld-msg { color: #ffe082; }

                .shld-ts {
                    font-size: 8px;
                    color: var(--shld-info);
                    flex-shrink: 0;
                    margin-top: 4px;
                    letter-spacing: 0.04em;
                }

                #shld-empty {
                    text-align: center;
                    color: var(--shld-info);
                    padding: 20px;
                    font-size: 10px;
                    letter-spacing: 0.06em;
                }

                /* ── FOOTER ── */
                #shld-footer {
                    display: flex;
                    justify-content: space-between;
                    padding: 5px 12px;
                    background: #080d16;
                    border-top: 1px solid var(--shld-border);
                    color: var(--shld-info);
                    font-size: 8px;
                    letter-spacing: 0.08em;
                }
                #shld-footer span { color: var(--shld-accent); }
            `,

            _entries: [],
            _filter:  'all',

            Initialize() {
                if (document.getElementById('shld-root')) return;

                const style = document.createElement('style');
                style.id = 'shld-style';
                style.textContent = this.CSS;
                (document.head || document.documentElement).appendChild(style);

                this.el = document.createElement('div');
                this.el.id = 'shld-root';
                this.el.innerHTML = `
                    <div id="shld-panel">
                        <div id="shld-topbar">
                            <svg id="shld-icon" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">
                                <path d="M12 2L4 6V12C4 16.418 7.582 20.344 12 22C16.418 20.344 20 16.418 20 12V6L12 2Z"
                                    fill="rgba(0,229,255,0.08)" stroke="#00e5ff" stroke-width="1.5" stroke-linejoin="round"/>
                                <path d="M9 12L11 14L15 10" stroke="#00e5ff" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round"/>
                            </svg>
                            <span id="shld-title">Sovereign Shield</span>
                            <div id="shld-stats">
                                <span class="shld-badge" id="shld-badge-warn">WARN 0</span>
                                <span class="shld-badge" id="shld-badge-block">BLOCK 0</span>
                            </div>
                            <span id="shld-toggle">▸ EXPAND</span>
                        </div>
                        <div id="shld-body">
                            <div id="shld-toolbar">
                                <button class="shld-filter-btn active" data-filter="all">ALL</button>
                                <button class="shld-filter-btn f-block" data-filter="block">BLOCKED</button>
                                <button class="shld-filter-btn f-warn"  data-filter="warn">WARNINGS</button>
                                <button class="shld-filter-btn" data-filter="Firewall">FIREWALL</button>
                                <button class="shld-filter-btn" data-filter="FPGuard">FINGERPRINT</button>
                                <button id="shld-clear-btn" class="shld-filter-btn">CLR</button>
                            </div>
                            <div id="shld-log">
                                <div id="shld-empty">No threats detected.</div>
                            </div>
                            <div id="shld-footer">
                                <span>SOVEREIGN SHIELD</span>
                                <span>v2.0.0 · <span id="shld-domain-label">${location.hostname}</span></span>
                            </div>
                        </div>
                    </div>
                `;
                (document.body || document.documentElement).appendChild(this.el);

                this.log = this.el.querySelector('#shld-log');

                // Toggle
                this.el.querySelector('#shld-topbar').addEventListener('click', () => {
                    this.open = !this.open;
                    this.el.classList.toggle('open', this.open);
                    this.el.querySelector('#shld-toggle').textContent = this.open ? '▾ COLLAPSE' : '▸ EXPAND';
                });

                // Filters
                this.el.querySelectorAll('.shld-filter-btn[data-filter]').forEach(btn => {
                    btn.addEventListener('click', e => {
                        e.stopPropagation();
                        this.el.querySelectorAll('.shld-filter-btn[data-filter]').forEach(b => b.classList.remove('active'));
                        btn.classList.add('active');
                        this._filter = btn.dataset.filter;
                        this._render();
                    });
                });

                // Clear
                this.el.querySelector('#shld-clear-btn').addEventListener('click', e => {
                    e.stopPropagation();
                    this._entries = [];
                    Shield.Warns   = 0;
                    Shield.Blocked = 0;
                    this._render();
                    this.Update();
                });

                Shield._hudReady = true;
                Shield._queue.forEach(q => Shield.HUD._push(q));
                Shield._queue = [];
            },

            _push(entry) {
                this._entries.push(entry);
                if (this._entries.length > 200) this._entries.shift();

                const empty = this.log?.querySelector('#shld-empty');
                if (empty) empty.remove();

                const show =
                    this._filter === 'all' ||
                    this._filter === entry.level ||
                    this._filter === entry.mod;

                if (show && this.log) {
                    const el = this._makeEl(entry);
                    this.log.appendChild(el);
                    if (this.open) this.log.scrollTop = this.log.scrollHeight;
                }
            },

            _makeEl(entry) {
                const el = document.createElement('div');
                el.className = `shld-entry lvl-${entry.level}`;
                el.dataset.level = entry.level;
                el.dataset.mod   = entry.mod;
                el.innerHTML = `
                    <div class="shld-dot"></div>
                    <div class="shld-msg-wrap">
                        <div class="shld-mod-tag">${entry.mod}</div>
                        <div class="shld-msg">${entry.msg.replace(/</g,'&lt;')}</div>
                    </div>
                    <div class="shld-ts">${entry.ts}</div>
                `;
                return el;
            },

            _render() {
                if (!this.log) return;
                this.log.innerHTML = '';
                const filtered = this._entries.filter(e =>
                    this._filter === 'all' ||
                    this._filter === e.level ||
                    this._filter === e.mod
                );
                if (filtered.length === 0) {
                    this.log.innerHTML = '<div id="shld-empty">No entries for this filter.</div>';
                    return;
                }
                const frag = document.createDocumentFragment();
                filtered.forEach(e => frag.appendChild(this._makeEl(e)));
                this.log.appendChild(frag);
                this.log.scrollTop = this.log.scrollHeight;
            },

            Update() {
                if (!this.el) return;
                const wBadge = this.el.querySelector('#shld-badge-warn');
                const bBadge = this.el.querySelector('#shld-badge-block');
                if (wBadge)  wBadge.textContent  = `WARN ${Shield.Warns}`;
                if (bBadge)  bBadge.textContent  = `BLOCK ${Shield.Blocked}`;

                const panel = this.el.querySelector('#shld-panel');
                if (!panel) return;
                panel.classList.remove('state-warn', 'state-block');
                if (Shield.Blocked > 0)       panel.classList.add('state-block');
                else if (Shield.Warns   > 0)  panel.classList.add('state-warn');

                // Update shield icon stroke color
                const paths = this.el.querySelectorAll('#shld-icon path');
                const color = Shield.Blocked > 0 ? '#ff1744' : Shield.Warns > 0 ? '#ffb300' : '#00e5ff';
                paths.forEach(p => { p.style.stroke = color; });
            }
        },

        // ── CORE INTERNALS ───────────────────────────────────────────
        _hudReady: false,
        _queue:    [],

        _threat(msg, level = 'warn', mod = 'Shield') {
            if (level === 'block') this.Blocked++;
            else if (level !== 'info') this.Warns++;

            const ts    = new Date().toLocaleTimeString();
            const entry = { msg, level, mod, ts };

            console[level === 'block' ? 'error' : level === 'warn' ? 'warn' : 'log'](
                `%c[SovereignShield/${mod}] ${msg}`,
                `color:${level==='block'?'#ff1744':level==='warn'?'#ffb300':'#546e7a'}`
            );

            if (this._hudReady) {
                this.HUD._push(entry);
            } else {
                this._queue.push(entry);
            }
            this.HUD.Update();
        },

        _domain(url) {
            try { return new URL(url, location.href).hostname; }
            catch (_) { return url.slice(0, 50); }
        },

        // ── BOOT ─────────────────────────────────────────────────────
        Boot() {
            this._buildIndexes();

            this.Firewall.Initialize();
            this.BeaconGuard.Initialize();
            this.ScriptScanner.Initialize();
            this.EvalGuard.Initialize();
            this.PopupGuard.Initialize();
            this.ClipboardGuard.Initialize();
            this.FingerprintGuard.Initialize();
            this.StorageGuard.Initialize();
            this.FormGuard.Initialize();
            this.PageCheck.Initialize();

            const tryInject = () => {
                if (document.body || document.documentElement) {
                    this.HUD.Initialize();
                    return true;
                }
                return false;
            };

            if (!tryInject()) {
                const obs = new MutationObserver(() => { if (tryInject()) obs.disconnect(); });
                obs.observe(document.documentElement, { childList: true, subtree: true });
            }
        }
    };

    Shield.Boot();

})();
