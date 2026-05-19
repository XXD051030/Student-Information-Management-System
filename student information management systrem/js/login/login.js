(function () {
    var emailInput = document.getElementById('email');
    var emailSubmit = document.getElementById('email-submit');
    var emailError = document.getElementById('email-error');
    var emailHelper = document.getElementById('email-helper');
    var emailCard = document.getElementById('email-card');
    var emailLabel = document.getElementById('email-label');

    var pwInput = document.getElementById('password');
    var pwSubmit = document.getElementById('pw-submit');
    var pwSubmitLabel = document.getElementById('pw-submit-label');
    var pwError = document.getElementById('pw-error');
    var pwHelper = document.getElementById('pw-helper');
    var pwCard = document.getElementById('password-card');
    var pwLabel = document.getElementById('pw-label');
    var pwEye = document.getElementById('pw-eye');

    var heading = document.getElementById('login-heading');
    var subtitle = document.getElementById('login-subtitle');
    var emailChip = document.getElementById('email-chip');

    var emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;

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
            btn.className = 'mt-6 group flex w-full items-center justify-center gap-2 rounded-xl px-4 transition-all h-12 bg-gradient-to-r from-indigo-600 to-indigo-700 text-white shadow-[0_8px_20px_-8px_rgba(79,70,229,0.6)] hover:from-indigo-700 hover:to-indigo-800 active:scale-[0.99]';
            btn.style.fontSize = '15px';
            btn.style.fontWeight = '600';
        } else {
            btn.disabled = true;
            btn.className = 'mt-6 group flex w-full items-center justify-center gap-2 rounded-xl px-4 transition-all h-12 bg-indigo-300 text-white cursor-not-allowed';
            btn.style.fontSize = '15px';
            btn.style.fontWeight = '600';
        }
    }

    emailInput.addEventListener('input', function () {
        var value = emailInput.value.trim();
        var valid = emailRegex.test(value);
        setSubmitEnabled(emailSubmit, valid);
        if (value.length > 0 && !valid) {
            emailError.classList.remove('hidden');
            emailError.classList.add('flex');
            emailHelper.classList.add('hidden');
        } else {
            emailError.classList.add('hidden');
            emailError.classList.remove('flex');
            emailHelper.classList.remove('hidden');
        }
        setLabelFloating(emailLabel, emailInput === document.activeElement || value.length > 0);
    });
    emailInput.addEventListener('focus', function () { setLabelFloating(emailLabel, true); });
    emailInput.addEventListener('blur', function () { setLabelFloating(emailLabel, emailInput.value.length > 0); });

    document.getElementById('email-form').addEventListener('submit', function () {
        if (!emailRegex.test(emailInput.value.trim())) return;
        emailChip.textContent = emailInput.value.trim();
        emailCard.classList.add('hidden');
        pwCard.classList.remove('hidden');
        heading.textContent = 'Enter your password';
        subtitle.textContent = "Confirm it's you to continue to your portal.";
        setTimeout(function () { pwInput.focus(); }, 0);
    });

    document.querySelector('[data-action="back-to-email"]').addEventListener('click', function () {
        pwCard.classList.add('hidden');
        emailCard.classList.remove('hidden');
        heading.textContent = 'Welcome back';
        subtitle.textContent = 'Sign in to access your INTI portal.';
        pwInput.value = '';
        setSubmitEnabled(pwSubmit, false);
        setTimeout(function () { emailInput.focus(); }, 0);
    });

    document.querySelector('[data-action="toggle-pw"]').addEventListener('click', function () {
        if (pwInput.type === 'password') {
            pwInput.type = 'text';
            pwEye.setAttribute('data-lucide', 'eye-off');
        } else {
            pwInput.type = 'password';
            pwEye.setAttribute('data-lucide', 'eye');
        }
        if (window.lucide) lucide.createIcons();
    });

    pwInput.addEventListener('input', function () {
        var valid = pwInput.value.length >= 6;
        setSubmitEnabled(pwSubmit, valid);
        if (pwInput.value.length > 0 && !valid) {
            pwError.classList.remove('hidden');
            pwError.classList.add('flex');
            pwHelper.classList.add('hidden');
        } else {
            pwError.classList.add('hidden');
            pwError.classList.remove('flex');
            pwHelper.classList.remove('hidden');
        }
        setLabelFloating(pwLabel, pwInput === document.activeElement || pwInput.value.length > 0);
    });
    pwInput.addEventListener('focus', function () { setLabelFloating(pwLabel, true); });
    pwInput.addEventListener('blur', function () { setLabelFloating(pwLabel, pwInput.value.length > 0); });

    document.getElementById('password-form').addEventListener('submit', function () {
        if (pwInput.value.length < 6) return;
        pwSubmitLabel.textContent = 'Signing in…';
        pwSubmit.disabled = true;
        setTimeout(function () { window.location.href = 'dashboard.aspx'; }, 900);
    });
})();
