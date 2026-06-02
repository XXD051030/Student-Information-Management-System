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
    var pwErrorText = document.getElementById('pw-error-text');
    var pwHelper = document.getElementById('pw-helper');
    var pwCard = document.getElementById('password-card');
    var pwLabel = document.getElementById('pw-label');

    var heading = document.getElementById('login-heading');
    var subtitle = document.getElementById('login-subtitle');
    var emailChip = document.getElementById('email-chip');

    // inti email regex
    var emailRegex = /^[^\s@]+@(student\.|lecturer\.)?newinti\.edu\.my$/i;

    // move the email label to the top
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

    // enable and disable the submit button, determine by user input 
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

    // main function tjhat move the email label to top and if wrong email format
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


    var emailErrorText = document.getElementById('email-error-text');
    var emailSubmitArrow = document.getElementById('email-submit-arrow');
    var emailSubmitSpinner = document.getElementById('email-submit-spinner');

    // show email error message
    function showEmailError(message) {
        emailErrorText.textContent = message;
        emailError.classList.remove('hidden');
        emailError.classList.add('flex');
        emailHelper.classList.add('hidden');
    }

    // show spinner when loading and hide arrow
    function setEmailSubmitLoading(loading) {
        if (loading) {
            emailSubmitArrow.classList.add('hidden');
            emailSubmitArrow.classList.remove('inline-flex');
            emailSubmitSpinner.classList.remove('hidden');
            emailSubmitSpinner.classList.add('inline-flex');
        } else {
            emailSubmitSpinner.classList.add('hidden');
            emailSubmitSpinner.classList.remove('inline-flex');
            emailSubmitArrow.classList.remove('hidden');
            emailSubmitArrow.classList.add('inline-flex');
        }
    }

    // handle email submit, send email to server and check if email exist in database, 
    // if exist move to password input, if not show error message
    emailSubmit.addEventListener('click', function (e) {
        e.preventDefault();

        var email = emailInput.value.trim();
        if (!emailRegex.test(email)) return;

        setSubmitEnabled(emailSubmit, false);
        setEmailSubmitLoading(true);

        fetch('/shared/login.aspx/CheckEmail', {
            method: 'POST',
            headers: { 'Content-Type': 'application/json; charset=utf-8' },
            body: JSON.stringify({ email: email })
        })
            .then(function (resp) {
                if (resp.status === 404) {
                    showEmailError('No account found for this email.');
                    setSubmitEnabled(emailSubmit, true);
                    setEmailSubmitLoading(false);
                    return;
                }
                if (!resp.ok) {
                    throw new Error('HTTP ' + resp.status);
                }
                setTimeout(function () {
                    emailChip.textContent = email;
                    emailCard.classList.add('hidden');
                    pwCard.classList.remove('hidden');
                    heading.textContent = 'Enter your password';
                    subtitle.textContent = "Confirm it's you to continue to your portal.";
                    setEmailSubmitLoading(false);
                    pwInput.focus();
                }, 1000);
            })
            .catch(function () {
                showEmailError('Could not reach server. Try again.');
                setSubmitEnabled(emailSubmit, true);
                setEmailSubmitLoading(false);
            });
    });

    // handle back to email button, move back to email input
    document.querySelector('[data-action="back-to-email"]').addEventListener('click', function () {
        pwCard.classList.add('hidden');
        emailCard.classList.remove('hidden');
        heading.textContent = 'Welcome back';
        subtitle.textContent = 'Sign in to access your INTI portal.';
        pwInput.value = '';
        setSubmitEnabled(pwSubmit, false);
        setSubmitEnabled(emailSubmit, emailRegex.test(emailInput.value.trim()));
        setTimeout(function () { emailInput.focus(); }, 0);
    });


    // handle toggle password visibility
    document.querySelector('[data-action="toggle-pw"]').addEventListener('click', function () {
        pwInput.type = pwInput.type === 'password' ? 'text' : 'password';
    });


    //  determine the password input 
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


    function showPasswordError(message) {
        pwErrorText.textContent = message;
        pwError.classList.remove('hidden');
        pwError.classList.add('flex');
        pwHelper.classList.add('hidden');
    }

    // handle password submit, send email and password to server and check if correct
    pwSubmit.addEventListener('click', function () {
        if (pwInput.value.length < 6) return;

        var email = emailInput.value.trim();
        var password = pwInput.value;
        var remember = document.getElementById('remember').checked;

        pwSubmitLabel.textContent = 'Signing in…';
        setSubmitEnabled(pwSubmit, false);

        fetch('/shared/login.aspx/VerifyPassword', {
            method: 'POST',
            headers: { 'Content-Type': 'application/json; charset=utf-8' },
            body: JSON.stringify({ email: email, password: password, remember: remember })
        })
            .then(function (resp) {
                if (resp.status === 401) {
                    showPasswordError('Incorrect password.');
                    pwSubmitLabel.textContent = 'Sign in';
                    setSubmitEnabled(pwSubmit, true);
                    return;
                }
                if (!resp.ok) {
                    throw new Error('HTTP ' + resp.status);
                }
                return resp.json().then(function (data) {
                    // ASP.NET page methods wrap the payload in { "d": ... }
                    var result = (data && typeof data.d !== 'undefined') ? data.d : data;
                    if (result && result.redirect) {
                        window.location.href = result.redirect;
                    } else {
                        showPasswordError('Could not determine where to go. Try again.');
                        pwSubmitLabel.textContent = 'Sign in';
                        setSubmitEnabled(pwSubmit, true);
                    }
                });
            })
            .catch(function () {
                showPasswordError('Could not reach server. Try again.');
                pwSubmitLabel.textContent = 'Sign in';
                setSubmitEnabled(pwSubmit, true);
            });
    });


})();
