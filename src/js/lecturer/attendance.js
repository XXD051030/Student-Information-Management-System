document.addEventListener('DOMContentLoaded', function () {
    const calendarEl = document.getElementById('lecturerTimetable');

    if (!calendarEl || typeof FullCalendar === 'undefined') {
        return;
    }

    const data = window.lecturerTimetableData || {};
    const events = Array.isArray(data.events) ? data.events : [];

    // Pre-count classes per weekday (0=Sun..6=Sat) so each day header can show
    // its class count, matching the mockup.
    const countsByDay = {};
    events.forEach(function (ev) {
        const days = Array.isArray(ev.daysOfWeek) ? ev.daysOfWeek : [];
        days.forEach(function (d) { countsByDay[d] = (countsByDay[d] || 0) + 1; });
    });

    function escapeHtml(value) {
        return String(value || '')
            .replace(/&/g, '&amp;')
            .replace(/</g, '&lt;')
            .replace(/>/g, '&gt;')
            .replace(/"/g, '&quot;')
            .replace(/'/g, '&#039;');
    }

    function formatTimeRange(event) {
        const options = { hour: 'numeric', minute: '2-digit', hour12: true };
        return `${event.start.toLocaleTimeString([], options)} - ${event.end.toLocaleTimeString([], options)}`;
    }

    const calendar = new FullCalendar.Calendar(calendarEl, {
        initialView: 'timeGridWeek',
        initialDate: data.initialDate || new Date().toISOString().slice(0, 10),
        firstDay: 1,
        weekends: data.weekends === true,
        allDaySlot: false,
        expandRows: true,
        height: 'auto',
        slotMinTime: data.slotMinTime || '08:00:00',
        slotMaxTime: data.slotMaxTime || '18:00:00',
        slotDuration: '01:00:00',
        slotLabelInterval: '01:00:00',
        nowIndicator: false,
        headerToolbar: false,
        dayHeaderFormat: { weekday: 'long' },
        slotLabelFormat: { hour: 'numeric', minute: '2-digit', hour12: true },
        eventTimeFormat: { hour: 'numeric', minute: '2-digit', hour12: true },
        events: events,
        dayHeaderContent: function (arg) {
            const n = countsByDay[arg.date.getDay()] || 0;
            return {
                html: `<div class="lt-dayname">${escapeHtml(arg.text)}</div>` +
                    `<div class="lt-daycount">${n} ${n === 1 ? 'class' : 'classes'}</div>`
            };
        },
        eventDidMount: function (info) {
            const color = info.event.extendedProps.color || '#e0162b';
            info.el.style.boxShadow = `inset 3px 0 0 ${color}`;
            info.el.style.cursor = 'default';
        },
        eventContent: function (arg) {
            const props = arg.event.extendedProps;
            const color = props.color || '#e0162b';
            const timeText = formatTimeRange(arg.event);

            return {
                html: `
                            <div class="tt-event">
                                <div class="tt-badges">
                                    <span class="tt-code" style="background:${escapeHtml(color)}">${escapeHtml(props.code)}</span>
                                    <span class="tt-type">${escapeHtml(props.type || 'Class')}</span>
                                </div>
                                <div class="tt-title">${escapeHtml(arg.event.title)}</div>
                                <div class="tt-meta">Room: ${escapeHtml(props.room)}</div>
                                <div class="tt-time">${escapeHtml(timeText)}</div>
                            </div>`
            };
        }
    });

    calendar.render();

    // Fonts, Lucide icons and the horizontal scrollbar can reflow the grid after
    // FullCalendar's initial measure, which desyncs the absolutely-positioned event
    // overlay from the time-axis grid lines (events drift upward, worse further down).
    // Force a re-measure once the layout has settled so the columns line up exactly.
    function syncCalendarSize() {
        calendar.updateSize();
    }
    requestAnimationFrame(syncCalendarSize);
    window.addEventListener('load', syncCalendarSize);
});
