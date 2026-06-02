(function () {
  function pct(p, a) { return Math.round((p / (p + a)) * 1000) / 10; }
  function mkSessions(total, baseAbsent, enrolled) {
    var out = [];
    for (var i = 0; i < total; i++) {
      var absent = Math.max(0, Math.min(enrolled, baseAbsent + ((i * 3) % 5) - 2));
      out.push({ present: enrolled - absent, absent: absent });
    }
    return out;
  }
  function mkStudents(rows) {
    return rows.map(function (r) {
      return { id: r[0], name: r[1], prog: r[2], present: r[3], absent: r[4], pct: pct(r[3], r[4]) };
    });
  }

  var courses = [
    { code: "CSC2024", title: "Mobile App Development", prog: "BCS", sem: 4,
      lecturer: "Dr. Aisyah Rahman", enrolled: 32, avgPct: 88.5, sessionsHeld: 12,
      sessions: mkSessions(12, 4, 32),
      students: mkStudents([
        ["S12039", "Lim Wei Jian", "BCS", 12, 0],
        ["S12101", "Lee Hui Min",  "BCS", 12, 0],
        ["S12042", "Tan Mei Ling", "BCS",  6, 6],
        ["S12055", "Aaron Choo",   "BCS", 11, 1],
        ["S12061", "Sofia Anwar",  "BCS", 10, 2],
        ["S12067", "Kenji Ho",     "BCS",  9, 3],
        ["S12072", "Priya Nair",   "BCS", 11, 1],
        ["S12080", "Marcus Tan",   "BCS",  7, 5]
      ])
    },
    { code: "CSC2030", title: "Machine Learning", prog: "BCS", sem: 4,
      lecturer: "Dr. Liew Chee Seng", enrolled: 28, avgPct: 76.2, sessionsHeld: 12,
      sessions: mkSessions(12, 7, 28),
      students: mkStudents([
        ["S12042", "Tan Mei Ling", "BCS",  5, 7],
        ["S12055", "Aaron Choo",   "BCS", 10, 2],
        ["S12101", "Lee Hui Min",  "BCS", 12, 0],
        ["S12067", "Kenji Ho",     "BCS",  8, 4],
        ["S12061", "Sofia Anwar",  "BCS",  9, 3],
        ["S12080", "Marcus Tan",   "BCS",  6, 6]
      ])
    },
    { code: "ITN3010", title: "Cloud Networking", prog: "BIT", sem: 3,
      lecturer: "Mr. Tan Wei Lun", enrolled: 30, avgPct: 82.0, sessionsHeld: 11,
      sessions: mkSessions(11, 5, 30),
      students: mkStudents([
        ["S12040", "Nur Aisyah",   "BIT", 10, 1],
        ["S12048", "Ahmad Faizal", "BIT",  7, 4],
        ["S12090", "Iris Wong",    "BIT", 11, 0],
        ["S12093", "Daniel Lee",   "BIT",  9, 2],
        ["S12099", "Hannah Yap",   "BIT",  8, 3]
      ])
    },
    { code: "BBA3201", title: "Strategic Marketing", prog: "BBA", sem: 5,
      lecturer: "Ms. Priya Devi", enrolled: 35, avgPct: 91.2, sessionsHeld: 12,
      sessions: mkSessions(12, 3, 35),
      students: mkStudents([
        ["S12041", "Raj Kumar",    "BBA", 12, 0],
        ["S12051", "Choo Kah Yan", "BBA",  9, 3],
        ["S12119", "Farah Diana",  "BBA", 12, 0],
        ["S12130", "Yusof Idris",  "BBA", 11, 1],
        ["S12141", "Grace Ong",    "BBA", 10, 2]
      ])
    },
    { code: "BBA2030", title: "HR Management", prog: "BBA", sem: 4,
      lecturer: "Dr. Ng Boon Hwa", enrolled: 26, avgPct: 68.4, sessionsHeld: 10,
      sessions: mkSessions(10, 8, 26),
      students: mkStudents([
        ["S12051", "Choo Kah Yan", "BBA",  6, 4],
        ["S12130", "Yusof Idris",  "BBA",  7, 3],
        ["S12141", "Grace Ong",    "BBA",  8, 2],
        ["S12150", "Ben Cheong",   "BBA",  5, 5],
        ["S12162", "Lim Hui Xian", "BBA",  9, 1]
      ])
    },
    { code: "DSC2010", title: "Machine Learning (DS)", prog: "BDS", sem: 3,
      lecturer: "Dr. Vikram Patel", enrolled: 24, avgPct: 93.0, sessionsHeld: 11,
      sessions: mkSessions(11, 2, 24),
      students: mkStudents([
        ["S12108", "Vivek Sharma",  "BDS", 11, 0],
        ["S12180", "Anya Krishnan", "BDS", 11, 0],
        ["S12188", "Daniel Goh",    "BDS", 10, 1],
        ["S12191", "Mira Suresh",   "BDS", 10, 1]
      ])
    }
  ];

  window.ATTENDANCE = {
    list: courses,
    get: function (code) {
      for (var i = 0; i < courses.length; i++) if (courses[i].code === code) return courses[i];
      return { code: code, title: "Unknown course", prog: "—", sem: 0, lecturer: "—",
               enrolled: 0, avgPct: 0, sessionsHeld: 0, sessions: [], students: [] };
    },
    status: function (pct) {
      if (pct >= 85) return { label: "Healthy",  tone: "success" };
      if (pct >= 70) return { label: "Warning",  tone: "pending" };
      return { label: "Critical", tone: "danger" };
    }
  };
})();
