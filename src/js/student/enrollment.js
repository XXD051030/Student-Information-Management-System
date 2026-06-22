// Course enrollment page: live selection totals + persist on "Proceed to Payment".
// Each enrollable <article data-course-row> carries:
//   data-credits   – integer credit hours
//   data-fee       – fee for this course (credits * rate)
// and contains a checkbox [data-action="toggle-enroll"][data-offering="<id>"].

function post(url, body) {
    return fetch(url, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json; charset=utf-8' },
        body: JSON.stringify(body)
    }).then(function (r) { return r.json(); }).then(function (json) {
        return json.d || json;
    });
}

(function () {
    "use strict";

    function rows() {
        return Array.prototype.slice.call(document.querySelectorAll("[data-course-row]"));
    }

    function checkbox(row) {
        return row.querySelector('[data-action="toggle-enroll"]');
    }

    function selectedRows() {
        return rows().filter(function (row) {
            var cb = checkbox(row);
            return cb && cb.checked;
        });
    }

    function setText(id, value) {
        var el = document.getElementById(id);
        if (el) el.textContent = value;
    }

    // Per-semester credit bounds, rendered onto #enroll-credits from the DB.
    function limits() {
        var el = document.getElementById("enroll-credits");
        var min = el ? parseInt(el.getAttribute("data-min-credits"), 10) : NaN;
        var max = el ? parseInt(el.getAttribute("data-max-credits"), 10) : NaN;
        return {
            min: isNaN(min) ? 0 : min,
            max: isNaN(max) ? Infinity : max
        };
    }

    function selectedCredits() {
        return selectedRows().reduce(function (sum, row) {
            return sum + (parseInt(row.getAttribute("data-credits"), 10) || 0);
        }, 0);
    }

    function recompute() {
        var selected = selectedRows();
        var count = selected.length;
        var credits = 0;
        var fee = 0;
        selected.forEach(function (row) {
            credits += parseInt(row.getAttribute("data-credits"), 10) || 0;
            fee += parseFloat(row.getAttribute("data-fee")) || 0;
        });

        setText("enroll-count", count);
        setText("enroll-credits", credits);
        setText("enroll-total", fee);
        setText("enroll-count-footer", count);
        setText("enroll-credits-footer", credits);
        setText("enroll-total-footer", fee.toFixed(2));

        var submit = document.getElementById("enroll-submit");
        if (submit) {
            var lim = limits();
            var enabled = count > 0 && credits >= lim.min && credits <= lim.max;
            submit.disabled = !enabled;
            submit.classList.toggle("bg-slate-100", !enabled);
            submit.classList.toggle("text-slate-400", !enabled);
            submit.classList.toggle("cursor-not-allowed", !enabled);
            submit.classList.toggle("bg-[#e0162b]", enabled);
            submit.classList.toggle("text-white", enabled);
            submit.classList.toggle("hover:bg-[#a01020]", enabled);
        }
    }

    function selectedOfferingIds() {
        return selectedRows().map(function (row) {
            return parseInt(checkbox(row).getAttribute("data-offering"), 10);
        }).filter(function (n) { return !isNaN(n); });
    }

    function proceed() {
        var selected = selectedRows();
        if (selected.length === 0) return;

        var payload = selected.map(function (row) {
            var cb = checkbox(row);
            return {
                offerId: parseInt(cb.getAttribute("data-offering"), 10),
                code: row.getAttribute("data-code") || "",
                name: row.getAttribute("data-name") || "",
                credits: parseInt(row.getAttribute("data-credits"), 10) || 0,
                fee: parseFloat(row.getAttribute("data-fee")) || 0
            };
        }).filter(function (r) { return !isNaN(r.offerId); });

        try {
            sessionStorage.setItem("sims:enrolled", JSON.stringify(payload));
        } catch (e) { /* ignore storage errors */ }

        window.location = "payment.aspx";
    }

    document.addEventListener("change", function (e) {
        if (e.target && e.target.matches('[data-action="toggle-enroll"]')) {
            // Block selections that would push the student over the credit cap.
            if (e.target.checked && selectedCredits() > limits().max) {
                e.target.checked = false;
                alert("You can register for at most " + limits().max + " credits this semester.");
                return;
            }
            recompute();
        }
    });

    document.addEventListener("click", function (e) {
        var btn = e.target.closest ? e.target.closest('[data-action="proceed-to-payment"]') : null;
        if (btn) {
            e.preventDefault();
            proceed();
        }
    });

    // Phase 2: Request Add
    document.addEventListener("click", function (e) {
        var btn = e.target.closest ? e.target.closest('[data-action="request-add"]') : null;
        if (!btn) return;
        btn.disabled = true;
        post("enrollment.aspx/RequestAdd", { offeringId: parseInt(btn.dataset.offering, 10) })
            .then(function (res) {
                if (res && res.ok) {
                    location.reload();
                } else {
                    alert("Could not submit add request. Please try again.");
                    btn.disabled = false;
                }
            })
            .catch(function () {
                alert("Network error. Please try again.");
                btn.disabled = false;
            });
    });

    // Phase 2: Request Drop
    document.addEventListener("click", function (e) {
        var btn = e.target.closest ? e.target.closest('[data-action="request-drop"]') : null;
        if (!btn) return;
        var code = btn.dataset.code || "this course";
        if (!confirm("Request to drop " + code + "? This will be sent to admin for review.")) return;
        btn.disabled = true;
        post("enrollment.aspx/RequestDrop", { offeringId: parseInt(btn.dataset.offering, 10) })
            .then(function (res) {
                if (res && res.ok) {
                    location.reload();
                } else {
                    alert("Could not submit drop request. Please try again.");
                    btn.disabled = false;
                }
            })
            .catch(function () {
                alert("Network error. Please try again.");
                btn.disabled = false;
            });
    });

    recompute();
})();
