(function () {
    var pwInput = document.getElementById('password');
    var confirmInput = document.getElementById('confirm');
    var resetSubmit = document.getElementById('reset_submit');
    var pwLabel = document.getElementById('pw-label');
    var confirmLabel = document.getElementById('confirm-label');

    var resetError = document.getElementById('reset-error');
    var resetErrorText = document.getElementById('reset-error-text');

    var formCard = document.getElementById('form-card');
    var invalidCard = document.getElementById('invalid-card');
    var successCard = document.getElementById('success-card');
    var backRow = document.getElementById('back-row');
    var heading = document.getElementById('reset-heading');
    var subtitle = document.getElementById('reset-subtitle');

    function setLabelFloating(label, floating) {
        if (floating) {
            label.className = 'pointer-events-none absolute left-4 transition-all top-1.5 text-gray-500';
            label.style.fontSize = '11px';
        } else {
            label.className = 'pointer-events-none absolute left-4 transition-all top-1/2 -translate-y-1/2 text-gray-400';
            label.style.fontSize = '14px';
        }
        label.style.fontWeight = '500';
    }

    function setSubmitEnabled(btn, enabled) {
        if (enabled) {
            btn.disabled = false;
            btn.className = 'mt-4 group flex w-full items-center justify-center gap-2 rounded-xl px-4 transition-all h-12 bg-gradient-to-r from-indigo-600 to-indigo-700 text-white shadow-[0_8px_20px_-8px_rgba(79,70,229,0.6)] hover:from-indigo-700 hover:to-indigo-800 active:scale-[0.99]';
        } else {
            btn.disabled = true;
            btn.className = 'mt-4 group flex w-full items-center justify-center gap-2 rounded-xl px-4 transition-all h-12 bg-indigo-300 text-white cursor-not-allowed';
        }
        btn.style.fontSize = '15px';
        btn.style.fontWeight = '600';
    }

    // mirrors AccountPasswordService.ValidateStrength on the server
    function evaluate() {
        var pw = pwInput.value;
        var confirm = confirmInput.value;
        var rules = {
            len: pw.length >= 8,
            upper: /[A-Z]/.test(pw),
            lower: /[a-z]/.test(pw),
            digit: /[0-9]/.test(pw),
            symbol: /[^A-Za-z0-9]/.test(pw),
            match: pw.length > 0 && pw === confirm
        };

        var allOk = true;
        Object.keys(rules).forEach(function (key) {
            var li = document.querySelector('[data-rule="' + key + '"]');
            if (!li) return;
            var icon = li.querySelector('i');
            if (rules[key]) {
                li.className = 'flex items-center gap-2 text-emerald-600';
                if (icon) icon.setAttribute('data-lucide', 'check-circle-2');
            } else {
                li.className = 'flex items-center gap-2 text-gray-400';
                if (icon) icon.setAttribute('data-lucide', 'circle');
                allOk = false;
            }
        });

        if (window.lucide && typeof window.lucide.createIcons === 'function') {
            window.lucide.createIcons();
        }
        setSubmitEnabled(resetSubmit, allOk);
    }

    pwInput.addEventListener('input', evaluate);
    confirmInput.addEventListener('input', evaluate);

    pwInput.addEventListener('focus', function () { setLabelFloating(pwLabel, true); });
    pwInput.addEventListener('blur', function () { setLabelFloating(pwLabel, pwInput.value.length > 0); });
    confirmInput.addEventListener('focus', function () { setLabelFloating(confirmLabel, true); });
    confirmInput.addEventListener('blur', function () { setLabelFloating(confirmLabel, confirmInput.value.length > 0); });

    // show/hide password toggles
    Array.prototype.forEach.call(document.querySelectorAll('[data-action="toggle-pw"]'), function (btn) {
        btn.addEventListener('click', function () {
            var target = document.getElementById(btn.getAttribute('data-target'));
            if (target) target.type = target.type === 'password' ? 'text' : 'password';
        });
    });

    // restore UI state after PostBack / initial load
    var _showInvalid = document.getElementById('ShowInvalid');
    var _showSuccess = document.getElementById('ShowSuccess');
    var _serverError = document.getElementById('ServerError');

    function showOnly(card) {
        formCard.classList.add('hidden');
        invalidCard.classList.add('hidden');
        successCard.classList.add('hidden');
        card.classList.remove('hidden');
    }

    if (_showSuccess && _showSuccess.value === 'true') {
        showOnly(successCard);
        backRow.classList.add('hidden');
        heading.textContent = 'All done';
        subtitle.textContent = 'Your password has been updated.';
    } else if (_showInvalid && _showInvalid.value === 'true') {
        showOnly(invalidCard);
        heading.textContent = 'Reset link expired';
        subtitle.textContent = 'Request a fresh link to reset your password.';
    } else if (_serverError && _serverError.value) {
        resetErrorText.textContent = _serverError.value;
        resetError.classList.remove('hidden');
        resetError.classList.add('flex');
    }
})();
