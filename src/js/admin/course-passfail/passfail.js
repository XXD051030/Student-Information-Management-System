(function () {
  function mk(rows) {
    return rows.map(function (r) {
      return { id: r[0], name: r[1], prog: r[2], sem: r[3], marks: r[4], grade: r[5],
               status: r[5] === "F" ? "Fail" : "Pass" };
    });
  }

  var courses = [
    { code: "CSC2024", title: "Mobile App Development", prog: "BCS", sem: 4,
      lecturer: "Dr. Aisyah Rahman", enrolled: 8, passed: 7, failed: 1, passRate: 87.5, avgMarks: 71.9,
      students: mk([
        ["S12039", "Lim Wei Jian", "BCS", 4, 86, "A"],
        ["S12101", "Lee Hui Min",  "BCS", 4, 92, "A+"],
        ["S12042", "Tan Mei Ling", "BCS", 4, 42, "F"],
        ["S12055", "Aaron Choo",   "BCS", 4, 74, "B"],
        ["S12061", "Sofia Anwar",  "BCS", 4, 68, "B-"],
        ["S12067", "Kenji Ho",     "BCS", 4, 81, "A-"],
        ["S12072", "Priya Nair",   "BCS", 4, 77, "B+"],
        ["S12080", "Marcus Tan",   "BCS", 4, 55, "C"]
      ])
    },
    { code: "CSC2030", title: "Machine Learning", prog: "BCS", sem: 4,
      lecturer: "Dr. Liew Chee Seng", enrolled: 7, passed: 4, failed: 3, passRate: 57.1, avgMarks: 61.4,
      students: mk([
        ["S12042", "Tan Mei Ling", "BCS", 4, 38, "F"],
        ["S12055", "Aaron Choo",   "BCS", 4, 70, "B"],
        ["S12101", "Lee Hui Min",  "BCS", 4, 88, "A"],
        ["S12067", "Kenji Ho",     "BCS", 4, 45, "F"],
        ["S12061", "Sofia Anwar",  "BCS", 4, 62, "C+"],
        ["S12080", "Marcus Tan",   "BCS", 4, 48, "F"],
        ["S12039", "Lim Wei Jian", "BCS", 4, 79, "B+"]
      ])
    },
    { code: "ITN3010", title: "Cloud Networking", prog: "BIT", sem: 3,
      lecturer: "Mr. Tan Wei Lun", enrolled: 5, passed: 4, failed: 1, passRate: 80.0, avgMarks: 64.2,
      students: mk([
        ["S12040", "Nur Aisyah",   "BIT", 3, 58, "C"],
        ["S12048", "Ahmad Faizal", "BIT", 3, 44, "F"],
        ["S12090", "Iris Wong",    "BIT", 3, 82, "A-"],
        ["S12093", "Daniel Lee",   "BIT", 3, 71, "B"],
        ["S12099", "Hannah Yap",   "BIT", 3, 66, "B-"]
      ])
    },
    { code: "BBA3201", title: "Strategic Marketing", prog: "BBA", sem: 5,
      lecturer: "Ms. Priya Devi", enrolled: 5, passed: 5, failed: 0, passRate: 100.0, avgMarks: 79.2,
      students: mk([
        ["S12041", "Raj Kumar",    "BBA", 5, 84, "A-"],
        ["S12051", "Choo Kah Yan", "BBA", 5, 63, "C+"],
        ["S12119", "Farah Diana",  "BBA", 5, 91, "A+"],
        ["S12130", "Yusof Idris",  "BBA", 5, 78, "B+"],
        ["S12141", "Grace Ong",    "BBA", 5, 80, "A-"]
      ])
    },
    { code: "BBA2030", title: "HR Management", prog: "BBA", sem: 4,
      lecturer: "Dr. Ng Boon Hwa", enrolled: 5, passed: 3, failed: 2, passRate: 60.0, avgMarks: 61.0,
      students: mk([
        ["S12051", "Choo Kah Yan", "BBA", 4, 41, "F"],
        ["S12130", "Yusof Idris",  "BBA", 4, 67, "B-"],
        ["S12141", "Grace Ong",    "BBA", 4, 73, "B"],
        ["S12150", "Ben Cheong",   "BBA", 4, 48, "F"],
        ["S12162", "Lim Hui Xian", "BBA", 4, 76, "B+"]
      ])
    },
    { code: "DSC2010", title: "Machine Learning (DS)", prog: "BDS", sem: 3,
      lecturer: "Dr. Vikram Patel", enrolled: 4, passed: 4, failed: 0, passRate: 100.0, avgMarks: 87.3,
      students: mk([
        ["S12108", "Vivek Sharma",  "BDS", 3, 94, "A+"],
        ["S12180", "Anya Krishnan", "BDS", 3, 88, "A"],
        ["S12188", "Daniel Goh",    "BDS", 3, 82, "A-"],
        ["S12191", "Mira Suresh",   "BDS", 3, 85, "A"]
      ])
    }
  ];

  window.PASSFAIL = {
    list: courses,
    get: function (code) {
      for (var i = 0; i < courses.length; i++) if (courses[i].code === code) return courses[i];
      return { code: code, title: "Unknown course", prog: "—", sem: 0, lecturer: "—",
               enrolled: 0, passed: 0, failed: 0, passRate: 0, avgMarks: 0, students: [] };
    },
    status: function (pct) {
      if (pct >= 80) return { label: "High",   tone: "success" };
      if (pct >= 60) return { label: "Medium", tone: "pending" };
      return { label: "Low", tone: "danger" };
    },
    gradeTone: function (g) {
      if (g === "F") return "danger";
      if (g.charAt(0) === "A") return "success";
      if (g.charAt(0) === "C" || g === "D") return "pending";
      return "neutral";
    }
  };
})();
