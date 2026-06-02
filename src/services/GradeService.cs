using System;
using System.Collections.Generic;
using System.Data.SqlClient;
using System.Linq;
using src.db;

namespace src.services
{
    /// <summary>
    /// A student's cumulative academic summary, computed over all published
    /// grades across all semesters.
    /// </summary>
    public class GradeSummary
    {
        /// <summary>Credit-weighted cumulative GPA; null when no published grades (or none carry a GPA).</summary>
        public decimal? Cgpa { get; set; }

        /// <summary>Total credit hours from all published grades (pass and fail); 0 when none.</summary>
        public int CreditsEarned { get; set; }
    }

    /// <summary>All data needed to render the student grades page.</summary>
    public class GradePageData
    {
        public List<GradeSemester> Semesters { get; set; }
        public List<GradeDistributionItem> GradeDistribution { get; set; }
        public decimal? Cgpa { get; set; }
        public int CreditsEarned { get; set; }
        public int CreditsAttempted { get; set; }
        public int CoursesGraded { get; set; }
        public GradeSemester BestSemester { get; set; }

        public GradePageData()
        {
            Semesters = new List<GradeSemester>();
            GradeDistribution = new List<GradeDistributionItem>();
        }

        public GradeSemester CurrentSemester
        {
            get { return Semesters.FirstOrDefault(s => s.IsCurrent); }
        }

        public decimal? CurrentGpa
        {
            get { return CurrentSemester == null ? (decimal?)null : CurrentSemester.Gpa; }
        }
    }

    /// <summary>One semester section on the grades page.</summary>
    public class GradeSemester
    {
        public int SemesterId { get; set; }
        public string SemesterName { get; set; }
        public DateTime StartDate { get; set; }
        public bool IsCurrent { get; set; }
        public int SemesterNo { get; set; }
        public List<GradeCourse> Courses { get; set; }

        public GradeSemester()
        {
            Courses = new List<GradeCourse>();
        }

        public int CourseCount
        {
            get { return Courses.Count; }
        }

        public int Credits
        {
            get { return Courses.Sum(c => c.CreditHours); }
        }

        public int EarnedCredits
        {
            get { return Courses.Where(c => c.GradePublished).Sum(c => c.CreditHours); }
        }

        public decimal? Gpa
        {
            get
            {
                var graded = Courses.Where(c => c.GradePublished && c.Gpa.HasValue).ToList();
                int totalCredits = graded.Sum(c => c.CreditHours);
                if (totalCredits == 0) return null;

                decimal weighted = graded.Sum(c => c.Gpa.Value * c.CreditHours);
                return Math.Round(weighted / totalCredits, 2);
            }
        }
    }

    /// <summary>One course row on the grades page.</summary>
    public class GradeCourse
    {
        public int EnrolmentId { get; set; }
        public int OfferingId { get; set; }
        public int SemesterId { get; set; }
        public string SemesterName { get; set; }
        public DateTime SemesterStartDate { get; set; }
        public bool SemesterIsCurrent { get; set; }
        public int SemesterNo { get; set; }
        public string CourseCode { get; set; }
        public string CourseName { get; set; }
        public int CreditHours { get; set; }
        public string LecturerName { get; set; }
        public string Color { get; set; }
        public string Status { get; set; }
        public decimal? CurrentAverage { get; set; }
        public decimal CompletedPercent { get; set; }
        public decimal? FinalExamMarks { get; set; }
        public bool HasFinalAssessment { get; set; }
        public string FinalAssessmentName { get; set; }
        public decimal? Marks { get; set; }
        public decimal? Gpa { get; set; }
        public string LetterGrade { get; set; }
        public bool GradePublished { get; set; }
    }

    /// <summary>One row in the letter-grade distribution chart.</summary>
    public class GradeDistributionItem
    {
        public string Grade { get; set; }
        public int Count { get; set; }
        public decimal BarWidth { get; set; }
    }

    internal class GradeStudentInfo
    {
        public int StudentId { get; set; }
    }

    /// <summary>
    /// Read-only access to a student's grade-derived metrics and grade page
    /// rows. SQL exceptions are not caught here; they propagate to the caller.
    /// </summary>
    public static class GradeService
    {
        // Credit-weighted CGPA numerator/denominator over all published grades,
        // for the student behind the given user. Division is done in C# so an
        // empty set yields null instead of a divide-by-zero.
        private const string SelectSummary =
            "SELECT SUM(g.gpa * c.credit_hours) AS weighted_points, " +
            "SUM(c.credit_hours) AS total_credits " +
            "FROM STUDENTS s " +
            "JOIN ENROLMENTS e ON e.student_id = s.student_id " +
            "JOIN COURSE_OFFERINGS o ON e.offering_id = o.offering_id " +
            "JOIN COURSES c ON o.course_id = c.course_id " +
            "JOIN GRADES g ON g.enrolment_id = e.enrolment_id " +
            "WHERE s.user_id = @userId AND g.published = 1 " +
            "AND e.status IN ('ENROLLED', 'COMPLETED')";

        private const string SelectStudent =
            "SELECT student_id FROM STUDENTS WHERE user_id = @userId";

        private const string SelectGradeRows =
            "WITH ordered AS (" +
            "SELECT semester_id, ROW_NUMBER() OVER (ORDER BY start_date, semester_id) AS seq " +
            "FROM SEMESTERS), " +
            "student_info AS (" +
            "SELECT s.student_id, intake.seq AS intake_seq " +
            "FROM STUDENTS s " +
            "JOIN ordered intake ON intake.semester_id = s.intake_semester_id " +
            "WHERE s.user_id = @userId) " +
            "SELECT e.enrolment_id, e.offering_id, e.status, " +
            "c.course_code, c.course_name, c.credit_hours, ISNULL(c.color, '') AS color, " +
            "sem.semester_id, sem.name AS semester_name, sem.start_date, sem.is_current, " +
            "CAST(CASE WHEN term.seq - student_info.intake_seq + 1 < 1 THEN 1 " +
            "ELSE term.seq - student_info.intake_seq + 1 END AS INT) AS semester_no, " +
            "ISNULL(lec.full_name, '') AS lecturer_name, " +
            "g.marks, g.gpa, g.grade, ISNULL(g.published, 0) AS published, " +
            "progress.earned_weighted, progress.completed_percent, " +
            "final_item.final_marks, final_item.final_name, final_item.has_final " +
            "FROM student_info " +
            "JOIN ENROLMENTS e ON e.student_id = student_info.student_id " +
            "JOIN COURSE_OFFERINGS o ON e.offering_id = o.offering_id " +
            "JOIN COURSES c ON o.course_id = c.course_id " +
            "JOIN SEMESTERS sem ON o.semester_id = sem.semester_id " +
            "JOIN ordered term ON term.semester_id = sem.semester_id " +
            "LEFT JOIN GRADES g ON g.enrolment_id = e.enrolment_id " +
            "OUTER APPLY (" +
            "SELECT TOP 1 l.full_name FROM TEACHINGS t " +
            "JOIN LECTURERS l ON t.lecturer_id = l.lecturer_id " +
            "WHERE t.offering_id = o.offering_id ORDER BY t.teaching_id) lec " +
            "OUTER APPLY (" +
            "SELECT SUM(CASE WHEN sa.marks IS NOT NULL AND a.max_marks > 0 " +
            "THEN sa.marks / a.max_marks * a.weight ELSE 0 END) AS earned_weighted, " +
            "SUM(CASE WHEN sa.marks IS NOT NULL AND a.max_marks > 0 " +
            "THEN a.weight ELSE 0 END) AS completed_percent " +
            "FROM ASSESSMENTS a " +
            "LEFT JOIN STUDENT_ASSESSMENTS sa ON sa.assessment_id = a.assessment_id " +
            "AND sa.student_id = student_info.student_id " +
            "WHERE a.offering_id = o.offering_id) progress " +
            "OUTER APPLY (" +
            "SELECT TOP 1 sa.marks AS final_marks, a.name AS final_name, CAST(1 AS bit) AS has_final " +
            "FROM ASSESSMENTS a " +
            "LEFT JOIN STUDENT_ASSESSMENTS sa ON sa.assessment_id = a.assessment_id " +
            "AND sa.student_id = student_info.student_id " +
            "WHERE a.offering_id = o.offering_id " +
            "AND (UPPER(a.type) = 'EXAM' OR UPPER(a.name) LIKE '%FINAL%') " +
            "ORDER BY CASE WHEN sa.marks IS NULL THEN 1 ELSE 0 END, a.sort_order DESC) final_item " +
            "WHERE e.status IN ('ENROLLED', 'COMPLETED') " +
            "ORDER BY sem.start_date DESC, c.course_code";

        /// <summary>
        /// Cumulative, credit-weighted GPA and total earned credits for the
        /// student behind <paramref name="userId"/>, over all published grades.
        /// </summary>
        public static GradeSummary GetSummary(int userId)
        {
            using (var conn = Db.OpenConnection())
            using (var cmd = new SqlCommand(SelectSummary, conn))
            {
                cmd.Parameters.AddWithValue("@userId", userId);
                using (var reader = cmd.ExecuteReader())
                {
                    // The aggregate always returns one row; total_credits is
                    // DBNull only when no published grades matched.
                    if (!reader.Read() || reader["total_credits"] == DBNull.Value)
                    {
                        return new GradeSummary { Cgpa = null, CreditsEarned = 0 };
                    }

                    int totalCredits = (int)reader["total_credits"];

                    // weighted_points is DBNull when published grades exist but
                    // none carry a GPA: no CGPA, yet the credits still count.
                    decimal? cgpa = reader["weighted_points"] == DBNull.Value
                        ? (decimal?)null
                        : Math.Round((decimal)reader["weighted_points"] / totalCredits, 2);

                    return new GradeSummary
                    {
                        Cgpa = cgpa,
                        CreditsEarned = totalCredits
                    };
                }
            }
        }

        /// <summary>
        /// Full grades page data for the student behind <paramref name="userId"/>.
        /// Returns null when the user has no student profile.
        /// </summary>
        public static GradePageData GetGradePage(int userId)
        {
            if (GetStudent(userId) == null) return null;

            var courses = GetGradeCourses(userId);
            var semesters = courses
                .GroupBy(c => c.SemesterId)
                .Select(g => new GradeSemester
                {
                    SemesterId = g.Key,
                    SemesterName = g.First().SemesterName,
                    StartDate = g.First().SemesterStartDate,
                    IsCurrent = g.First().SemesterIsCurrent,
                    SemesterNo = g.First().SemesterNo,
                    Courses = g.OrderBy(c => c.CourseCode).ToList()
                })
                .OrderByDescending(s => s.StartDate)
                .ToList();

            var summary = GetSummary(userId);
            var distribution = BuildDistribution(courses);

            return new GradePageData
            {
                Semesters = semesters,
                GradeDistribution = distribution,
                Cgpa = summary.Cgpa,
                CreditsEarned = summary.CreditsEarned,
                CreditsAttempted = semesters.Sum(s => s.Credits),
                CoursesGraded = courses.Count(c => c.GradePublished),
                BestSemester = semesters
                    .Where(s => s.Gpa.HasValue)
                    .OrderByDescending(s => s.Gpa.Value)
                    .ThenByDescending(s => s.StartDate)
                    .FirstOrDefault()
            };
        }

        private static GradeStudentInfo GetStudent(int userId)
        {
            using (var conn = Db.OpenConnection())
            using (var cmd = new SqlCommand(SelectStudent, conn))
            {
                cmd.Parameters.AddWithValue("@userId", userId);
                using (var reader = cmd.ExecuteReader())
                {
                    if (!reader.Read()) return null;
                    return new GradeStudentInfo
                    {
                        StudentId = (int)reader["student_id"]
                    };
                }
            }
        }

        private static List<GradeCourse> GetGradeCourses(int userId)
        {
            var courses = new List<GradeCourse>();

            using (var conn = Db.OpenConnection())
            using (var cmd = new SqlCommand(SelectGradeRows, conn))
            {
                cmd.Parameters.AddWithValue("@userId", userId);
                using (var reader = cmd.ExecuteReader())
                {
                    while (reader.Read())
                    {
                        decimal completedPercent = ReadDecimal(reader, "completed_percent") ?? 0m;
                        decimal? earnedWeighted = ReadDecimal(reader, "earned_weighted");
                        decimal? marks = ReadDecimal(reader, "marks");
                        bool published = Convert.ToBoolean(reader["published"]);

                        decimal? currentAverage = null;
                        if (completedPercent > 0 && earnedWeighted.HasValue)
                        {
                            currentAverage = Math.Round(earnedWeighted.Value / completedPercent * 100, 1);
                        }
                        else if (published && marks.HasValue)
                        {
                            currentAverage = marks;
                        }

                        courses.Add(new GradeCourse
                        {
                            EnrolmentId = (int)reader["enrolment_id"],
                            OfferingId = (int)reader["offering_id"],
                            SemesterId = (int)reader["semester_id"],
                            SemesterName = reader["semester_name"].ToString(),
                            SemesterStartDate = (DateTime)reader["start_date"],
                            SemesterIsCurrent = Convert.ToBoolean(reader["is_current"]),
                            SemesterNo = (int)reader["semester_no"],
                            CourseCode = reader["course_code"].ToString(),
                            CourseName = reader["course_name"].ToString(),
                            CreditHours = (int)reader["credit_hours"],
                            LecturerName = reader["lecturer_name"].ToString(),
                            Color = reader["color"].ToString(),
                            Status = reader["status"].ToString(),
                            CurrentAverage = currentAverage,
                            CompletedPercent = completedPercent,
                            FinalExamMarks = ReadDecimal(reader, "final_marks"),
                            HasFinalAssessment = reader["has_final"] != DBNull.Value,
                            FinalAssessmentName = reader["final_name"] == DBNull.Value ? "" : reader["final_name"].ToString(),
                            Marks = marks,
                            Gpa = ReadDecimal(reader, "gpa"),
                            LetterGrade = published && reader["grade"] != DBNull.Value ? reader["grade"].ToString() : "",
                            GradePublished = published
                        });
                    }
                }
            }

            return courses;
        }

        private static List<GradeDistributionItem> BuildDistribution(List<GradeCourse> courses)
        {
            var grouped = courses
                .Where(c => c.GradePublished && !string.IsNullOrWhiteSpace(c.LetterGrade))
                .GroupBy(c => c.LetterGrade)
                .Select(g => new GradeDistributionItem
                {
                    Grade = g.Key,
                    Count = g.Count()
                })
                .OrderBy(g => GradeSortOrder(g.Grade))
                .ToList();

            int max = grouped.Count == 0 ? 0 : grouped.Max(g => g.Count);
            foreach (var item in grouped)
            {
                item.BarWidth = max == 0 ? 0 : Math.Round(item.Count / (decimal)max * 100, 2);
            }

            return grouped;
        }

        private static int GradeSortOrder(string grade)
        {
            switch ((grade ?? "").ToUpperInvariant())
            {
                case "A+": return 1;
                case "A": return 2;
                case "A-": return 3;
                case "B+": return 4;
                case "B": return 5;
                case "B-": return 6;
                case "C+": return 7;
                case "C": return 8;
                case "C-": return 9;
                case "D": return 10;
                case "F": return 11;
                default: return 99;
            }
        }

        private static decimal? ReadDecimal(SqlDataReader reader, string field)
        {
            return reader[field] == DBNull.Value ? (decimal?)null : Convert.ToDecimal(reader[field]);
        }
    }
}
