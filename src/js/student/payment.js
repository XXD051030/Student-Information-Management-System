(function () {
    var rowsEl = document.getElementById('payment-rows');
    var emptyEl = document.getElementById('payment-empty');
    var subtotalEl = document.getElementById('pay-subtotal');
    var taxEl = document.getElementById('pay-tax');
    var totalEl = document.getElementById('pay-total');

    var rows = [];
    try {
        var raw = sessionStorage.getItem('sims:enrolled');
        rows = raw ? JSON.parse(raw) : [];
    } catch (e) {
        rows = [];
    }

    if (rows.length === 0) {
        if (emptyEl) emptyEl.classList.remove('hidden');
        if (rowsEl) {
            var emptyTr = document.createElement('tr');
            emptyTr.innerHTML = '<td colspan="4" class="px-6 py-12 text-center text-slate-400" style="font-size:13px">No courses selected.</td>';
            rowsEl.appendChild(emptyTr);
        }
    } else {
        if (emptyEl) emptyEl.classList.add('hidden');
        var subtotal = 0;
        for (var i = 0; i < rows.length; i++) {
            var r = rows[i];
            subtotal += r.fee;
            var tr = document.createElement('tr');
            tr.className = 'border-t border-slate-100';
            tr.innerHTML =
                '<td class="px-6 py-4 text-slate-900" style="font-size:13.5px;font-weight:600">' + escapeHtml(r.code) + '</td>' +
                '<td class="px-6 py-4 text-slate-700" style="font-size:13px">' + escapeHtml(r.name) + '</td>' +
                '<td class="px-6 py-4 text-slate-500" style="font-size:13px">' + r.credits + '</td>' +
                '<td class="px-6 py-4 text-right text-slate-900" style="font-size:13.5px;font-weight:600">RM ' + r.fee.toFixed(2) + '</td>';
            rowsEl.appendChild(tr);
        }
        var tax = subtotal * 0.06;
        if (subtotalEl) subtotalEl.textContent = subtotal.toFixed(2);
        if (taxEl) taxEl.textContent = tax.toFixed(2);
        if (totalEl) totalEl.textContent = (subtotal + tax).toFixed(2);

        // Also update aside total and pay button amount
        var totalAside = document.getElementById('pay-total-aside');
        var payBtnAmount = document.getElementById('pay-btn-amount');
        if (totalAside) totalAside.textContent = (subtotal + tax).toFixed(2);
        if (payBtnAmount) payBtnAmount.textContent = (subtotal + tax).toFixed(2);

        var grandTotal = (subtotal + tax).toFixed(2);
        setHidden('hfAmount', grandTotal);
        setHidden('hfDescription', 'Tuition — Y2 T2 2025/26');
        setHidden('hfOfferingIds', rows.map(function (r) { return r.offerId; }).join(','));
    }

    function escapeHtml(s) {
        return String(s).replace(/[&<>"']/g, function (c) {
            return { '&': '&amp;', '<': '&lt;', '>': '&gt;', '"': '&quot;', "'": '&#39;' }[c];
        });
    }

    var radios = document.querySelectorAll('input[name="payment-method"]');
    function syncPanels() {
        var current = 'card';
        for (var i = 0; i < radios.length; i++) {
            if (radios[i].checked) { current = radios[i].value; break; }
        }
        setHidden('hfMethod', current);
        var panels = document.querySelectorAll('[data-method-panel]');
        for (var j = 0; j < panels.length; j++) {
            panels[j].classList.toggle('hidden', panels[j].getAttribute('data-method-panel') !== current);
        }
        // Update label ring styles to reflect active selection
        var labels = document.querySelectorAll('label:has(input[name="payment-method"])');
        for (var l = 0; l < labels.length; l++) {
            var radio = labels[l].querySelector('input[name="payment-method"]');
            var dot = labels[l].querySelector('span.rounded-full');
            if (!radio) continue;
            var isActive = radio.value === current;
            labels[l].classList.toggle('border-[#e0162b]', isActive);
            labels[l].classList.toggle('bg-[#e0162b]/5', isActive);
            labels[l].classList.toggle('ring-4', isActive);
            labels[l].classList.toggle('ring-[#e0162b]/10', isActive);
            labels[l].classList.toggle('border-slate-200', !isActive);
            var icon = labels[l].querySelector('.flex.h-9');
            if (icon) {
                icon.classList.toggle('bg-[#e0162b]', isActive);
                icon.classList.toggle('text-white', isActive);
                icon.classList.toggle('bg-slate-100', !isActive);
                icon.classList.toggle('text-slate-600', !isActive);
            }
            if (dot) {
                dot.classList.toggle('border-[#e0162b]', isActive);
                dot.classList.toggle('bg-[#e0162b]', isActive);
                dot.classList.toggle('border-slate-300', !isActive);
            }
        }
    }
    for (var k = 0; k < radios.length; k++) radios[k].addEventListener('change', syncPanels);
    syncPanels();

    function setHidden(idSuffix, value) {
        var el = document.querySelector('input[type="hidden"][id$="' + idSuffix + '"]');
        if (el) el.value = value;
    }
})();
