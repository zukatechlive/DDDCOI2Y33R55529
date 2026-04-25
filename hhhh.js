// ==UserScript==
// @name         VANTAGE // Red Team Audit Toolkit
// @namespace    redteam.audit.vantage
// @version      1.0.0
// @description  Authorized web application security auditing toolkit. Network logging, token inspection, storage analysis, endpoint harvesting, and recon utilities.
// @author       Private Build
// @match        *://*/*
// @run-at       document-start
// @grant        GM_setClipboard
// @grant        GM_notification
// ==/UserScript==

(function () {
    'use strict';

    // ─────────────────────────────────────────────
    //  VANTAGE — Red Team Audit Toolkit
    //  For use only on systems you own or have
    //  explicit written authorization to test.
    // ─────────────────────────────────────────────

    const VT = {

        // ── Config ────────────────────────────────
        Config: {
            SensitiveKeywords: [
                'token', 'auth', 'secret', 'key', 'password', 'passwd', 'credential',
                'api_key', 'apikey', 'bearer', 'session', 'jwt', 'oauth', 'access_token',
                'refresh_token', 'private', 'admin', 'role', 'permission', 'isStaff',
                'userType', 'priv', 'ssn', 'credit_card', 'cvv', 'account'
            ],
            MaxPreviewLen: 800,
            MaxLogs: 500,
            // Known browser-native window properties to skip in globals scan
            GlobalsBlocklist: new Set([
                'onkeydown','onkeypress','onkeyup','onkeydown','onclick','ondblclick',
                'onmousedown','onmouseup','onmousemove','onmouseover','onmouseout',
                'onmouseenter','onmouseleave','oncontextmenu','onwheel',
                'onpointerdown','onpointerup','onpointermove','onpointerover',
                'onpointerout','onpointerenter','onpointerleave','onpointercancel',
                'ontouchstart','ontouchmove','ontouchend','ontouchcancel',
                'onfocus','onblur','onchange','oninput','oninvalid','onreset',
                'onselect','onsubmit','onabort','oncancel','oncanplay',
                'oncanplaythrough','oncuechange','ondurationchange','onemptied',
                'onended','onerror','onloadeddata','onloadedmetadata','onloadstart',
                'onpause','onplay','onplaying','onprogress','onratechange',
                'onseeked','onseeking','onstalled','onsuspend','ontimeupdate',
                'onvolumechange','onwaiting','onload','onunload','onbeforeunload',
                'onhashchange','onpopstate','onpagehide','onpageshow',
                'onresize','onscroll','onscrollend','onstorage','onoffline','ononline',
                'onmessage','onmessageerror','onclose','onopen',
                'ondevicemotion','ondeviceorientation','ondeviceorientationabsolute',
                'sessionStorage','localStorage','location','history','navigation',
                'document','window','self','top','parent','frames','opener','closed',
                'screen','screenX','screenY','screenLeft','screenTop',
                'outerWidth','outerHeight','innerWidth','innerHeight',
                'scrollX','scrollY','pageXOffset','pageYOffset',
                'devicePixelRatio','visualViewport',
                'performance','crypto','indexedDB','caches','cookieStore',
                'credentialless','crossOriginIsolated','isSecureContext',
                'originAgentCluster','scheduler','trustedTypes',
                'speechSynthesis','speechRecognition',
                'Notification','Permissions','PushManager',
                'customElements','external','toolbar','menubar','statusbar',
                'personalbar','scrollbars','locationbar',
                'name','status','length','frameElement','origin',
                'clientInformation','navigator','console',
                'alert','confirm','prompt','print','open','close','stop','focus','blur',
                'scroll','scrollTo','scrollBy','resizeTo','resizeBy','moveTo','moveBy',
                'requestAnimationFrame','cancelAnimationFrame',
                'requestIdleCallback','cancelIdleCallback',
                'setTimeout','setInterval','clearTimeout','clearInterval',
                'queueMicrotask','structuredClone','reportError',
                'fetch','XMLHttpRequest','WebSocket','EventSource',
                'atob','btoa','escape','unescape','encodeURI','encodeURIComponent',
                'decodeURI','decodeURIComponent','eval','isFinite','isNaN',
                'parseFloat','parseInt','undefined','Infinity','NaN',
                'Object','Function','Array','String','Number','Boolean','Symbol','BigInt',
                'Math','Date','RegExp','Error','Map','Set','WeakMap','WeakSet','WeakRef',
                'Promise','Proxy','Reflect','JSON','globalThis',
                'ArrayBuffer','SharedArrayBuffer','DataView','Atomics',
                'Int8Array','Uint8Array','Uint8ClampedArray','Int16Array','Uint16Array',
                'Int32Array','Uint32Array','Float32Array','Float64Array',
                'BigInt64Array','BigUint64Array',
                'URL','URLSearchParams','Blob','File','FileReader','FileList',
                'FormData','Headers','Request','Response','ReadableStream',
                'WritableStream','TransformStream','TextEncoder','TextDecoder',
                'MutationObserver','IntersectionObserver','ResizeObserver',
                'PerformanceObserver','ReportingObserver',
                'HTMLElement','Element','Node','NodeList','Document','DocumentFragment',
                'Event','CustomEvent','AbortController','AbortSignal',
                'ImageData','ImageBitmap','OffscreenCanvas','Path2D',
                'Worker','ServiceWorker','BroadcastChannel','MessageChannel',
                'IDBFactory','IDBDatabase','IDBTransaction',
                'Cache','CacheStorage','SubtleCrypto','CryptoKey',
                'getComputedStyle','matchMedia','getSelection',
                'postMessage','addEventListener','removeEventListener','dispatchEvent',
            ])
        },

        // ── State ─────────────────────────────────
        State: {
            Logs: [],
            NetworkLog: [],
            Findings: [],
            History: [],
            HistoryPos: -1,
            Visible: true,
            ActiveTab: 'console',
            LinkMap: null,
            WatchList: []
        },

        // ── Utility ───────────────────────────────
        Utils: {
            trimUrl(url, len = 60) {
                try { const u = new URL(url); return (u.pathname + u.search).slice(0, len); }
                catch (_) { return String(url).slice(0, len); }
            },
            ts() {
                return new Date().toTimeString().slice(0, 8);
            },
            flagSensitive(text) {
                if (!text) return null;
                const lower = text.toLowerCase();
                return VT.Config.SensitiveKeywords.find(kw => lower.includes(kw)) || null;
            },
            decodeJWT(token) {
                try {
                    const parts = token.split('.');
                    if (parts.length !== 3) return null;
                    const decode = p => JSON.parse(atob(p.replace(/-/g, '+').replace(/_/g, '/')));
                    return { header: decode(parts[0]), payload: decode(parts[1]) };
                } catch (_) { return null; }
            },
            findJWTs(text) {
                const re = /eyJ[A-Za-z0-9_-]+\.eyJ[A-Za-z0-9_-]+\.[A-Za-z0-9_-]+/g;
                return [...new Set(text.match(re) || [])];
            },
            formatJSON(obj) {
                try { return JSON.stringify(obj, null, 2); } catch (_) { return String(obj); }
            },
            copyToClip(text) {
                try { GM_setClipboard(text); VT.log('Copied to clipboard.', 'ok'); }
                catch (_) {
                    navigator.clipboard?.writeText(text)
                        .then(() => VT.log('Copied to clipboard.', 'ok'))
                        .catch(() => VT.log('Clipboard copy failed.', 'warn'));
                }
            },

            // ── JWT weak-secret wordlist (client-side HMAC brute)
            JWTWordlist: [
                'secret','password','123456','12345678','qwerty','abc123','letmein',
                'welcome','monkey','dragon','master','pass','test','admin','root',
                'toor','alpine','changeme','default','hunter2','iloveyou','sunshine',
                'princess','shadow','superman','michael','football','charlie','donald',
                'aa123456','password1','hello','trustno1','jwt','jwtSecret','jwt_secret',
                'your-256-bit-secret','your-secret','supersecret','mysecret','secretkey',
                'secret_key','app_secret','api_secret','token_secret','auth_secret',
                'private_key','privatekey','signing_key','signingkey','hmac_secret',
                'development','production','staging','local','debug','app','webapp',
                'node','express','rails','laravel','django','flask','spring',
            ],

            async crackJWT(token) {
                const parts = token.split('.');
                if (parts.length !== 3) return null;
                const header = JSON.parse(atob(parts[0].replace(/-/g,'+').replace(/_/g,'/')));
                if (!header.alg || !header.alg.startsWith('HS')) {
                    return { error: `Algorithm ${header.alg} cannot be cracked client-side (not HMAC)` };
                }
                const algMap = { HS256: 'SHA-256', HS384: 'SHA-384', HS512: 'SHA-512' };
                const hashAlg = algMap[header.alg];
                if (!hashAlg) return { error: `Unsupported algorithm: ${header.alg}` };

                const encoder = new TextEncoder();
                const sigInput = encoder.encode(`${parts[0]}.${parts[1]}`);

                // Decode expected signature
                const sigB64 = parts[2].replace(/-/g,'+').replace(/_/g,'/');
                const expectedSig = Uint8Array.from(atob(sigB64), c => c.charCodeAt(0));

                // Also append hostname as a candidate
                const candidates = [...VT.Utils.JWTWordlist, location.hostname, location.hostname.split('.')[0]];

                for (const candidate of candidates) {
                    try {
                        const keyMaterial = await crypto.subtle.importKey(
                            'raw', encoder.encode(candidate),
                            { name: 'HMAC', hash: hashAlg },
                            false, ['sign']
                        );
                        const sig = new Uint8Array(await crypto.subtle.sign('HMAC', keyMaterial, sigInput));
                        if (sig.length === expectedSig.length && sig.every((b, i) => b === expectedSig[i])) {
                            return { cracked: true, secret: candidate };
                        }
                    } catch (_) {}
                }
                return { cracked: false };
            },

            // Parse Set-Cookie header string into attribute map
            parseCookieHeader(raw) {
                const parts = raw.split(';').map(s => s.trim());
                const [nameVal, ...attrs] = parts;
                const attrMap = {};
                attrs.forEach(a => {
                    const [k, v] = a.split('=');
                    attrMap[k.trim().toLowerCase()] = v?.trim() ?? true;
                });
                return { nameVal, attrs: attrMap };
            }
        },

        // ── Network Hooks ─────────────────────────
        Net: {
            Initialize() {
                // ── Fetch Hook
                const rawFetch = window.fetch;
                window.fetch = async (...args) => {
                    const url  = (typeof args[0] === 'string' ? args[0] : args[0]?.url) ?? '?';
                    const method = args[1]?.method?.toUpperCase() ?? 'GET';
                    const reqBody = args[1]?.body ? String(args[1].body).slice(0, 500) : null;

                    const entry = {
                        type: 'fetch', method, url,
                        time: VT.Utils.ts(), reqBody,
                        status: null, preview: null, flags: []
                    };
                    VT.State.NetworkLog.push(entry);
                    VT.log(`[FETCH] ${method} ${VT.Utils.trimUrl(url)}`, 'net');

                    // ── Sniff outbound auth headers
                    const reqHeaders = args[1]?.headers;
                    if (reqHeaders) {
                        const hObj = reqHeaders instanceof Headers ? Object.fromEntries(reqHeaders.entries()) : reqHeaders;
                        const authVal = hObj['authorization'] || hObj['Authorization'] || hObj['x-auth-token'] || hObj['X-Auth-Token'] || hObj['x-api-key'] || hObj['X-Api-Key'];
                        if (authVal) {
                            entry.authHeader = authVal.slice(0, 120);
                            VT.log(`  [AUTH HEADER] ${authVal.slice(0, 80)}`, 'flag');
                            VT.State.Findings.push({ type: 'auth_header_observed', value: authVal.slice(0,120), url, time: entry.time });
                            const jwts = VT.Utils.findJWTs(authVal);
                            jwts.forEach(jwt => {
                                VT.log(`  [JWT IN HEADER] ${jwt.slice(0,50)}...`, 'flag');
                                const dec = VT.Utils.decodeJWT(jwt);
                                if (dec) {
                                    const now = Math.floor(Date.now()/1000);
                                    VT.log(`    alg:${dec.header.alg}  sub:${dec.payload.sub||'?'}  ${dec.payload.exp ? (dec.payload.exp < now ? 'EXPIRED' : `ttl:${dec.payload.exp-now}s`) : 'no-exp'}`, 'data');
                                }
                                VT.State.Findings.push({ type: 'jwt_in_auth_header', token: jwt, url, time: entry.time });
                            });
                        }
                    }

                    const response = await rawFetch.apply(window, args);
                    entry.status = response.status;

                    response.clone().text().then(body => {
                        entry.preview = body.slice(0, VT.Config.MaxPreviewLen);

                        // Watchlist
                        if (VT.State.WatchList?.length) {
                            VT.State.WatchList.forEach(kw => {
                                if (body.toLowerCase().includes(kw.toLowerCase())) {
                                    VT.log(`[WATCH] "${kw}" hit in response: ${VT.Utils.trimUrl(url)}`, 'flag');
                                    VT.State.Findings.push({ type: 'watch_hit', keyword: kw, url, time: entry.time });
                                }
                            });
                        }

                        // Check for sensitive data
                        const flag = VT.Utils.flagSensitive(body);
                        if (flag) {
                            entry.flags.push(flag);
                            VT.log(`[!!] SENSITIVE KEYWORD "${flag}" in response: ${VT.Utils.trimUrl(url)}`, 'flag');
                            VT.State.Findings.push({ type: 'response_keyword', keyword: flag, url, time: entry.time });
                        }

                        // Check for JWTs in response
                        const jwts = VT.Utils.findJWTs(body);
                        jwts.forEach(jwt => {
                            VT.log(`[JWT] Token found in response: ${jwt.slice(0, 40)}...`, 'flag');
                            VT.State.Findings.push({ type: 'jwt_in_response', token: jwt, url, time: entry.time });
                        });

                        // Status flags
                        if (response.status === 401 || response.status === 403) {
                            VT.log(`[AUTH] ${response.status} on ${VT.Utils.trimUrl(url)}`, 'warn');
                        } else if (response.status >= 500) {
                            VT.log(`[ERR] ${response.status} — possible info leak: ${VT.Utils.trimUrl(url)}`, 'warn');
                        }

                        // ── Set-Cookie flag audit
                        const setCookie = response.headers.get('set-cookie');
                        if (setCookie) {
                            const { nameVal, attrs } = VT.Utils.parseCookieHeader(setCookie);
                            VT.log(`  [SET-COOKIE] ${nameVal}`, 'data');
                            if (!attrs['httponly']) {
                                VT.log(`    [!!] Missing HttpOnly — readable via JS (XSS risk)`, 'flag');
                                VT.State.Findings.push({ type: 'cookie_missing_httponly', cookie: nameVal, url, time: entry.time });
                            }
                            if (!attrs['secure']) {
                                VT.log(`    [!!] Missing Secure — transmitted over HTTP`, 'flag');
                                VT.State.Findings.push({ type: 'cookie_missing_secure', cookie: nameVal, url, time: entry.time });
                            }
                            if (!attrs['samesite']) {
                                VT.log(`    [WARN] Missing SameSite — CSRF risk`, 'warn');
                                VT.State.Findings.push({ type: 'cookie_missing_samesite', cookie: nameVal, url, time: entry.time });
                            } else if (attrs['samesite'] === 'none' && !attrs['secure']) {
                                VT.log(`    [!!] SameSite=None without Secure is invalid and insecure`, 'flag');
                            }
                            if (attrs['httponly'] && attrs['secure'] && attrs['samesite']) {
                                VT.log(`    [✓] All security flags present`, 'ok');
                            }
                        }

                    }).catch(() => {});

                    return response;
                };

                // ── XHR Hook
                const rawOpen = XMLHttpRequest.prototype.open;
                const rawSend = XMLHttpRequest.prototype.send;

                XMLHttpRequest.prototype.open = function (method, url, ...rest) {
                    this._vt = { method: method.toUpperCase(), url, time: VT.Utils.ts() };
                    return rawOpen.apply(this, [method, url, ...rest]);
                };

                XMLHttpRequest.prototype.send = function (body) {
                    if (this._vt) {
                        const entry = {
                            type: 'xhr', ...this._vt,
                            reqBody: body ? String(body).slice(0, 500) : null,
                            status: null, preview: null, flags: []
                        };
                        VT.State.NetworkLog.push(entry);
                        VT.log(`[XHR]  ${this._vt.method} ${VT.Utils.trimUrl(this._vt.url)}`, 'net');

                        this.addEventListener('load', () => {
                            entry.status = this.status;
                            const text = this.responseText ?? '';
                            entry.preview = text.slice(0, VT.Config.MaxPreviewLen);

                            if (VT.State.WatchList?.length) {
                                VT.State.WatchList.forEach(kw => {
                                    if (text.toLowerCase().includes(kw.toLowerCase())) {
                                        VT.log(`[WATCH] "${kw}" hit in XHR: ${VT.Utils.trimUrl(this._vt.url)}`, 'flag');
                                        VT.State.Findings.push({ type: 'watch_hit', keyword: kw, url: this._vt.url, time: entry.time });
                                    }
                                });
                            }

                            const flag = VT.Utils.flagSensitive(text);
                            if (flag) {
                                entry.flags.push(flag);
                                VT.log(`[!!] SENSITIVE KEYWORD "${flag}" in XHR response: ${VT.Utils.trimUrl(this._vt.url)}`, 'flag');
                                VT.State.Findings.push({ type: 'xhr_keyword', keyword: flag, url: this._vt.url, time: entry.time });
                            }

                            const jwts = VT.Utils.findJWTs(text);
                            jwts.forEach(jwt => {
                                VT.log(`[JWT] Token found in XHR: ${jwt.slice(0, 40)}...`, 'flag');
                            });
                        });
                    }
                    return rawSend.apply(this, arguments);
                };

                VT.log('Network hooks active (fetch + XHR).', 'ok');
            }
        },

        // ── Recon Modules ─────────────────────────
        Recon: {
            ScanRoutes() {
                VT.log('── Endpoint Harvest ──────────────────', 'section');
                const patterns = [
                    /["'`](\/[a-zA-Z0-9_\-/.]*(?:api|admin|v\d|auth|config|internal|dashboard|graphql|rpc|ws|socket)[a-zA-Z0-9_\-/.]*)["'`]/gi,
                    /["'`](https?:\/\/[a-zA-Z0-9._-]+\/[a-zA-Z0-9_\-/.?=&]*)["'`]/gi
                ];
                const found = new Set();
                document.querySelectorAll('script').forEach(s => {
                    const src = s.innerText || '';
                    patterns.forEach(pat => {
                        let m;
                        while ((m = pat.exec(src)) !== null) {
                            if (!found.has(m[1])) {
                                found.add(m[1]);
                                VT.log(`  ENDPOINT  ${m[1]}`, 'data');
                            }
                        }
                    });
                });
                VT.log(`  Total: ${found.size} endpoint(s) found.`, 'ok');
                return [...found];
            },

            ScanGlobals() {
                VT.log('── Window Globals Scan ───────────────', 'section');
                const kw      = VT.Config.SensitiveKeywords;
                const blocked = VT.Config.GlobalsBlocklist;
                let count = 0;
                for (const prop in window) {
                    try {
                        if (blocked.has(prop)) continue;
                        if (!kw.some(k => prop.toLowerCase().includes(k))) continue;
                        if (typeof window[prop] === 'function') continue;
                        const raw = window[prop];
                        if (raw === null || raw === undefined || raw === '') continue;
                        // Skip empty objects/arrays
                        if (typeof raw === 'object' && Object.keys(raw).length === 0) continue;
                        const val = JSON.stringify(raw)?.slice(0, 150) ?? String(raw);
                        VT.log(`  window.${prop} = ${val}`, 'data');
                        VT.State.Findings.push({ type: 'global_var', key: prop, value: val, time: VT.Utils.ts() });
                        count++;
                    } catch (_) {}
                }
                if (count === 0) VT.log('  No suspicious globals found.', 'info');
                else VT.log(`  Total: ${count} sensitive global(s) found.`, 'ok');
                return count;
            },

            ScanStorage() {
                VT.log('── Storage & Token Audit ─────────────', 'section');

                // ── Helper: inspect a value for JWT / bearer tokens
                const inspectValue = (source, key, val) => {
                    if (!val) return;
                    const jwts = VT.Utils.findJWTs(val);
                    jwts.forEach(jwt => {
                        VT.log(`  [JWT FOUND] ${source}["${key}"] → ${jwt.slice(0,50)}...`, 'flag');
                        VT.State.Findings.push({ type: 'jwt_in_storage', source, key, token: jwt, time: VT.Utils.ts() });
                        const decoded = VT.Utils.decodeJWT(jwt);
                        if (decoded) {
                            const now = Math.floor(Date.now() / 1000);
                            const exp = decoded.payload.exp;
                            const alg = decoded.header.alg;
                            const sub = decoded.payload.sub || decoded.payload.userId || decoded.payload.id || '?';
                            const role = decoded.payload.role || decoded.payload.roles || decoded.payload.scope || null;
                            VT.log(`    alg:${alg}  sub:${sub}  ${exp ? (exp < now ? 'EXPIRED' : `ttl:${exp-now}s`) : 'no-exp'}${role ? `  role:${JSON.stringify(role)}` : ''}`, alg === 'none' || !exp ? 'flag' : 'data');
                        }
                    });
                    // Also flag raw bearer-looking values
                    if (!jwts.length && /^(Bearer\s+)?[A-Za-z0-9\-_]{20,}$/.test(val.trim()) && VT.Config.SensitiveKeywords.some(k => key.toLowerCase().includes(k))) {
                        VT.log(`  [TOKEN?] ${source}["${key}"] = ${val.slice(0,80)}`, 'warn');
                        VT.State.Findings.push({ type: 'possible_token_in_storage', source, key, value: val.slice(0,80), time: VT.Utils.ts() });
                    }
                };

                // ── Cookies (document.cookie only shows non-HttpOnly)
                VT.log('  ── Cookies ──────────────────────────', 'section');
                const cookies = document.cookie.split(';').map(c => c.trim()).filter(Boolean);
                if (cookies.length) {
                    cookies.forEach(c => {
                        VT.log(`    ${c}`, 'data');
                        const [name, val] = c.split('=');
                        if (val) inspectValue('cookie', name.trim(), decodeURIComponent(val.trim()));
                    });
                    VT.log(`  Note: HttpOnly cookies are not readable here — check DevTools Application tab.`, 'info');
                } else {
                    VT.log('  No accessible cookies (all may be HttpOnly).', 'info');
                }

                // ── LocalStorage
                VT.log('  ── LocalStorage ─────────────────────', 'section');
                try {
                    const lsKeys = Object.keys(localStorage);
                    if (lsKeys.length) {
                        lsKeys.forEach(k => {
                            const v = localStorage.getItem(k);
                            VT.log(`    [${k}]: ${v?.slice(0, 120)}`, 'data');
                            inspectValue('localStorage', k, v);
                        });
                    } else { VT.log('  LocalStorage empty.', 'info'); }
                } catch (_) { VT.log('  LocalStorage access denied.', 'warn'); }

                // ── SessionStorage
                VT.log('  ── SessionStorage ───────────────────', 'section');
                try {
                    const ssKeys = Object.keys(sessionStorage);
                    if (ssKeys.length) {
                        ssKeys.forEach(k => {
                            const v = sessionStorage.getItem(k);
                            VT.log(`    [${k}]: ${v?.slice(0, 120)}`, 'data');
                            inspectValue('sessionStorage', k, v);
                        });
                    } else { VT.log('  SessionStorage empty.', 'info'); }
                } catch (_) { VT.log('  SessionStorage access denied.', 'warn'); }
            },

            ScanCSP() {
                VT.log('── CSP & Security Headers ────────────', 'section');
                const metas = document.querySelectorAll('meta[http-equiv]');
                let found = false;
                metas.forEach(m => {
                    const name = m.getAttribute('http-equiv') || '';
                    if (name.toLowerCase().includes('content-security-policy')) {
                        VT.log(`  CSP (meta): ${m.getAttribute('content')?.slice(0, 200)}`, 'data');
                        found = true;
                    }
                });
                if (!found) VT.log('  No CSP meta tag found (check response headers separately).', 'warn');
            },

            ScanForms() {
                VT.log('── Form & Input Enumeration ──────────', 'section');
                const forms = document.querySelectorAll('form');
                if (!forms.length) { VT.log('  No forms found.', 'info'); return; }
                forms.forEach((form, i) => {
                    const action = form.action || '(none)';
                    const method = form.method?.toUpperCase() || 'GET';
                    VT.log(`  Form[${i}] ${method} → ${action}`, 'data');
                    form.querySelectorAll('input, textarea, select').forEach(el => {
                        VT.log(`    <${el.tagName.toLowerCase()}> name="${el.name}" type="${el.type || '-'}"`, 'info');
                    });
                });
            },

            ScanScripts() {
                VT.log('── Inline Scripts & Src Audit ────────', 'section');
                document.querySelectorAll('script[src]').forEach(s => {
                    VT.log(`  [EXT] ${s.src}`, 'data');
                });
                VT.log(`  ${document.querySelectorAll('script:not([src])').length} inline script block(s).`, 'info');
            },

            ScanMeta() {
                VT.log('── Meta Tag Harvest ──────────────────', 'section');
                const interesting = new Set([
                    'csrf','token','_token','verification','generator','version',
                    'build','application','app','framework','author','keywords',
                    'robots','referrer','content-security-policy','x-ua-compatible'
                ]);
                let count = 0;
                document.querySelectorAll('meta').forEach(m => {
                    const name    = (m.name || m.httpEquiv || m.getAttribute('property') || '').toLowerCase();
                    const content = m.content || m.getAttribute('content') || '';
                    if (!name && !content) return;
                    const hit = interesting.has(name) || VT.Config.SensitiveKeywords.some(k => name.includes(k) || content.toLowerCase().includes(k));
                    if (hit) {
                        VT.log(`  [META] ${name || '(unnamed)'} = ${content.slice(0, 150)}`, 'data');
                        if (VT.Config.SensitiveKeywords.some(k => name.includes(k) || content.toLowerCase().includes(k))) {
                            VT.State.Findings.push({ type: 'meta_sensitive', name, content: content.slice(0, 150), time: VT.Utils.ts() });
                        }
                        count++;
                    }
                });
                if (count === 0) VT.log('  No interesting meta tags found.', 'info');
                else VT.log(`  ${count} interesting meta tag(s) found.`, 'ok');
            },

            ScanComments() {
                VT.log('── Comment Scraper ───────────────────', 'section');
                const sensitive = /todo|fixme|hack|bug|password|passwd|secret|key|token|auth|api|internal|remove|temp|debug|test|credentials|private|note|xxx/i;
                let count = 0;

                // HTML comments
                const walker = document.createTreeWalker(document.documentElement, NodeFilter.SHOW_COMMENT);
                let node;
                while ((node = walker.nextNode())) {
                    const text = node.nodeValue.trim();
                    if (text.length < 3) continue;
                    if (sensitive.test(text)) {
                        VT.log(`  [HTML COMMENT] ${text.slice(0, 200)}`, 'flag');
                        VT.State.Findings.push({ type: 'comment_sensitive', source: 'html', text: text.slice(0, 200), time: VT.Utils.ts() });
                        count++;
                    } else {
                        VT.log(`  [HTML COMMENT] ${text.slice(0, 120)}`, 'data');
                        count++;
                    }
                }

                // JS block/line comments in inline scripts
                const jsCommentRe = /\/\*[\s\S]*?\*\/|\/\/.+/g;
                document.querySelectorAll('script:not([src])').forEach((s, si) => {
                    let m;
                    while ((m = jsCommentRe.exec(s.innerText)) !== null) {
                        const text = m[0].replace(/^\/\/\s*|^\/\*|\*\/$/g, '').trim();
                        if (text.length < 4) continue;
                        if (sensitive.test(text)) {
                            VT.log(`  [JS COMMENT #${si}] ${text.slice(0, 200)}`, 'flag');
                            VT.State.Findings.push({ type: 'comment_sensitive', source: `inline_script_${si}`, text: text.slice(0, 200), time: VT.Utils.ts() });
                            count++;
                        }
                    }
                });

                if (count === 0) VT.log('  No comments found.', 'info');
                else VT.log(`  ${count} comment(s) scanned.`, 'ok');
            },

            async ScanHeaders() {
                VT.log('── Response Header Audit ─────────────', 'section');
                const securityHeaders = [
                    'content-security-policy','strict-transport-security',
                    'x-frame-options','x-content-type-options','referrer-policy',
                    'permissions-policy','cross-origin-opener-policy',
                    'cross-origin-embedder-policy','cross-origin-resource-policy',
                    'cache-control','pragma'
                ];
                const infoLeakHeaders = [
                    'server','x-powered-by','x-aspnet-version','x-aspnetmvc-version',
                    'x-generator','x-drupal-cache','x-wp-total','x-runtime',
                    'x-request-id','x-correlation-id','via','x-cache','x-varnish',
                    'x-amz-cf-id','x-amzn-requestid','cf-ray'
                ];
                try {
                    const res = await fetch(location.href, { method: 'HEAD', credentials: 'include' });
                    VT.log(`  Status: ${res.status} ${res.statusText}`, res.ok ? 'ok' : 'warn');

                    // Info-leak headers
                    VT.log('  ── Info-Leak Headers:', 'section');
                    let leaks = 0;
                    infoLeakHeaders.forEach(h => {
                        const v = res.headers.get(h);
                        if (v) {
                            VT.log(`  [!!] ${h}: ${v}`, 'flag');
                            VT.State.Findings.push({ type: 'header_info_leak', header: h, value: v, time: VT.Utils.ts() });
                            leaks++;
                        }
                    });
                    if (leaks === 0) VT.log('  No info-leak headers found.', 'ok');

                    // Security headers — flag missing ones
                    VT.log('  ── Security Headers:', 'section');
                    securityHeaders.forEach(h => {
                        const v = res.headers.get(h);
                        if (v) VT.log(`  [✓] ${h}: ${v.slice(0, 100)}`, 'ok');
                        else {
                            VT.log(`  [✗] MISSING: ${h}`, 'warn');
                            VT.State.Findings.push({ type: 'missing_security_header', header: h, time: VT.Utils.ts() });
                        }
                    });

                    // CORS header
                    const cors = res.headers.get('access-control-allow-origin');
                    if (cors) {
                        const severity = cors === '*' ? 'flag' : 'warn';
                        VT.log(`  [CORS] access-control-allow-origin: ${cors}`, severity);
                        if (cors === '*') VT.State.Findings.push({ type: 'cors_wildcard', value: cors, time: VT.Utils.ts() });
                    }

                } catch (e) {
                    VT.log(`  HEAD request failed: ${e.message}`, 'warn');
                    VT.log('  (CORS may be blocking the HEAD request — check DevTools Network tab for headers)', 'info');
                }
            },

            ScanSubdomains() {
                VT.log('── Subdomain Enumeration ─────────────', 'section');
                const base = location.hostname.split('.').slice(-2).join('.');
                const found = new Set();

                // From network log
                VT.State.NetworkLog.forEach(e => {
                    try { const h = new URL(e.url).hostname; if (h.endsWith(base) && h !== location.hostname) found.add(h); } catch (_) {}
                });
                // From script srcs
                document.querySelectorAll('script[src],link[href],img[src],iframe[src]').forEach(el => {
                    const raw = el.src || el.href || '';
                    try { const h = new URL(raw).hostname; if (h.endsWith(base) && h !== location.hostname) found.add(h); } catch (_) {}
                });
                // From link map if already scanned
                if (VT.State.LinkMap) {
                    [...(VT.State.LinkMap.external || []), ...(VT.State.LinkMap.sublinks || [])].forEach(u => {
                        try { const h = new URL(u).hostname; if (h.endsWith(base)) found.add(h); } catch (_) {}
                    });
                }
                // From inline script text
                const hostRe = new RegExp(`["'\`]([a-zA-Z0-9_-]+\\.${base.replace('.','\\.')})[/"'\`]`, 'gi');
                document.querySelectorAll('script:not([src])').forEach(s => {
                    let m;
                    while ((m = hostRe.exec(s.innerText)) !== null) found.add(m[1]);
                });

                if (!found.size) { VT.log('  No subdomains found.', 'info'); return; }
                found.forEach(h => {
                    VT.log(`  ${h}`, 'data');
                    VT.State.Findings.push({ type: 'subdomain', host: h, time: VT.Utils.ts() });
                });
                VT.log(`  Total: ${found.size} subdomain(s) found.`, 'ok');
            },

            ScanEventListeners() {
                VT.log('── Event Listener Probe ──────────────', 'section');
                const targets = [window, document, document.body].filter(Boolean);
                const interesting = new Set([
                    'message','messageerror','storage','popstate','hashchange',
                    'deviceorientation','devicemotion','visibilitychange',
                    'beforeunload','unload','pagehide','pageshow',
                    'securitypolicyviolation','rejectionhandled','unhandledrejection'
                ]);
                // We can't enumerate listeners directly — instead probe via getEventListeners if available (Chrome DevTools)
                // or check window.on* properties for non-null handlers
                let count = 0;
                const onProps = Object.getOwnPropertyNames(window).filter(p => p.startsWith('on') && !VT.Config.GlobalsBlocklist.has(p));
                onProps.forEach(p => {
                    try {
                        const v = window[p];
                        if (v !== null && typeof v === 'function') {
                            VT.log(`  window.${p} = [function ${v.name || 'anonymous'}]`, interesting.has(p.slice(2)) ? 'flag' : 'data');
                            if (interesting.has(p.slice(2))) {
                                VT.State.Findings.push({ type: 'event_listener', event: p, time: VT.Utils.ts() });
                            }
                            count++;
                        }
                    } catch (_) {}
                });
                // Also check document.on*
                const docOnProps = Object.getOwnPropertyNames(document).filter(p => p.startsWith('on'));
                docOnProps.forEach(p => {
                    try {
                        const v = document[p];
                        if (v !== null && typeof v === 'function') {
                            VT.log(`  document.${p} = [function ${v.name || 'anonymous'}]`, 'data');
                            count++;
                        }
                    } catch (_) {}
                });
                if (count === 0) VT.log('  No custom event handlers found on window/document.', 'info');
                else VT.log(`  ${count} active handler(s) found.`, 'ok');
                VT.log('  Note: addEventListener bindings require Chrome DevTools getEventListeners() — not inspectable here.', 'info');
            },

            ScanLinks() {
                VT.log('── Link Enumerator ───────────────────', 'section');

                const origin   = location.origin;
                const hostname = location.hostname;

                const buckets = {
                    internal : new Set(),   // same origin
                    sublinks : new Set(),   // same hostname, different path/query
                    external : new Set(),   // different origin
                    assets   : new Set(),   // images, fonts, media, stylesheets
                    mailto   : new Set(),   // mailto: / tel:
                    anchors  : new Set(),   // #fragment only
                    js       : new Set(),   // javascript: hrefs
                };

                // Collect every href / src / action / data-href on the page
                const rawLinks = new Set();

                // <a href>, <area href>
                document.querySelectorAll('a[href], area[href]').forEach(el => rawLinks.add(el.href));
                // <link href>  (stylesheets, preloads, etc.)
                document.querySelectorAll('link[href]').forEach(el => rawLinks.add(el.href));
                // <img src>, <source src/srcset>, <video src>, <audio src>, <iframe src>, <embed src>
                document.querySelectorAll('img[src],source[src],video[src],audio[src],iframe[src],embed[src],frame[src]')
                    .forEach(el => rawLinks.add(el.src));
                // srcset
                document.querySelectorAll('[srcset]').forEach(el => {
                    el.srcset.split(',').forEach(part => {
                        const url = part.trim().split(/\s+/)[0];
                        if (url) rawLinks.add(url);
                    });
                });
                // <form action>
                document.querySelectorAll('form[action]').forEach(el => rawLinks.add(el.action));
                // data-href / data-url / data-src (common SPA patterns)
                document.querySelectorAll('[data-href],[data-url],[data-src]').forEach(el => {
                    ['data-href','data-url','data-src'].forEach(attr => {
                        const v = el.getAttribute(attr);
                        if (v) rawLinks.add(v);
                    });
                });

                // Also mine inline script text for URL-shaped strings
                const urlPattern = /["'`]((?:https?:\/\/|\/)[a-zA-Z0-9_\-/.?=&#%@:+]+)["'`]/g;
                document.querySelectorAll('script').forEach(s => {
                    let m;
                    while ((m = urlPattern.exec(s.innerText)) !== null) rawLinks.add(m[1]);
                });

                // Classify
                rawLinks.forEach(raw => {
                    if (!raw || raw === 'about:blank') return;
                    const str = String(raw).trim();
                    if (!str) return;

                    // Special schemes
                    if (/^javascript:/i.test(str))          { buckets.js.add(str.slice(0, 80)); return; }
                    if (/^(mailto|tel):/i.test(str))        { buckets.mailto.add(str); return; }
                    if (/^#/.test(str))                     { buckets.anchors.add(str); return; }

                    let full = str;
                    // Resolve relative URLs
                    try { full = new URL(str, location.href).href; } catch (_) { return; }

                    // Assets by extension
                    const ext = full.split('?')[0].split('#')[0].split('.').pop().toLowerCase();
                    const assetExts = new Set(['jpg','jpeg','png','gif','webp','svg','ico','woff','woff2','ttf','eot','otf','mp4','mp3','wav','ogg','pdf','css','map']);
                    if (assetExts.has(ext)) { buckets.assets.add(full); return; }

                    try {
                        const u = new URL(full);
                        if (u.origin === origin)           buckets.internal.add(full);
                        else if (u.hostname.endsWith(hostname) || hostname.endsWith(u.hostname))
                                                           buckets.sublinks.add(full);
                        else                               buckets.external.add(full);
                    } catch (_) {}
                });

                // ── Print results
                const print = (label, set, type) => {
                    if (!set.size) return;
                    VT.log(`\n  ${label} (${set.size})`, 'section');
                    [...set].sort().forEach(u => VT.log(`    ${u}`, type));
                };

                print('INTERNAL LINKS',  buckets.internal,  'data');
                print('SUBDOMAINS/CROSS-ORIGIN SAME HOST', buckets.sublinks, 'warn');
                print('EXTERNAL LINKS',  buckets.external,  'info');
                print('ASSETS',          buckets.assets,    'info');
                print('MAILTO / TEL',    buckets.mailto,    'info');
                print('ANCHORS (#)',      buckets.anchors,   'info');
                print('JAVASCRIPT HREFS', buckets.js,       'flag');

                const total = Object.values(buckets).reduce((n, s) => n + s.size, 0);
                VT.log(`\n  Total unique links: ${total}`, 'ok');

                // Store for export
                VT.State.LinkMap = buckets;
                return buckets;
            },

            async DecodeToken(token) {
                VT.log('── JWT Analysis ──────────────────────', 'section');
                const result = VT.Utils.decodeJWT(token);
                if (!result) { VT.log('  Invalid or non-JWT token.', 'warn'); return; }

                // ── Header
                VT.log('  Header:', 'data');
                Object.entries(result.header).forEach(([k,v]) => VT.log(`    ${k}: ${v}`, 'data'));

                // ── Algorithm analysis
                const alg = result.header.alg;
                if (!alg || alg === 'none') {
                    VT.log(`  [CRITICAL] alg:"none" — server may accept unsigned tokens. Forgery possible.`, 'flag');
                    VT.State.Findings.push({ type: 'jwt_alg_none', token: token.slice(0,60), time: VT.Utils.ts() });
                } else if (alg.startsWith('HS')) {
                    VT.log(`  [WARN] ${alg} — symmetric HMAC. Vulnerable to weak secret brute force.`, 'warn');
                } else if (alg.startsWith('RS') || alg.startsWith('ES') || alg.startsWith('PS')) {
                    VT.log(`  [INFO] ${alg} — asymmetric. Check for: key confusion (RS256→HS256 attack), JWKS misconfig.`, 'data');
                }

                // ── Payload
                VT.log('  Payload:', 'data');
                Object.entries(result.payload).forEach(([k,v]) => {
                    const isSensitive = VT.Config.SensitiveKeywords.some(kw => k.toLowerCase().includes(kw));
                    VT.log(`    ${k}: ${JSON.stringify(v)}`, isSensitive ? 'flag' : 'data');
                });

                // ── Timing claims
                const now = Math.floor(Date.now() / 1000);
                if (result.payload.exp) {
                    const exp = new Date(result.payload.exp * 1000);
                    const expired = result.payload.exp < now;
                    const ttl = result.payload.exp - now;
                    VT.log(`  Expires : ${exp.toISOString()} — ${expired ? '[!!] EXPIRED' : `valid for ${ttl}s`}`, expired ? 'flag' : 'ok');
                    if (!expired && ttl > 86400 * 30) VT.log(`  [WARN] Token TTL > 30 days (${Math.floor(ttl/86400)}d) — long-lived tokens increase stolen-token risk.`, 'warn');
                } else {
                    VT.log('  [!!] No exp claim — token never expires.', 'flag');
                    VT.State.Findings.push({ type: 'jwt_no_expiry', token: token.slice(0,60), time: VT.Utils.ts() });
                }
                if (result.payload.nbf && result.payload.nbf > now) {
                    VT.log(`  [INFO] nbf (not before) is in the future — token not yet valid.`, 'warn');
                }
                if (result.payload.iat) {
                    VT.log(`  Issued  : ${new Date(result.payload.iat * 1000).toISOString()}`, 'info');
                }

                // ── Sensitive claims
                const sensitiveClaims = ['role','roles','scope','permissions','admin','isAdmin','isStaff','userType','groups','authorities'];
                sensitiveClaims.forEach(c => {
                    if (result.payload[c] !== undefined) {
                        VT.log(`  [!!] Privilege claim found — "${c}": ${JSON.stringify(result.payload[c])}`, 'flag');
                        VT.State.Findings.push({ type: 'jwt_privilege_claim', claim: c, value: result.payload[c], time: VT.Utils.ts() });
                    }
                });

                // ── Weak secret crack attempt (HMAC only)
                if (alg && alg.startsWith('HS')) {
                    VT.log(`  Attempting weak secret crack (${VT.Utils.JWTWordlist.length + 2} candidates)...`, 'info');
                    const result2 = await VT.Utils.crackJWT(token);
                    if (result2?.cracked) {
                        VT.log(`  [CRITICAL] WEAK SECRET FOUND: "${result2.secret}"`, 'flag');
                        VT.State.Findings.push({ type: 'jwt_weak_secret', secret: result2.secret, token: token.slice(0,60), time: VT.Utils.ts() });
                    } else if (result2?.error) {
                        VT.log(`  Crack skipped: ${result2.error}`, 'info');
                    } else {
                        VT.log('  Secret not found in wordlist.', 'ok');
                    }
                }
            },

            FullScan() {
                VT.log('═══════════════════════════════════════', 'section');
                VT.log('  VANTAGE FULL RECON SCAN', 'section');
                VT.log(`  Target: ${location.href}`, 'section');
                VT.log(`  Time:   ${new Date().toISOString()}`, 'section');
                VT.log('═══════════════════════════════════════', 'section');
                VT.Recon.ScanRoutes();
                VT.Recon.ScanLinks();
                VT.Recon.ScanGlobals();
                VT.Recon.ScanStorage();
                VT.Recon.ScanMeta();
                VT.Recon.ScanComments();
                VT.Recon.ScanCSP();
                VT.Recon.ScanForms();
                VT.Recon.ScanScripts();
                VT.Recon.ScanSubdomains();
                VT.Recon.ScanEventListeners();
                VT.Recon.ScanHeaders(); // async, fires last
                VT.log('═══════════════════════════════════════', 'section');
                VT.log(`  SCAN COMPLETE — ${VT.State.Findings.length} finding(s)`, 'ok');
                VT.log('═══════════════════════════════════════', 'section');
            }
        },

        // ── Commands ──────────────────────────────
        Commands: {
            help() {
                const cmds = [
                    ['scan',            'Full recon scan — runs all modules'],
                    ['routes',          'Harvest API endpoints from inline scripts'],
                    ['links',           'Enumerate all links — internal, external, assets, subdomains, anchors'],
                    ['globals',         'Scan window.* for sensitive variables'],
                    ['storage',         'Dump cookies, localStorage, sessionStorage'],
                    ['meta',            'Harvest meta tags — CSRF tokens, generator, version leaks'],
                    ['comments',        'Scrape HTML + JS comments for secrets and internal notes'],
                    ['headers',         'Audit response headers — info leaks + missing security headers'],
                    ['subdomains',      'Enumerate subdomains referenced on this page'],
                    ['events',          'Probe window/document event handlers'],
                    ['csp',             'Check CSP headers/meta'],
                    ['forms',           'Enumerate forms and inputs'],
                    ['scripts',         'Audit external/inline script sources'],
                    ['net',             'Show captured network requests'],
                    ['findings',        'Show all flagged findings'],
                    ['jwt <token>',      'Decode + analyse a JWT (expiry, claims, alg, privilege fields, auto-crack)'],
                    ['jwtcrack <token>', 'Standalone weak secret brute force against a JWT (HS256/384/512)'],
                    ['note <text>',     'Add a manual annotation to findings'],
                    ['watch <keyword>', 'Flag any future network response containing keyword'],
                    ['export',          'Copy full report to clipboard'],
                    ['clear',           'Clear console output'],
                    ['help',            'Show this message'],
                ];
                VT.log('── VANTAGE Commands ──────────────────', 'section');
                cmds.forEach(([cmd, desc]) => VT.log(`  ${cmd.padEnd(18)} ${desc}`, 'info'));
            },

            scan()       { VT.Recon.FullScan(); },
            routes()     { VT.Recon.ScanRoutes(); },
            links()      { VT.Recon.ScanLinks(); },
            globals()    { VT.Recon.ScanGlobals(); },
            storage()    { VT.Recon.ScanStorage(); },
            meta()       { VT.Recon.ScanMeta(); },
            comments()   { VT.Recon.ScanComments(); },
            headers()    { VT.Recon.ScanHeaders(); },
            subdomains() { VT.Recon.ScanSubdomains(); },
            events()     { VT.Recon.ScanEventListeners(); },
            csp()        { VT.Recon.ScanCSP(); },
            forms()      { VT.Recon.ScanForms(); },
            scripts()    { VT.Recon.ScanScripts(); },

            note(args) {
                const text = args.join(' ');
                if (!text) { VT.log('  Usage: note <your annotation>', 'warn'); return; }
                VT.log(`  [NOTE] ${text}`, 'ok');
                VT.State.Findings.push({ type: 'analyst_note', text, time: VT.Utils.ts() });
            },

            watch(args) {
                const kw = args[0];
                if (!kw) { VT.log('  Usage: watch <keyword>', 'warn'); return; }
                if (!VT.State.WatchList) VT.State.WatchList = [];
                if (VT.State.WatchList.includes(kw)) { VT.log(`  Already watching "${kw}".`, 'info'); return; }
                VT.State.WatchList.push(kw);
                VT.log(`  Watching for "${kw}" in all future network responses.`, 'ok');
            },

            net() {
                VT.log('── Network Log ───────────────────────', 'section');
                if (!VT.State.NetworkLog.length) { VT.log('  No requests captured yet.', 'info'); return; }
                VT.State.NetworkLog.forEach((e, i) => {
                    const flags = e.flags?.length ? ` [!!:${e.flags.join(',')}]` : '';
                    VT.log(`  [${i}] ${e.type.toUpperCase()} ${e.method} ${VT.Utils.trimUrl(e.url)} ${e.status ?? '...'}${flags}`, 'data');
                });
            },

            findings() {
                VT.log('── Findings ──────────────────────────', 'section');
                if (!VT.State.Findings.length) { VT.log('  No findings yet.', 'info'); return; }
                VT.State.Findings.forEach((f, i) => {
                    VT.log(`  [${i}] [${f.type}] ${JSON.stringify(f).slice(0, 150)}`, 'flag');
                });
            },

            jwt(args) {
                const token = args[0];
                if (!token) { VT.log('  Usage: jwt <token>', 'warn'); return; }
                VT.Recon.DecodeToken(token); // async, logs as it goes
            },

            jwtcrack(args) {
                const token = args[0];
                if (!token) { VT.log('  Usage: jwtcrack <token>', 'warn'); return; }
                VT.log('── JWT Weak Secret Crack ─────────────', 'section');
                const dec = VT.Utils.decodeJWT(token);
                if (!dec) { VT.log('  Invalid JWT.', 'warn'); return; }
                if (!dec.header.alg?.startsWith('HS')) {
                    VT.log(`  Cannot crack ${dec.header.alg} client-side — only HS256/384/512 supported.`, 'warn');
                    return;
                }
                VT.log(`  Algorithm: ${dec.header.alg}`, 'data');
                VT.log(`  Trying ${VT.Utils.JWTWordlist.length + 2} candidates...`, 'info');
                VT.Utils.crackJWT(token).then(r => {
                    if (r?.cracked) {
                        VT.log(`  [CRITICAL] WEAK SECRET CRACKED: "${r.secret}"`, 'flag');
                        VT.State.Findings.push({ type: 'jwt_weak_secret', secret: r.secret, token: token.slice(0,60), time: VT.Utils.ts() });
                    } else if (r?.error) {
                        VT.log(`  ${r.error}`, 'warn');
                    } else {
                        VT.log('  Secret not in wordlist — token appears to use a strong secret.', 'ok');
                    }
                });
            },

            export() {
                const lines = VT.State.Logs.map(l => l.text).join('\n');
                const report = [
                    `VANTAGE AUDIT EXPORT`,
                    `Target : ${location.href}`,
                    `Date   : ${new Date().toISOString()}`,
                    `Logs   : ${VT.State.Logs.length}`,
                    `Network: ${VT.State.NetworkLog.length}`,
                    `Findings:${VT.State.Findings.length}`,
                    '─'.repeat(60),
                    lines,
                    '─'.repeat(60),
                    'NETWORK LOG',
                    VT.State.NetworkLog.map(e =>
                        `[${e.time}] ${e.type.toUpperCase()} ${e.method} ${e.url} ${e.status ?? '?'}\n` +
                        (e.preview ? `  Preview: ${e.preview.slice(0,200)}` : '')
                    ).join('\n'),
                    '─'.repeat(60),
                    'LINK MAP',
                    VT.State.LinkMap ? Object.entries(VT.State.LinkMap).map(([k, v]) =>
                        `[${k.toUpperCase()}]\n` + [...v].map(u => '  ' + u).join('\n')
                    ).join('\n') : '  Run  links  or  scan  first.',
                    '─'.repeat(60),
                    'FINDINGS',
                    VT.Utils.formatJSON(VT.State.Findings)
                ].join('\n');
                VT.Utils.copyToClip(report);
            },

            clear() {
                VT.State.Logs = [];
                if (VT.UI.Console) VT.UI.Console.innerHTML = '';
            }
        },

        // ── Logging ───────────────────────────────
        log(msg, type = 'info') {
            const entry = { text: `${VT.Utils.ts()}  ${msg}`, type };
            VT.State.Logs.push(entry);
            if (VT.State.Logs.length > VT.Config.MaxLogs) VT.State.Logs.shift();
            if (!VT.UI?.Console || VT.State.ActiveTab !== 'console') return;
            VT._appendLog(entry);
        },

        _appendLog(entry) {
            const el = document.createElement('div');
            el.className = `vt-line vt-${entry.type}`;
            el.textContent = entry.text;
            VT.UI.Console.appendChild(el);
            VT.UI.Console.scrollTop = VT.UI.Console.scrollHeight;
        },

        // ── Execute ───────────────────────────────
        Execute(raw) {
            VT.log(`# ${raw}`, 'exec');
            VT.State.History.push(raw);
            VT.State.HistoryPos = VT.State.History.length;
            const parts = raw.trim().split(/\s+/);
            const cmd   = parts[0].toLowerCase();
            const args  = parts.slice(1);
            if (VT.Commands[cmd]) {
                try { VT.Commands[cmd](args); }
                catch (e) { VT.log(`Error: ${e.message}`, 'warn'); }
            } else {
                try {
                    // eslint-disable-next-line no-eval
                    const r = eval(raw);
                    if (r !== undefined) VT.log(String(r), 'data');
                } catch (e) { VT.log(`Eval error: ${e.message}`, 'warn'); }
            }
        },

        // ── UI ────────────────────────────────────
        UI: {
            Main: null,
            Console: null,
            Input: null,

            CSS: `
                @import url('https://fonts.googleapis.com/css2?family=JetBrains+Mono:wght@400;600;700&family=Syne:wght@700;800&display=swap');

                #vt-root *, #vt-root *::before, #vt-root *::after {
                    box-sizing: border-box;
                    margin: 0; padding: 0;
                }

                #vt-root {
                    position: fixed;
                    top: 24px; right: 24px;
                    width: 560px;
                    height: 420px;
                    background: #09090c;
                    border: 1px solid #1e1e28;
                    border-radius: 10px;
                    display: flex;
                    flex-direction: column;
                    font-family: 'JetBrains Mono', monospace;
                    font-size: 11px;
                    color: #9099b0;
                    z-index: 2147483647;
                    box-shadow:
                        0 0 0 1px #0d0d14,
                        0 24px 80px rgba(0,0,0,0.9),
                        inset 0 1px 0 #1c1c28;
                    resize: both;
                    overflow: hidden;
                    min-width: 380px;
                    min-height: 260px;
                }

                #vt-titlebar {
                    display: flex;
                    align-items: center;
                    justify-content: space-between;
                    padding: 0 14px;
                    height: 38px;
                    background: #0c0c10;
                    border-bottom: 1px solid #161620;
                    border-radius: 10px 10px 0 0;
                    cursor: grab;
                    user-select: none;
                    flex-shrink: 0;
                }
                #vt-titlebar:active { cursor: grabbing; }

                #vt-title {
                    font-family: 'Syne', sans-serif;
                    font-size: 12px;
                    font-weight: 800;
                    letter-spacing: 0.12em;
                    color: #e8eaf0;
                    display: flex;
                    align-items: center;
                    gap: 8px;
                }
                #vt-title .vt-dot {
                    width: 6px; height: 6px;
                    border-radius: 50%;
                    background: #3dffb0;
                    box-shadow: 0 0 6px #3dffb0;
                    animation: vt-pulse 2s ease infinite;
                }
                @keyframes vt-pulse {
                    0%,100% { opacity:1; } 50% { opacity:0.4; }
                }

                #vt-controls {
                    display: flex; gap: 8px; align-items: center;
                }
                .vt-ctrl-btn {
                    width: 11px; height: 11px;
                    border-radius: 50%;
                    border: none;
                    cursor: pointer;
                    opacity: 0.6;
                    transition: opacity 0.15s;
                }
                .vt-ctrl-btn:hover { opacity: 1; }
                #vt-btn-hide { background: #f5a623; }
                #vt-btn-close { background: #ff5f57; }

                #vt-tabs {
                    display: flex;
                    gap: 2px;
                    padding: 6px 10px 0;
                    background: #0a0a0e;
                    border-bottom: 1px solid #141420;
                    flex-shrink: 0;
                }
                .vt-tab {
                    padding: 5px 12px;
                    border-radius: 5px 5px 0 0;
                    font-size: 10px;
                    font-weight: 600;
                    letter-spacing: 0.08em;
                    color: #484860;
                    cursor: pointer;
                    transition: all 0.15s;
                    text-transform: uppercase;
                    border: 1px solid transparent;
                    border-bottom: none;
                }
                .vt-tab:hover { color: #9099b0; }
                .vt-tab.active {
                    background: #09090c;
                    color: #3dffb0;
                    border-color: #1c1c28;
                    position: relative;
                    bottom: -1px;
                }

                #vt-console {
                    flex: 1;
                    overflow-y: auto;
                    padding: 10px 14px;
                    line-height: 1.7;
                    scrollbar-width: thin;
                    scrollbar-color: #1e1e2e #09090c;
                }
                #vt-console::-webkit-scrollbar { width: 4px; }
                #vt-console::-webkit-scrollbar-track { background: transparent; }
                #vt-console::-webkit-scrollbar-thumb { background: #1e1e2e; border-radius: 4px; }

                .vt-line { white-space: pre-wrap; word-break: break-all; }
                .vt-info    { color: #3a3a50; }
                .vt-ok      { color: #3dffb0; }
                .vt-warn    { color: #f5a623; }
                .vt-flag    { color: #ff4466; font-weight: 600; }
                .vt-net     { color: #5090ff; }
                .vt-data    { color: #a0c8ff; }
                .vt-section { color: #7060c0; font-weight: 600; }
                .vt-exec    {
                    color: #e8eaf0;
                    border-left: 2px solid #3dffb0;
                    padding-left: 8px;
                    margin: 4px 0;
                }

                #vt-statusbar {
                    display: flex;
                    justify-content: space-between;
                    align-items: center;
                    padding: 4px 14px;
                    font-size: 9px;
                    color: #2a2a3a;
                    background: #070709;
                    border-top: 1px solid #111118;
                    letter-spacing: 0.06em;
                    flex-shrink: 0;
                }
                #vt-statusbar span { font-weight: 600; }
                .vt-stat-ok  { color: #3dffb0 !important; }
                .vt-stat-warn { color: #f5a623 !important; }

                #vt-inputrow {
                    display: flex;
                    align-items: center;
                    padding: 0 14px;
                    height: 36px;
                    background: #07070a;
                    border-top: 1px solid #131320;
                    border-radius: 0 0 10px 10px;
                    gap: 8px;
                    flex-shrink: 0;
                }
                #vt-prompt {
                    color: #3dffb0;
                    font-weight: 700;
                    font-size: 12px;
                    flex-shrink: 0;
                }
                #vt-input {
                    flex: 1;
                    background: transparent;
                    border: none;
                    outline: none;
                    color: #c8d0e0;
                    font-family: 'JetBrains Mono', monospace;
                    font-size: 11px;
                    caret-color: #3dffb0;
                }
                #vt-input::placeholder { color: #282838; }
            `,

            Initialize() {
                if (document.getElementById('vt-root')) return;

                const style = document.createElement('style');
                style.id = 'vt-style';
                style.textContent = this.CSS;
                document.head.appendChild(style);

                this.Main = document.createElement('div');
                this.Main.id = 'vt-root';
                this.Main.innerHTML = `
                    <div id="vt-titlebar">
                        <div id="vt-title">
                            <span class="vt-dot"></span>
                            VANTAGE
                        </div>
                        <div id="vt-controls">
                            <button class="vt-ctrl-btn" id="vt-btn-hide" title="Hide (Shift+tilde)"></button>
                            <button class="vt-ctrl-btn" id="vt-btn-close" title="Close"></button>
                        </div>
                    </div>
                    <div id="vt-tabs">
                        <div class="vt-tab active" data-tab="console">Console</div>
                        <div class="vt-tab" data-tab="network">Network</div>
                        <div class="vt-tab" data-tab="findings">Findings</div>
                    </div>
                    <div id="vt-console"></div>
                    <div id="vt-statusbar">
                        <span id="vt-st-url">${location.hostname}</span>
                        <span id="vt-st-net">NET 0</span>
                        <span id="vt-st-findings">FINDINGS 0</span>
                        <span id="vt-st-status" class="vt-stat-ok">● ACTIVE</span>
                    </div>
                    <div id="vt-inputrow">
                        <span id="vt-prompt">▶</span>
                        <input type="text" id="vt-input" placeholder="type 'help' for commands..." autocomplete="off" spellcheck="false">
                    </div>
                `;
                document.body.appendChild(this.Main);

                this.Console = this.Main.querySelector('#vt-console');
                this.Input   = this.Main.querySelector('#vt-input');

                this._setupTabs();
                this._setupInput();
                this._setupHotkey();
                this._setupDrag();
                this._setupButtons();
                this._statusTick();

                VT.log('VANTAGE loaded. Type  help  to list commands.', 'ok');
                VT.log(`Target: ${location.href}`, 'info');
            },

            _setupTabs() {
                this.Main.querySelectorAll('.vt-tab').forEach(tab => {
                    tab.addEventListener('click', () => {
                        this.Main.querySelectorAll('.vt-tab').forEach(t => t.classList.remove('active'));
                        tab.classList.add('active');
                        const view = tab.dataset.tab;
                        VT.State.ActiveTab = view;
                        this.Console.innerHTML = '';

                        if (view === 'console') {
                            VT.State.Logs.slice(-200).forEach(l => VT._appendLog(l));
                        } else if (view === 'network') {
                            if (!VT.State.NetworkLog.length) {
                                const el = document.createElement('div');
                                el.className = 'vt-line vt-info';
                                el.textContent = '  No requests captured yet.';
                                this.Console.appendChild(el);
                            }
                            VT.State.NetworkLog.forEach((e, i) => {
                                const flags = e.flags?.length ? `  [!! ${e.flags.join(', ')}]` : '';
                                const el = document.createElement('div');
                                el.className = `vt-line ${e.flags?.length ? 'vt-flag' : 'vt-net'}`;
                                el.textContent = `${e.time}  [${String(i).padStart(3,'0')}] ${e.type.toUpperCase()} ${e.method.padEnd(6)} ${e.status ?? '???'}  ${VT.Utils.trimUrl(e.url, 55)}${flags}`;
                                this.Console.appendChild(el);
                            });
                        } else if (view === 'findings') {
                            if (!VT.State.Findings.length) {
                                const el = document.createElement('div');
                                el.className = 'vt-line vt-info';
                                el.textContent = '  No findings yet. Run  scan  or  findings  to generate.';
                                this.Console.appendChild(el);
                            }
                            VT.State.Findings.forEach((f, i) => {
                                const el = document.createElement('div');
                                el.className = 'vt-line vt-flag';
                                el.textContent = `  [${String(i).padStart(3,'0')}] [${f.type}] ${JSON.stringify(f).slice(0, 160)}`;
                                this.Console.appendChild(el);
                            });
                        }
                    });
                });
            },

            _setupInput() {
                this.Input.addEventListener('keydown', e => {
                    if (e.key === 'Enter') {
                        const val = this.Input.value.trim();
                        if (!val) return;
                        // Switch to console tab on execute
                        this.Main.querySelectorAll('.vt-tab').forEach(t => t.classList.remove('active'));
                        this.Main.querySelector('[data-tab="console"]').classList.add('active');
                        VT.State.ActiveTab = 'console';
                        VT.Execute(val);
                        this.Input.value = '';
                    }
                    if (e.key === 'ArrowUp') {
                        e.preventDefault();
                        VT.State.HistoryPos = Math.max(0, VT.State.HistoryPos - 1);
                        this.Input.value = VT.State.History[VT.State.HistoryPos] ?? '';
                    }
                    if (e.key === 'ArrowDown') {
                        e.preventDefault();
                        VT.State.HistoryPos = Math.min(VT.State.History.length, VT.State.HistoryPos + 1);
                        this.Input.value = VT.State.History[VT.State.HistoryPos] ?? '';
                    }
                    if (e.key === 'Tab') {
                        e.preventDefault();
                        // Tab completion
                        const partial = this.Input.value.trim().toLowerCase();
                        const match = Object.keys(VT.Commands).find(c => c.startsWith(partial) && c !== partial);
                        if (match) this.Input.value = match;
                    }
                    e.stopPropagation();
                });
            },

            _setupHotkey() {
                window.addEventListener('keydown', e => {
                    if (e.code === 'Backquote' && e.shiftKey) {
                        VT.State.Visible = !VT.State.Visible;
                        this.Main.style.display = VT.State.Visible ? 'flex' : 'none';
                    }
                });
            },

            _setupDrag() {
                const bar = this.Main.querySelector('#vt-titlebar');
                let drag = false, ox = 0, oy = 0;
                bar.addEventListener('mousedown', e => {
                    if (e.target.classList.contains('vt-ctrl-btn')) return;
                    drag = true;
                    ox = e.clientX - this.Main.offsetLeft;
                    oy = e.clientY - this.Main.offsetTop;
                    e.preventDefault();
                });
                window.addEventListener('mousemove', e => {
                    if (!drag) return;
                    this.Main.style.left = (e.clientX - ox) + 'px';
                    this.Main.style.top  = (e.clientY - oy) + 'px';
                    this.Main.style.right = 'auto';
                });
                window.addEventListener('mouseup', () => drag = false);
            },

            _setupButtons() {
                this.Main.querySelector('#vt-btn-hide').addEventListener('click', () => {
                    VT.State.Visible = false;
                    this.Main.style.display = 'none';
                });
                this.Main.querySelector('#vt-btn-close').addEventListener('click', () => {
                    this.Main.remove();
                    document.getElementById('vt-style')?.remove();
                });
            },

            _statusTick() {
                setInterval(() => {
                    const netEl = document.getElementById('vt-st-net');
                    const fndEl = document.getElementById('vt-st-findings');
                    if (netEl) netEl.textContent = `NET ${VT.State.NetworkLog.length}`;
                    if (fndEl) {
                        fndEl.textContent = `FINDINGS ${VT.State.Findings.length}`;
                        fndEl.className = VT.State.Findings.length > 0 ? 'vt-stat-warn' : '';
                    }
                }, 1000);
            }
        },

        // ── Boot ──────────────────────────────────
        Boot() {
            // Net hooks go in immediately — no DOM needed
            VT.Net.Initialize();

            let booted = false;

            const tryInit = () => {
                if (booted) return true;
                if (!document.body) return false;
                booted = true;
                VT.UI.Initialize();
                return true;
            };

            // Strategy 1: already ready right now
            if (tryInit()) return;

            // Strategy 2: DOMContentLoaded event
            document.addEventListener('DOMContentLoaded', () => tryInit(), { once: true });

            // Strategy 3: window load (last resort for slow SPAs)
            window.addEventListener('load', () => tryInit(), { once: true });

            // Strategy 4: MutationObserver watching for body to appear
            const obs = new MutationObserver(() => {
                if (tryInit()) obs.disconnect();
            });
            obs.observe(document.documentElement, { childList: true, subtree: true });

            // Strategy 5: polling fallback — catches sandboxed iframes, CSP-blocked events, etc.
            const poll = setInterval(() => {
                if (tryInit()) clearInterval(poll);
            }, 150);
            setTimeout(() => clearInterval(poll), 15000);
        }
    };

    VT.Boot();

})();
