(function () {
    var emailInput = document.getElementById('email');
    var sendSubmit = document.getElementById('send_submit');
    var emailError = document.getElementById('email-error');
    var emailErrorText = document.getElementById('email-error-text');
    var emailHelper = document.getElementById('email-helper');
    var emailLabel = document.getElementById('email-label');

    var requestCard = document.getElementById('request-card');
    var sentCard = document.getElementById('sent-card');
    var heading = document.getElementById('forgot-heading');
    var subtitle = document.getElementById('forgot-subtitle');

    var sendArrow = document.getElementById('send-arrow');
    var sendSpinner = document.getElementById('send-spinner');

    // accept any normal email here; the server confirms whether an account exists
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
        } else {
            btn.disabled = true;
            btn.className = 'mt-6 group flex w-full items-center justify-center gap-2 rounded-xl px-4 transition-all h-12 bg-indigo-300 text-white cursor-not-allowed';
        }
        btn.style.fontSize = '15px';
        btn.style.fontWeight = '600';
    }

    emailInput.addEventListener('input', function () {
        var value = emailInput.value.trim();
        var valid = emailRegex.test(value);
        setSubmitEnabled(sendSubmit, valid);
        if (value.length > 0 && !valid) {
            emailErrorText.textContent = 'Please enter a valid email.';
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

    // show the spinner while the postback is in flight
    sendSubmit.addEventListener('click', function () {
        if (sendSubmit.disabled) return;
        sendArrow.classList.add('hidden');
        sendArrow.classList.remove('inline-flex');
        sendSpinner.classList.remove('hidden');
        sendSpinner.classList.add('inline-flex');
    });

    // restore UI state after PostBack
    var _showSent = document.getElementById('ShowSent');
    var _serverError = document.getElementById('ServerError');

    if (_showSent && _showSent.value === 'true') {
        requestCard.classList.add('hidden');
        sentCard.classList.remove('hidden');
        heading.textContent = 'Reset link sent';
        subtitle.textContent = 'Follow the link in your email to choose a new password.';
    }
    if (_serverError && _serverError.value) {
        emailErrorText.textContent = _serverError.value;
        emailError.classList.remove('hidden');
        emailError.classList.add('flex');
        emailHelper.classList.add('hidden');
    }
})();
