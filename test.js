// ==UserScript==
// @name         blox
// @namespace    http://tampermonkey.net/
// @version      3.0
// @description  Client Sided Unlocks
// @author       Callum
// @match        https://scriptblox.com/*
// @grant        GM_setClipboard
// @grant        GM_notification
// @run-at       document-idle
// ==/UserScript==

(function() {
    'use strict';

    const SHADOW_LOG = (msg) => console.log(`%c[ShadowBlox] ${msg}`, "color: #a855f7; font-weight: bold;");

    // --- 1. THE EXTRACTION ENGINE ---
    const getAuthToken = () => {
        // Source A: Cookies (Nuxt standard)
        let cookieToken = document.cookie.split('; ').find(row => row.startsWith('token='))?.split('=')[1];
        if (cookieToken) {
            cookieToken = decodeURIComponent(cookieToken).replace(/"/g, '');
            return cookieToken;
        }

        // Source B: Nuxt State Hydration
        if (window.__NUXT__?.payload?.state) {
            const state = window.__NUXT__.payload.state;
            // Recursively look for any key containing a JWT-like string
            const found = Object.values(state).find(s => s && typeof s.token === 'string' && s.token.length > 20);
            if (found) return found.token;
        }

        // Source C: LocalStorage fallback
        const localToken = window.localStorage.getItem('token');
        if (localToken) return localToken.replace(/"/g, '');

        return null;
    };

    // --- 2. THE AUTHORITY ENFORCER ---
    const enforceAuthority = () => {
        if (!window.__NUXT__) return;

        try {
            const state = window.__NUXT__.payload.state;
            // Find the main store key (it's often minified to something like '$smain')
            const storeKey = Object.keys(state).find(k => state[k] && state[k].visitorId !== undefined);

            if (storeKey) {
                const store = state[storeKey];

                // Hijack Identity
                if (!store.visitorId.startsWith("AUTHORITY_")) {
                    store.visitorId = "AUTHORITY_" + Math.random().toString(36).substring(7);
                }

                // UNLOCK UI: Force site to think you are the Owner
                // This reveals hidden tabs like 'Dashboard' and 'Reinstate' in the sidebar
                if (store.role !== "owner") {
                    store.role = "owner";
                    store.userVerified = true;
                    SHADOW_LOG("UI Authority Enforced: Role set to Owner.");
                }

                // Global exposure for console debugging
                window.AuthorityStore = store;
            }
        } catch (e) {
            // Silently fail if state isn't ready
        }
    };

    // --- 3. UI SCRUBBER ---
    const nukeChildishElements = () => {
        const targets = [
            'div[role="dialog"]',             // Modals
            '[class*="bg-secondary/40"]',     // Banners
            '#nuxt-route-announcer',
            '[id^="headlessui-portal-root"]'
        ];

        targets.forEach(query => {
            document.querySelectorAll(query).forEach(el => {
                const text = el.innerText || "";
                if (text.includes("requests") || text.includes("Login") || text.includes("Beta") || text.includes("understand")) {
                    el.remove();
                }
            });
        });
    };

    // --- 4. NETWORK SECURITY ---
    const originalFetch = window.fetch;
    window.fetch = async (...args) => {
        const url = typeof args[0] === 'string' ? args[0] : args[0].url;

        // Block site's attempt to report our script errors to their Discord/Devs
        if (url.includes('/api/diag/err') || url.includes('google-analytics')) {
            return new Response(JSON.stringify({ status: "ok" }), { status: 200 });
        }

        return originalFetch.apply(window, args);
    };

    // --- 5. INITIALIZATION & OBSERVERS ---
    const run = () => {
        enforceAuthority();
        nukeChildishElements();
    };

    const observer = new MutationObserver(run);
    observer.observe(document.documentElement, { childList: true, subtree: true });

    // --- 6. AUTHORITY CONTROL PANEL ---
    const injectUI = () => {
        if (document.getElementById('authority-shield')) return;

        const shield = document.createElement('div');
        shield.id = 'authority-shield';
        shield.innerHTML = '🛡️';
        shield.style = `
            position: fixed; bottom: 20px; right: 20px; z-index: 999999;
            background: linear-gradient(135deg, #a855f7 0%, #6366f1 100%);
            color: white; width: 55px; height: 55px; border-radius: 15px;
            display: flex; align-items: center; justify-content: center;
            cursor: pointer; border: 2px solid #fff;
            box-shadow: 0 10px 25px rgba(0,0,0,0.5); font-size: 28px;
            transition: transform 0.2s;
        `;

        shield.onclick = () => {
            const token = getAuthToken();
            if (token) {
                GM_setClipboard(token);
                GM_notification({
                    title: "Authority V3",
                    text: "JWT Token extracted from Cookies/Store.",
                    timeout: 2000
                });
                SHADOW_LOG("Token copied successfully.");
            } else {
                SHADOW_LOG("Extraction Failed. Store might be locked.");
                alert("Auth Token not found. Try refreshing or logging out/in.");
            }
        };

        shield.onmouseenter = () => shield.style.transform = 'scale(1.1)';
        shield.onmouseleave = () => shield.style.transform = 'scale(1.0)';

        document.body.appendChild(shield);
    };

    // Startup
    SHADOW_LOG("Suite V3 Loaded. Searching for Session...");
    run();
    injectUI();

})();
