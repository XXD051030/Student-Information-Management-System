(function () {
    function getInitialTab() {
        var match = location.search.match(/[?&]tab=([^&]+)/);
        if (match) {
            var t = decodeURIComponent(match[1]);
            if (['modules', 'announcements', 'assignments', 'grades'].indexOf(t) !== -1) return t;
        }
        return 'modules';
    }

    function activate(tab) {
        var panes = document.querySelectorAll('[data-pane]');
        for (var i = 0; i < panes.length; i++) {
            panes[i].classList.toggle('hidden', panes[i].getAttribute('data-pane') !== tab);
        }
        var buttons = document.querySelectorAll('[data-action="switch-tab"]');
        for (var j = 0; j < buttons.length; j++) {
            buttons[j].setAttribute('data-active', buttons[j].getAttribute('data-tab') === tab ? 'true' : 'false');
        }
    }

    activate(getInitialTab());

    var btns = document.querySelectorAll('[data-action="switch-tab"]');
    for (var k = 0; k < btns.length; k++) {
        btns[k].addEventListener('click', function (e) {
            activate(e.currentTarget.getAttribute('data-tab'));
        });
    }
})();
