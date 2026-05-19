(function () {
    var filterButtons = document.querySelectorAll('[data-action="filter"]');
    var rows = document.querySelectorAll('[data-row]');
    var current = 'all';

    function applyFilter() {
        for (var i = 0; i < rows.length; i++) {
            var status = rows[i].getAttribute('data-status');
            rows[i].classList.toggle('hidden', current !== 'all' && current !== status);
        }
        for (var j = 0; j < filterButtons.length; j++) {
            filterButtons[j].setAttribute('data-active', filterButtons[j].getAttribute('data-status') === current ? 'true' : 'false');
        }
    }

    for (var k = 0; k < filterButtons.length; k++) {
        filterButtons[k].addEventListener('click', function (e) {
            current = e.currentTarget.getAttribute('data-status');
            applyFilter();
        });
    }

    var openLinks = document.querySelectorAll('[data-action="open-assignment"]');
    for (var m = 0; m < openLinks.length; m++) {
        openLinks[m].addEventListener('click', function (e) {
            e.preventDefault();
            var code = e.currentTarget.getAttribute('data-course-code');
            window.location.href = 'course-detail.aspx?tab=assignments&code=' + encodeURIComponent(code);
        });
    }

    applyFilter();
})();
