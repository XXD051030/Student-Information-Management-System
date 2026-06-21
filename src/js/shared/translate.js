/*
 * Portal display-language engine.
 *
 * Pages are served in English. This script, included on every page via
 * site.master, re-applies the user's chosen language (stored in localStorage)
 * on each load by walking the rendered DOM, batching the visible strings to the
 * server-side /translate.ashx proxy (Google Cloud Translation), and swapping the
 * text in place. Switching back to English just reloads the original markup.
 *
 * Public API (window.PortalTranslate):
 *   .current()            -> current language code ("en", "ms", ...)
 *   .set(langCode)        -> persist + apply (or reload for English)
 *   .apply()              -> re-translate the current DOM into the stored language
 */
(function () {
    var STORAGE_KEY = 'portal_lang';
    var BATCH_SIZE = 100;                 // strings per request to the proxy
    var SKIP_TAGS = { SCRIPT: 1, STYLE: 1, NOSCRIPT: 1, TEXTAREA: 1, CODE: 1, PRE: 1 };

    var endpoint = window.PORTAL_TRANSLATE_URL || 'translate.ashx';
    var applying = false;

    function current() {
        try { return localStorage.getItem(STORAGE_KEY) || 'en'; }
        catch (e) { return 'en'; }
    }

    function store(lang) {
        try { localStorage.setItem(STORAGE_KEY, lang); } catch (e) { }
    }

    // Per-language translation cache in localStorage: { sourceText: translated }.
    // Lets repeat loads apply instantly (before paint) without hitting the network.
    function cacheKeyFor(lang) { return 'portal_tx_' + lang; }
    function readCache(lang) {
        try { return JSON.parse(localStorage.getItem(cacheKeyFor(lang)) || '{}') || {}; }
        catch (e) { return {}; }
    }
    function writeCache(lang, map) {
        try { localStorage.setItem(cacheKeyFor(lang), JSON.stringify(map)); } catch (e) { }
    }

    // Reveal the page (the <head> guard hides <body> until translation is ready).
    function reveal() {
        document.documentElement.classList.remove('tx-hide');
    }

    // True when a string is worth translating (has at least one letter).
    function hasLetters(s) {
        return /[A-Za-zÀ-ɏ]/.test(s);
    }

    function isSkippable(node) {
        var el = node.parentNode;
        while (el && el.nodeType === 1) {
            if (SKIP_TAGS[el.tagName]) return true;
            if (el.getAttribute && (el.getAttribute('data-no-translate') !== null ||
                                    el.getAttribute('translate') === 'no')) return true;
            el = el.parentNode;
        }
        return false;
    }

    // Collect translatable text nodes and translatable attributes (placeholders).
    // Each target is { get, set, original } so we can read once and write back.
    function collectTargets() {
        var targets = [];

        var walker = document.createTreeWalker(document.body, NodeFilter.SHOW_TEXT, {
            acceptNode: function (node) {
                if (!node.nodeValue || !node.nodeValue.trim()) return NodeFilter.FILTER_REJECT;
                if (!hasLetters(node.nodeValue)) return NodeFilter.FILTER_REJECT;
                if (isSkippable(node)) return NodeFilter.FILTER_REJECT;
                return NodeFilter.FILTER_ACCEPT;
            }
        });

        var n;
        while ((n = walker.nextNode())) {
            (function (textNode) {
                targets.push({
                    original: textNode.nodeValue,
                    set: function (v) {
                        // Preserve the original leading/trailing whitespace.
                        var lead = textNode.nodeValue.match(/^\s*/)[0];
                        var tail = textNode.nodeValue.match(/\s*$/)[0];
                        textNode.nodeValue = lead + v.trim() + tail;
                    }
                });
            })(n);
        }

        var ph = document.querySelectorAll('[placeholder]');
        for (var i = 0; i < ph.length; i++) {
            (function (el) {
                var val = el.getAttribute('placeholder');
                if (val && val.trim() && hasLetters(val) && !isSkippable(el.firstChild || el)) {
                    targets.push({
                        original: val,
                        set: function (v) { el.setAttribute('placeholder', v); }
                    });
                }
            })(ph[i]);
        }

        return targets;
    }

    function chunk(arr, size) {
        var out = [];
        for (var i = 0; i < arr.length; i += size) out.push(arr.slice(i, i + size));
        return out;
    }

    function translateBatch(strings, lang) {
        return fetch(endpoint, {
            method: 'POST',
            credentials: 'same-origin',
            headers: { 'Content-Type': 'application/json; charset=utf-8' },
            body: JSON.stringify({ target: lang, q: strings })
        }).then(function (r) {
            if (!r.ok) throw new Error('Request failed');
            return r.json();
        }).then(function (json) {
            if (!json || !json.ok) throw new Error((json && json.message) || 'Translation failed');
            return json.translations;
        });
    }

    // Translate the live DOM into `lang`. English is the served language, so a
    // request for "en" is a no-op here (callers reload to restore originals).
    // Cached strings are swapped in synchronously (no flash on repeat loads);
    // only the uncached ones are fetched, then cached for next time.
    function apply(lang) {
        lang = lang || current();
        if (lang === 'en' || applying) { reveal(); return Promise.resolve(); }

        var targets = collectTargets();
        if (!targets.length) { reveal(); return Promise.resolve(); }

        var cache = readCache(lang);

        // Apply whatever we already have cached right away, and figure out the
        // distinct strings still missing a translation.
        var missing = [];
        var missingIndex = {};
        for (var i = 0; i < targets.length; i++) {
            var src = targets[i].original;
            var cached = cache[src.trim()];
            if (cached) {
                targets[i].set(cached);
            } else if (!(src in missingIndex)) {
                missingIndex[src] = missing.length;
                missing.push(src);
            }
        }

        document.documentElement.setAttribute('lang', lang);

        // Nothing left to fetch — fully served from cache, reveal immediately.
        if (!missing.length) { reveal(); return Promise.resolve(); }

        applying = true;
        var batches = chunk(missing, BATCH_SIZE);
        return Promise.all(batches.map(function (b) { return translateBatch(b, lang); }))
            .then(function (results) {
                var flat = [].concat.apply([], results);   // translated, in `missing` order
                for (var m = 0; m < missing.length; m++) {
                    if (flat[m]) cache[missing[m].trim()] = flat[m];
                }
                writeCache(lang, cache);

                for (var j = 0; j < targets.length; j++) {
                    var t = targets[j];
                    if (t.original in missingIndex) {
                        var tr = flat[missingIndex[t.original]];
                        if (tr) t.set(tr);
                    }
                }
            })
            .catch(function (e) {
                if (window.console) console.warn('Translation failed:', e && e.message);
            })
            .then(function () {
                applying = false;
                reveal();
            });
    }

    function set(lang) {
        var prev = current();
        if (lang === prev) return Promise.resolve();
        store(lang);

        // The live DOM is only the English source when the previous language was
        // English. Otherwise reload to re-serve English first, so we never
        // translate from an already-translated page (which would corrupt the
        // cache). The <head> guard + cache make the reload flash-free.
        if (prev !== 'en') { window.location.reload(); return Promise.resolve(); }

        // prev === 'en': DOM is English source — translate (or stay) in place.
        return lang === 'en' ? Promise.resolve() : apply(lang);
    }

    window.PortalTranslate = { current: current, set: set, apply: apply };

    // Wire any language picker on the page (the account page <select>) and
    // auto-apply the stored language once the DOM is ready.
    function init() {
        var picker = document.getElementById('portal-lang-select');
        if (picker) {
            picker.value = current();
            // Don't let the picker's own option labels get translated.
            picker.setAttribute('translate', 'no');
            picker.addEventListener('change', function () { set(picker.value); });
        }
        if (current() !== 'en') apply(current());
    }
    if (document.readyState === 'loading') {
        document.addEventListener('DOMContentLoaded', init);
    } else {
        init();
    }
})();
