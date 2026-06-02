<%@ Page Language="C#" MasterPageFile="~/shared/AdminLayout.master" AutoEventWireup="true" CodeBehind="student_detail.aspx.cs" Inherits="src.admin.student_detail" Title="Student Detail - INTI Admin Portal" %>
<asp:Content ContentPlaceHolderID="MainContent" runat="server">

    <a href="<%= ResolveUrl("~/academic_performance.aspx") %>" class="inline-flex items-center gap-1.5 text-slate-600 hover:text-[#a01020] transition-colors" style="font-size:13px;font-weight:600">
        <i data-lucide="arrow-left" class="h-4 w-4"></i> Back to Academic Performance
    </a>

    <div id="student-detail-root" class="mt-4"></div>

</asp:Content>
<asp:Content ContentPlaceHolderID="ScriptsPlaceholder" runat="server">
    <script src="<%= ResolveUrl("~/js/admin/shared/icons.js") %>"></script>
    <script src="<%= ResolveUrl("~/js/admin/shared/toast.js") %>"></script>
    <script src="<%= ResolveUrl("~/js/admin/shared/table.js") %>"></script>
    <script src="<%= ResolveUrl("~/js/admin/shared/ui.js") %>"></script>
    <script src="<%= ResolveUrl("~/js/admin/student-detail/students.js") %>"></script>
    <script>
      (function () {
        function qp(k) {
          var m = location.search.match(new RegExp("[?&]" + k + "=([^&]*)"));
          return m ? decodeURIComponent(m[1]) : "";
        }
        function esc(s) {
          return String(s == null ? "" : s).replace(/[&<>"']/g, function (c) {
            return { "&": "&amp;", "<": "&lt;", ">": "&gt;", '"': "&quot;", "'": "&#39;" }[c];
          });
        }
        function initials(name) {
          var parts = (name || "").split(" "), out = "";
          for (var i = 0; i < parts.length && out.length < 2; i++) if (parts[i]) out += parts[i][0];
          return out.toUpperCase();
        }
        function gradeTone(g) {
          if (g === "F") return "danger";
          if (g.charAt(0) === "A") return "success";
          if (g.charAt(0) === "D") return "danger";
          if (g.charAt(0) === "C") return "pending";
          return "neutral";
        }
        function badgeClass(tone) {
          var map = {
            success: "bg-emerald-50 text-emerald-700 border-emerald-100",
            pending: "bg-amber-50 text-amber-700 border-amber-100",
            danger:  "bg-[#e0162b]/10 text-[#a01020] border-[#e0162b]/20",
            neutral: "bg-slate-100 text-slate-600 border-slate-200",
            info:    "bg-sky-50 text-sky-700 border-sky-100"
          };
          return "inline-flex items-center gap-1 rounded-full border px-2 py-0.5 " + (map[tone] || map.neutral);
        }
        function statusFromCgpa(cgpa) {
          if (cgpa >= 3.7) return { label: "Dean's List",   tone: "success" };
          if (cgpa >= 3.0) return { label: "Good Standing", tone: "success" };
          if (cgpa >= 2.0) return { label: "Probation",     tone: "pending" };
          return { label: "At Risk", tone: "danger" };
        }
        function attendanceStatus(pct) {
          if (pct >= 85) return { label: "Healthy",  tone: "success" };
          if (pct >= 70) return { label: "Warning",  tone: "pending" };
          return { label: "Critical", tone: "danger" };
        }
        function courseAttendancePct(base, code) {
          var h = 0;
          for (var i = 0; i < code.length; i++) h = ((h * 31 + code.charCodeAt(i)) >>> 0);
          var offset = (h % 17) - 8;
          return Math.max(40, Math.min(100, base + offset));
        }
        function barColor(tone) { return tone === "success" ? "bg-emerald-500" : tone === "pending" ? "bg-amber-500" : "bg-[#e0162b]"; }
        function valColor(v) { return v < 2 ? "text-[#a01020]" : v >= 3.7 ? "text-emerald-600" : "text-slate-900"; }

        function cgpaChart(semesters) {
          if (!semesters.length) return "";
          var w = 720, h = 220, padL = 36, padR = 24, padT = 20, padB = 36;
          var innerW = w - padL - padR, innerH = h - padT - padB;
          var n = semesters.length;
          function y(v) { return padT + innerH - (v / 4) * innerH; }
          var xs = [];
          for (var i = 0; i < n; i++) xs.push(padL + (n === 1 ? innerW / 2 : (i * innerW) / (n - 1)));
          var lineCgpa = "", lineGpa = "";
          semesters.forEach(function (s, i) {
            lineCgpa += (i === 0 ? "M " : "L ") + xs[i] + " " + y(s.cgpa) + " ";
            lineGpa  += (i === 0 ? "M " : "L ") + xs[i] + " " + y(s.gpa) + " ";
          });
          var grid = "", labels = "", points = "";
          [0, 1, 2, 3, 4].forEach(function (g) {
            grid += '<line x1="' + padL + '" x2="' + (w - padR) + '" y1="' + y(g) + '" y2="' + y(g) + '" stroke="#f1f5f9" stroke-width="1" />' +
                    '<text x="' + (padL - 8) + '" y="' + (y(g) + 4) + '" text-anchor="end" font-size="10" fill="#94a3b8">' + g.toFixed(1) + '</text>';
          });
          semesters.forEach(function (s, i) {
            labels += '<text x="' + xs[i] + '" y="' + (h - padB + 18) + '" text-anchor="middle" font-size="11" fill="#64748b" font-weight="600">Sem ' + s.sem + '</text>';
            points += '<circle cx="' + xs[i] + '" cy="' + y(s.gpa)  + '" r="3.5" fill="#fff" stroke="#94a3b8" stroke-width="2" />' +
                      '<circle cx="' + xs[i] + '" cy="' + y(s.cgpa) + '" r="5"   fill="#fff" stroke="#e0162b" stroke-width="2.5" />';
          });
          return '<div class="w-full overflow-x-auto">' +
                   '<svg viewBox="0 0 ' + w + ' ' + h + '" class="w-full min-w-[640px]">' + grid + labels +
                     '<path d="' + lineGpa  + '" fill="none" stroke="#cbd5e1" stroke-width="2"   stroke-dasharray="4 4" />' +
                     '<path d="' + lineCgpa + '" fill="none" stroke="#e0162b" stroke-width="2.5" />' + points +
                   '</svg>' +
                   '<div class="mt-2 flex items-center gap-4 px-2 text-slate-500" style="font-size:12px">' +
                     '<span class="inline-flex items-center gap-1.5"><span class="h-0.5 w-5 bg-[#e0162b]"></span> CGPA</span>' +
                     '<span class="inline-flex items-center gap-1.5"><span class="h-0.5 w-5 border-t-2 border-dashed border-slate-300"></span> Semester GPA</span>' +
                   '</div>' +
                 '</div>';
        }

        function buildHtml(s) {
          var latest = s.semesters[s.semesters.length - 1] || { gpa: 0, cgpa: 0, term: "—" };
          var overall = latest.cgpa || 0;
          var status = statusFromCgpa(overall);
          var totalCredits = 0, totalCourses = 0;
          s.semesters.forEach(function (x) { x.courses.forEach(function (c) { totalCredits += c.credits; totalCourses++; }); });

          var html = "";

          // Header card
          html += '<section class="rounded-lg border border-slate-200 bg-white">' +
                    '<div class="flex flex-col gap-5 px-6 py-6 lg:flex-row lg:items-start lg:justify-between">' +
                      '<div class="flex items-start gap-4">' +
                        '<div class="flex h-16 w-16 shrink-0 items-center justify-center rounded-2xl bg-[#e0162b]/10 text-[#a01020]" style="font-size:22px;font-weight:700;letter-spacing:-0.01em">' + esc(initials(s.name)) + '</div>' +
                        '<div>' +
                          '<div class="flex flex-wrap items-center gap-2">' +
                            '<h1 class="text-slate-900" style="font-size:24px;font-weight:700;letter-spacing:-0.01em">' + esc(s.name) + '</h1>' +
                            '<span class="' + badgeClass(status.tone) + '" style="font-size:11.5px;font-weight:600">' + esc(status.label) + '</span>' +
                          '</div>' +
                          '<div class="mt-1 text-slate-500" style="font-size:13px">Student ID: <span class="text-slate-700 font-medium">' + esc(s.id) + '</span></div>' +
                          '<div class="mt-3 flex flex-wrap items-center gap-x-5 gap-y-2 text-slate-600" style="font-size:12.5px">' +
                            '<span class="inline-flex items-center gap-1.5"><i data-lucide="graduation-cap" class="h-4 w-4 text-slate-400"></i> ' + esc(s.progFull) + '</span>' +
                            '<span class="inline-flex items-center gap-1.5"><i data-lucide="calendar-clock" class="h-4 w-4 text-slate-400"></i> Intake ' + esc(s.intake) + '</span>' +
                            '<span class="inline-flex items-center gap-1.5"><i data-lucide="mail" class="h-4 w-4 text-slate-400"></i> ' + esc(s.email) + '</span>' +
                          '</div>' +
                        '</div>' +
                      '</div>' +
                    '</div>' +
                  '</section>';

          // Stat strip
          function stat(label, value, tone, help) {
            var col = tone === "danger" ? "text-[#a01020]" : tone === "success" ? "text-emerald-600" : tone === "pending" ? "text-amber-600" : "text-slate-900";
            return '<div class="rounded-2xl border border-slate-200 bg-white p-4 hover:border-slate-300 hover:shadow-sm transition-all">' +
                     '<div class="flex items-center gap-1.5 text-slate-500" style="font-size:11.5px;font-weight:500"><i data-lucide="activity" class="h-3.5 w-3.5 text-slate-400"></i> ' + esc(label) + '</div>' +
                     '<div class="mt-1 ' + col + '" style="font-size:24px;font-weight:700;letter-spacing:-0.01em">' + esc(value) + '</div>' +
                     (help ? '<div class="text-slate-400" style="font-size:11.5px">' + esc(help) + '</div>' : '') +
                   '</div>';
          }
          html += '<section class="mt-4" style="display:grid;grid-template-columns:repeat(auto-fit,minmax(200px,1fr));gap:16px">' +
                    stat("Overall CGPA",     overall.toFixed(2),                  overall < 2 ? "danger" : overall >= 3.7 ? "success" : "neutral", "Semester " + s.currentSem) +
                    stat("Current Sem GPA",  (latest.gpa || 0).toFixed(2),        (latest.gpa || 0) < 2 ? "danger" : (latest.gpa || 0) >= 3.7 ? "success" : "neutral", latest.term) +
                    stat("Courses Completed", String(totalCourses),               "neutral", totalCredits + " credit hrs") +
                    stat("Attendance",        s.attendance + "%",                 s.attendance < 70 ? "danger" : s.attendance >= 90 ? "success" : "pending", "all semesters") +
                  '</section>';

          // CGPA trend
          html += '<section class="mt-6 rounded-lg border border-slate-200 bg-white">' +
                    '<div class="border-b border-slate-100 px-6 py-4"><h2 class="text-slate-900" style="font-size:15px;font-weight:700">CGPA Trend</h2><p class="mt-0.5 text-slate-500" style="font-size:12.5px">Cumulative GPA vs semester GPA across all completed semesters.</p></div>' +
                    '<div class="px-6 py-6">' + cgpaChart(s.semesters) + '</div>' +
                  '</section>';

          // Risk / Award alerts
          if (s.risk) {
            html += '<div class="mt-6 flex items-start gap-3 rounded-lg border border-[#e0162b]/20 bg-[#e0162b]/5 px-5 py-4">' +
                      '<i data-lucide="alert-triangle" class="h-5 w-5 shrink-0 text-[#e0162b]"></i>' +
                      '<div>' +
                        '<div class="flex items-center gap-2"><div class="text-slate-900" style="font-size:13.5px;font-weight:700">Academic Risk: ' + esc(s.risk.level) + '</div>' +
                          '<span class="' + badgeClass("danger") + '" style="font-size:11.5px;font-weight:600">' + esc(s.risk.level) + '</span></div>' +
                        '<div class="mt-0.5 text-slate-600" style="font-size:12.5px">' + esc(s.risk.reason) + '. Intervention recommended.</div>' +
                      '</div>' +
                    '</div>';
          }
          if (s.awards) {
            html += '<div class="mt-6 flex items-start gap-3 rounded-lg border border-emerald-100 bg-emerald-50 px-5 py-4">' +
                      '<i data-lucide="trophy" class="h-5 w-5 shrink-0 text-emerald-600"></i>' +
                      '<div>' +
                        '<div class="flex items-center gap-2"><div class="text-slate-900" style="font-size:13.5px;font-weight:700">Top Performer</div>' +
                          '<span class="' + badgeClass("success") + '" style="font-size:11.5px;font-weight:600">Awarded</span></div>' +
                        '<div class="mt-0.5 text-slate-600" style="font-size:12.5px">' + esc(s.awards) + '</div>' +
                      '</div>' +
                    '</div>';
          }

          // Attendance by semester accordion
          html += '<section class="mt-6 rounded-lg border border-slate-200 bg-white">' +
                    '<div class="flex items-center justify-between border-b border-slate-100 px-6 py-4">' +
                      '<div><h2 class="text-slate-900" style="font-size:15px;font-weight:700">Attendance by Semester</h2><p class="mt-0.5 text-slate-500" style="font-size:12.5px">Per-course attendance rate across each semester.</p></div>' +
                      '<div class="inline-flex items-center gap-1.5 text-slate-500" style="font-size:12.5px"><i data-lucide="calendar-check" class="h-4 w-4 text-slate-400"></i> Overall ' + s.attendance + '%</div>' +
                    '</div>' +
                    '<ul class="divide-y divide-slate-100">';
          if (s.semesters.length === 0) {
            html += '<li class="px-6 py-10 text-center text-slate-400" style="font-size:13px">No attendance records available.</li>';
          }
          s.semesters.forEach(function (sem, idx) {
            var rows = sem.courses.map(function (c) {
              var pct = courseAttendancePct(s.attendance, c.code);
              return { code: c.code, title: c.title, pct: pct, st: attendanceStatus(pct) };
            });
            var semAvg = rows.length ? rows.reduce(function (a, r) { return a + r.pct; }, 0) / rows.length : 0;
            var semSt = attendanceStatus(semAvg);
            var openInit = idx === s.semesters.length - 1;
            html += '<li>' +
                      '<button type="button" data-acc-toggle data-target="att-' + sem.sem + '" class="flex w-full items-center justify-between gap-3 px-6 py-3 text-left hover:bg-slate-50/60">' +
                        '<div class="flex items-center gap-3">' +
                          '<i data-lucide="' + (openInit ? "chevron-down" : "chevron-right") + '" class="h-4 w-4 text-slate-500 acc-chevron"></i>' +
                          '<div><div class="text-slate-900" style="font-size:13.5px;font-weight:700">Semester ' + sem.sem + '</div>' +
                          '<div class="text-slate-500" style="font-size:12px">' + esc(sem.term) + ' &middot; ' + sem.courses.length + ' courses</div></div>' +
                        '</div>' +
                        '<div class="flex items-center gap-3">' +
                          '<div class="h-1.5 w-28 overflow-hidden rounded-full bg-slate-100"><div class="h-full rounded-full ' + barColor(semSt.tone) + '" style="width:' + Math.min(100, semAvg) + '%"></div></div>' +
                          '<span class="tabular-nums text-slate-700" style="font-size:13px;font-weight:600">' + semAvg.toFixed(1) + '%</span>' +
                          '<span class="' + badgeClass(semSt.tone) + '" style="font-size:11.5px;font-weight:600">' + esc(semSt.label) + '</span>' +
                        '</div>' +
                      '</button>' +
                      '<div id="att-' + sem.sem + '" style="display:' + (openInit ? "" : "none") + '">' +
                        '<div class="overflow-x-auto"><table class="min-w-full">' +
                          '<thead class="text-slate-500"><tr>' +
                            '<th class="px-6 py-3 text-left uppercase" style="font-size:11px;font-weight:600;letter-spacing:0.05em">Code</th>' +
                            '<th class="px-6 py-3 text-left uppercase" style="font-size:11px;font-weight:600;letter-spacing:0.05em">Course</th>' +
                            '<th class="px-6 py-3 text-left uppercase" style="font-size:11px;font-weight:600;letter-spacing:0.05em">Attendance</th>' +
                            '<th class="px-6 py-3 text-right uppercase" style="font-size:11px;font-weight:600;letter-spacing:0.05em">Rate</th>' +
                            '<th class="px-6 py-3 text-left uppercase" style="font-size:11px;font-weight:600;letter-spacing:0.05em">Status</th>' +
                          '</tr></thead><tbody>';
            rows.forEach(function (r) {
              html += '<tr class="border-t border-slate-100">' +
                        '<td class="px-6 py-3 text-slate-500 font-medium" style="font-size:12.5px">' + esc(r.code) + '</td>' +
                        '<td class="px-6 py-3" style="font-size:12.5px"><span class="text-slate-900 font-medium">' + esc(r.title) + '</span></td>' +
                        '<td class="px-6 py-3" style="font-size:12.5px"><div class="h-1.5 w-32 overflow-hidden rounded-full bg-slate-100"><div class="h-full rounded-full ' + barColor(r.st.tone) + '" style="width:' + Math.min(100, r.pct) + '%"></div></div></td>' +
                        '<td class="px-6 py-3 text-right tabular-nums" style="font-size:12.5px">' + r.pct.toFixed(1) + '%</td>' +
                        '<td class="px-6 py-3" style="font-size:12.5px"><span class="' + badgeClass(r.st.tone) + '" style="font-size:11.5px;font-weight:600">' + esc(r.st.label) + '</span></td>' +
                      '</tr>';
            });
            html += '</tbody></table></div></div></li>';
          });
          html += '</ul></section>';

          // Semester results accordion
          html += '<section class="mt-6 rounded-lg border border-slate-200 bg-white">' +
                    '<div class="border-b border-slate-100 px-6 py-4"><h2 class="text-slate-900" style="font-size:15px;font-weight:700">Semester Results</h2><p class="mt-0.5 text-slate-500" style="font-size:12.5px">Expand each semester to view course grades.</p></div>' +
                    '<ul class="divide-y divide-slate-100">';
          if (s.semesters.length === 0) {
            html += '<li class="px-6 py-10 text-center text-slate-400" style="font-size:13px">No semester records available.</li>';
          }
          s.semesters.forEach(function (sem, idx) {
            var openInit = idx === s.semesters.length - 1;
            html += '<li>' +
                      '<button type="button" data-acc-toggle data-target="res-' + sem.sem + '" class="flex w-full items-center justify-between gap-3 px-6 py-4 text-left hover:bg-slate-50/60">' +
                        '<div class="flex items-center gap-3">' +
                          '<i data-lucide="' + (openInit ? "chevron-down" : "chevron-right") + '" class="h-4 w-4 text-slate-500 acc-chevron"></i>' +
                          '<div><div class="text-slate-900" style="font-size:14px;font-weight:700">Semester ' + sem.sem + '</div>' +
                          '<div class="text-slate-500" style="font-size:12px">' + esc(sem.term) + ' &middot; ' + sem.courses.length + ' courses</div></div>' +
                        '</div>' +
                        '<div class="flex items-center gap-6">' +
                          '<div class="text-right"><div class="text-slate-400 uppercase" style="font-size:10.5px;font-weight:600;letter-spacing:0.06em">Sem GPA</div><div class="' + valColor(sem.gpa) + '" style="font-size:16px;font-weight:700">' + sem.gpa.toFixed(2) + '</div></div>' +
                          '<div class="text-right"><div class="text-slate-400 uppercase" style="font-size:10.5px;font-weight:600;letter-spacing:0.06em">CGPA</div><div class="' + valColor(sem.cgpa) + '" style="font-size:16px;font-weight:700">' + sem.cgpa.toFixed(2) + '</div></div>' +
                        '</div>' +
                      '</button>' +
                      '<div id="res-' + sem.sem + '" style="display:' + (openInit ? "" : "none") + '">' +
                        '<div class="border-t border-slate-100 bg-slate-50/40"><div class="overflow-x-auto"><table class="min-w-full">' +
                          '<thead class="text-slate-500"><tr>' +
                            '<th class="px-6 py-3 text-left uppercase" style="font-size:11px;font-weight:600;letter-spacing:0.05em">Code</th>' +
                            '<th class="px-6 py-3 text-left uppercase" style="font-size:11px;font-weight:600;letter-spacing:0.05em">Course</th>' +
                            '<th class="px-6 py-3 text-center uppercase" style="font-size:11px;font-weight:600;letter-spacing:0.05em">Credits</th>' +
                            '<th class="px-6 py-3 text-center uppercase" style="font-size:11px;font-weight:600;letter-spacing:0.05em">Grade</th>' +
                            '<th class="px-6 py-3 text-right uppercase" style="font-size:11px;font-weight:600;letter-spacing:0.05em">GPA Points</th>' +
                          '</tr></thead><tbody>';
            sem.courses.forEach(function (c) {
              var tone = gradeTone(c.grade);
              html += '<tr class="border-t border-slate-100">' +
                        '<td class="px-6 py-3 text-slate-500 font-medium" style="font-size:12.5px">' + esc(c.code) + '</td>' +
                        '<td class="px-6 py-3" style="font-size:12.5px"><span class="text-slate-900 font-medium">' + esc(c.title) + '</span></td>' +
                        '<td class="px-6 py-3 text-center text-slate-700" style="font-size:12.5px">' + c.credits + '</td>' +
                        '<td class="px-6 py-3 text-center" style="font-size:12.5px"><span class="' + badgeClass(tone) + '" style="font-size:11.5px;font-weight:600">' + esc(c.grade) + '</span></td>' +
                        '<td class="px-6 py-3 text-right text-slate-700" style="font-size:12.5px">' + c.gpa.toFixed(2) + '</td>' +
                      '</tr>';
            });
            html += '</tbody></table></div></div></div></li>';
          });
          html += '</ul></section>';

          return html;
        }

        function wireAccordions() {
          document.querySelectorAll("[data-acc-toggle]").forEach(function (btn) {
            btn.addEventListener("click", function () {
              var t = document.getElementById(btn.getAttribute("data-target"));
              if (!t) return;
              var willOpen = t.style.display === "none";
              t.style.display = willOpen ? "" : "none";
              var chevron = btn.querySelector(".acc-chevron");
              if (chevron) {
                var fresh = document.createElement("i");
                fresh.setAttribute("data-lucide", willOpen ? "chevron-down" : "chevron-right");
                fresh.className = "h-4 w-4 text-slate-500 acc-chevron";
                chevron.parentNode.replaceChild(fresh, chevron);
              }
              if (window.renderIcons) window.renderIcons();
            });
          });
        }

        var s = window.STUDENTS.get(qp("id") || "S12101");
        document.getElementById("student-detail-root").innerHTML = buildHtml(s);
        if (window.renderIcons) window.renderIcons();
        wireAccordions();
      })();
    </script>
</asp:Content>
