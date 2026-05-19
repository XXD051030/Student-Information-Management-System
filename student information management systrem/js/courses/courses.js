(function () {
    var STORAGE_KEY = 'sims:pinned-courses';

    function loadPinned() {
        try {
            var raw = localStorage.getItem(STORAGE_KEY);
            return raw ? JSON.parse(raw) : ['CSC2104', 'CSC2103', 'MTH2101', 'ENG2001'];
        } catch (e) {
            return [];
        }
    }
    function savePinned(arr) {
        try { localStorage.setItem(STORAGE_KEY, JSON.stringify(arr)); } catch (e) {}
    }

    function renderStar(button, pinned) {
        var icon = button.querySelector('[data-pinned-icon]');
        if (pinned) {
            icon.classList.add('text-amber-500', 'fill-amber-500');
            icon.classList.remove('text-slate-400');
        } else {
            icon.classList.add('text-slate-400');
            icon.classList.remove('text-amber-500', 'fill-amber-500');
        }
    }

    var pinned = loadPinned();
    var buttons = document.querySelectorAll('[data-action="toggle-pin"]');
    for (var i = 0; i < buttons.length; i++) {
        (function (btn) {
            var code = btn.getAttribute('data-code');
            renderStar(btn, pinned.indexOf(code) !== -1);
            btn.addEventListener('click', function () {
                var idx = pinned.indexOf(code);
                if (idx === -1) pinned.push(code);
                else pinned.splice(idx, 1);
                savePinned(pinned);
                renderStar(btn, pinned.indexOf(code) !== -1);
            });
        })(buttons[i]);
    }

    var search = document.getElementById('course-search');

    // Semester filter
    var filterBtns = document.querySelectorAll('[data-action="filter-semester"]');
    var activeSemester = 'All semesters';
    for (var k = 0; k < filterBtns.length; k++) {
        (function (fb) {
            fb.addEventListener('click', function () {
                activeSemester = fb.getAttribute('data-semester');
                // Update button styles
                for (var m = 0; m < filterBtns.length; m++) {
                    var isActive = filterBtns[m].getAttribute('data-semester') === activeSemester;
                    filterBtns[m].className = isActive
                        ? 'rounded-full px-3.5 py-1.5 bg-slate-900 text-white transition-all'
                        : 'rounded-full px-3.5 py-1.5 border border-slate-200 bg-white text-slate-600 hover:border-slate-300 hover:text-slate-900 transition-all';
                    filterBtns[m].style.fontSize = '12.5px';
                    filterBtns[m].style.fontWeight = '600';
                }
                applyFilters();
            });
        })(filterBtns[k]);
    }

    function applyFilters() {
        var q = search ? search.value.toLowerCase().trim() : '';
        var cards = document.querySelectorAll('[data-course-code]');
        var anyVisible = false;
        for (var n = 0; n < cards.length; n++) {
            var sem = (cards[n].getAttribute('data-semester') || '');
            var hay = (cards[n].getAttribute('data-search') || '').toLowerCase();
            var semOk = activeSemester === 'All semesters' || sem === activeSemester;
            var qOk = q.length === 0 || hay.indexOf(q) !== -1;
            var show = semOk && qOk;
            cards[n].classList.toggle('hidden', !show);
            if (show) anyVisible = true;
        }
        var noResults = document.getElementById('no-results');
        if (noResults) noResults.classList.toggle('hidden', anyVisible);
    }

    if (search) {
        search.addEventListener('input', applyFilters);
    }
})();
