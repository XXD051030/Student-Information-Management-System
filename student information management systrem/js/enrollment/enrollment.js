(function () {
    var selected = {}; // code -> { code, name, credits, fee }

    function recompute() {
        var count = 0, credits = 0, total = 0;
        for (var code in selected) {
            if (!Object.prototype.hasOwnProperty.call(selected, code)) continue;
            count++;
            credits += selected[code].credits;
            total += selected[code].fee;
        }
        var countEl = document.getElementById('enroll-count');
        var creditsEl = document.getElementById('enroll-credits');
        var totalEl = document.getElementById('enroll-total');
        if (countEl) countEl.textContent = count;
        if (creditsEl) creditsEl.textContent = credits;
        if (totalEl) totalEl.textContent = total.toFixed(2);
        var submit = document.getElementById('enroll-submit');
        if (submit) submit.disabled = count === 0;

        // Keep footer summary spans in sync
        var countFooter = document.getElementById('enroll-count-footer');
        var creditsFooter = document.getElementById('enroll-credits-footer');
        var totalFooter = document.getElementById('enroll-total-footer');
        if (countFooter) countFooter.textContent = count;
        if (creditsFooter) creditsFooter.textContent = credits;
        if (totalFooter) totalFooter.textContent = total.toFixed(2);

        // Style submit button based on disabled state
        if (submit) {
            if (count === 0) {
                submit.className = 'inline-flex items-center gap-2 rounded-xl px-5 h-11 bg-slate-100 text-slate-400 cursor-not-allowed transition-all';
            } else {
                submit.className = 'inline-flex items-center gap-2 rounded-xl px-5 h-11 bg-[#e0162b] text-white hover:bg-[#a01020] shadow-[0_8px_20px_-8px_rgba(224,22,43,0.55)] transition-all';
            }
        }
    }

    var checkboxes = document.querySelectorAll('[data-action="toggle-enroll"]');
    for (var i = 0; i < checkboxes.length; i++) {
        (function (cb) {
            var row = cb.closest('[data-course-row]');
            cb.addEventListener('change', function () {
                var code = cb.getAttribute('data-code');
                if (cb.checked) {
                    selected[code] = {
                        code: code,
                        name: row.getAttribute('data-name'),
                        credits: parseInt(row.getAttribute('data-credits'), 10) || 0,
                        fee: parseFloat(row.getAttribute('data-fee')) || 0
                    };
                } else {
                    delete selected[code];
                }
                recompute();
            });
        })(checkboxes[i]);
    }

    var submit = document.querySelector('[data-action="proceed-to-payment"]');
    if (submit) {
        submit.addEventListener('click', function () {
            var rows = [];
            for (var code in selected) {
                if (Object.prototype.hasOwnProperty.call(selected, code)) rows.push(selected[code]);
            }
            if (rows.length === 0) return;
            try { sessionStorage.setItem('sims:enrolled', JSON.stringify(rows)); } catch (e) {}
            window.location.href = 'payment.aspx';
        });
    }

    recompute();
})();
