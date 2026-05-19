(function () {
    var buttons = document.querySelectorAll('[data-action="toggle-read"]');
    var unreadEl = document.getElementById('unread-count');

    function recount() {
        var n = 0;
        for (var i = 0; i < buttons.length; i++) {
            if (buttons[i].getAttribute('data-read') !== 'true') n++;
        }
        if (unreadEl) unreadEl.textContent = n;
    }

    for (var j = 0; j < buttons.length; j++) {
        buttons[j].addEventListener('click', function (e) {
            var btn = e.currentTarget;
            btn.setAttribute('data-read', btn.getAttribute('data-read') === 'true' ? 'false' : 'true');
            recount();
        });
    }

    recount();
})();
