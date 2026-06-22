(function () {
    var button = document.getElementById('btnDownloadLecturerPdf');
    if (!button) return;

    button.addEventListener('click', function () {
        if (!window.jspdf || !window.jspdf.jsPDF) {
            alert('PDF generator is not available.');
            return;
        }

        var original = button.innerHTML;
        button.innerHTML = 'Generating PDF...';
        button.disabled = true;
        try {
            createPdf();
        } finally {
            button.innerHTML = original;
            button.disabled = false;
            if (window.lucide) window.lucide.createIcons();
        }
    });

    function createPdf() {
        var data = window.lecturerTimetableData || {};
        var events = Array.isArray(data.events) ? data.events : [];
        var jsPDF = window.jspdf.jsPDF;
        var doc = new jsPDF({ orientation: 'landscape', unit: 'mm', format: 'a3' });
        var days = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday'];
        var startHour = Math.floor(timeValue(data.slotMinTime || '08:00'));
        var endHour = Math.ceil(timeValue(data.slotMaxTime || '18:00'));
        if (endHour <= startHour) endHour = startHour + 1;

        var margin = 10;
        var titleHeight = 18;
        var timeWidth = 20;
        var headerHeight = 12;
        var width = doc.internal.pageSize.getWidth();
        var height = doc.internal.pageSize.getHeight();
        var gridX = margin + timeWidth;
        var gridY = margin + titleHeight + headerHeight;
        var gridWidth = width - (margin * 2) - timeWidth;
        var gridHeight = height - (margin * 2) - titleHeight - headerHeight;
        var columnWidth = gridWidth / days.length;
        var hourHeight = gridHeight / (endHour - startHour);

        doc.setFont('helvetica', 'bold');
        doc.setFontSize(17);
        doc.setTextColor(15, 23, 42);
        doc.text('Lecturer Timetable', margin, margin + 7);
        doc.setFont('helvetica', 'normal');
        doc.setFontSize(9);
        doc.setTextColor(100, 116, 139);
        doc.text('Weekly teaching schedule', margin, margin + 14);

        doc.setFillColor(248, 250, 252);
        doc.setDrawColor(226, 232, 240);
        doc.rect(gridX, margin + titleHeight, gridWidth, headerHeight, 'FD');
        doc.setFont('helvetica', 'bold');
        doc.setFontSize(9);
        doc.setTextColor(15, 23, 42);
        days.forEach(function (day, index) {
            var x = gridX + (index * columnWidth);
            doc.rect(x, margin + titleHeight, columnWidth, headerHeight);
            doc.text(day, x + (columnWidth / 2), margin + titleHeight + 7.5, { align: 'center' });
        });

        doc.setFont('helvetica', 'normal');
        doc.setFontSize(7);
        doc.setTextColor(100, 116, 139);
        for (var hour = startHour; hour <= endHour; hour++) {
            var y = gridY + ((hour - startHour) * hourHeight);
            doc.line(gridX, y, gridX + gridWidth, y);
            if (hour < endHour) doc.text(formatHour(hour), margin + 2, y + 3);
        }
        for (var column = 0; column <= days.length; column++) {
            var lineX = gridX + (column * columnWidth);
            doc.line(lineX, gridY, lineX, gridY + gridHeight);
        }

        events.forEach(function (event) {
            var day = Number((event.daysOfWeek || [0])[0]) - 1;
            if (day < 0 || day > 4) return;
            drawEvent(doc, event, day, gridX, gridY, columnWidth, hourHeight, startHour, endHour);
        });

        doc.save('Lecturer_Timetable.pdf');
    }

    function drawEvent(doc, event, day, gridX, gridY, columnWidth, hourHeight, startHour, endHour) {
        var start = timeValue(event.startTime);
        var end = timeValue(event.endTime);
        if (end <= startHour || start >= endHour) return;

        start = Math.max(start, startHour);
        end = Math.min(end, endHour);
        var x = gridX + (day * columnWidth) + 2;
        var y = gridY + ((start - startHour) * hourHeight) + 2;
        var w = columnWidth - 4;
        var h = Math.max(12, ((end - start) * hourHeight) - 4);
        var props = event.extendedProps || {};
        var rgb = colorToRgb(props.color || event.borderColor || '#e0162b');

        doc.setFillColor(light(rgb.r), light(rgb.g), light(rgb.b));
        doc.setDrawColor(rgb.r, rgb.g, rgb.b);
        doc.roundedRect(x, y, w, h, 2, 2, 'FD');
        doc.setFillColor(rgb.r, rgb.g, rgb.b);
        doc.roundedRect(x + 3, y + 3, 18, 5, 1, 1, 'F');
        doc.setFont('helvetica', 'bold');
        doc.setFontSize(8);
        doc.setTextColor(255, 255, 255);
        doc.text(String(props.code || ''), x + 12, y + 6.5, { align: 'center' });

        doc.setTextColor(15, 23, 42);
        doc.setFontSize(9);
        var title = doc.splitTextToSize(String(event.title || 'Class'), w - 6);
        doc.text(title.slice(0, 2), x + 3, y + 13);
        doc.setFont('helvetica', 'normal');
        doc.setFontSize(8);
        doc.setTextColor(71, 85, 105);
        doc.text('Room: ' + String(props.room || 'TBA'), x + 3, y + Math.min(h - 4, 23));
    }

    function timeValue(value) {
        var parts = String(value || '0:0').split(':');
        return Number(parts[0]) + (Number(parts[1]) / 60);
    }

    function formatHour(hour) {
        var suffix = hour >= 12 ? 'PM' : 'AM';
        var display = hour % 12 || 12;
        return display + ':00 ' + suffix;
    }

    function colorToRgb(color) {
        var hex = String(color || '').replace('#', '').substring(0, 6);
        var value = parseInt(hex, 16);
        return isNaN(value)
            ? { r: 224, g: 22, b: 43 }
            : { r: (value >> 16) & 255, g: (value >> 8) & 255, b: value & 255 };
    }

    function light(value) {
        return Math.round(value + ((255 - value) * 0.9));
    }
})();
