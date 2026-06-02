using System;
using System.Collections.Generic;
using System.Data.SqlClient;
using src.db;

namespace src.services
{
    /// <summary>One gradebook line item with the student's score, if any.</summary>
    public class AssessmentRow
    {
        public string Name { get; set; }
        public string Type { get; set; }
        public decimal Weight { get; set; }
        public int MaxMarks { get; set; }
        public decimal? Marks { get; set; }
        public bool IsGraded { get { return Marks.HasValue; } }
        /// <summary>Weighted contribution to the final grade; null when not graded.</summary>
        public decimal? Contribution
        {
            get { return (Marks.HasValue && MaxMarks > 0) ? (decimal?)Math.Round(Marks.Value / MaxMarks * Weight, 1) : null; }
        }
    }

    /// <summary>An offering's gradebook for one student, plus computed totals.</summary>
    public class Gradebook
    {
        public List<AssessmentRow> Items { get; private set; } = new List<AssessmentRow>();
        /// <summary>Weighted average over graded items (0-100); null when none graded.</summary>
        public decimal? OverallAverage { get; set; }
        /// <summary>Sum of contributions of graded items.</summary>
        public decimal EarnedWeighted { get; set; }
        /// <summary>Sum of weights of graded items (the % of the course completed).</summary>
        public decimal CompletedPercent { get; set; }
    }

    /// <summary>
    /// Read-only gradebook for an offering and the student behind a user id.
    /// Assessments with no student score are returned as pending (null marks)
    /// and excluded from the totals. SQL exceptions propagate to the caller.
    /// </summary>
    public static class AssessmentService
    {
        private const string SelectGradebook =
            "SELECT a.name, a.type, a.weight, a.max_marks, sa.marks " +
            "FROM ASSESSMENTS a " +
            "LEFT JOIN STUDENT_ASSESSMENTS sa ON sa.assessment_id = a.assessment_id " +
            "AND sa.student_id = (SELECT student_id FROM STUDENTS WHERE user_id = @userId) " +
            "WHERE a.offering_id = @offeringId " +
            "AND EXISTS (SELECT 1 FROM ENROLMENTS e " +
            "JOIN STUDENTS s ON e.student_id = s.student_id " +
            "WHERE e.offering_id = @offeringId AND s.user_id = @userId) " +
            "ORDER BY a.sort_order";

        public static Gradebook GetGradebook(int offeringId, int userId)
        {
            using (var conn = Db.OpenConnection())
            using (var cmd = new SqlCommand(SelectGradebook, conn))
            {
                cmd.Parameters.AddWithValue("@offeringId", offeringId);
                cmd.Parameters.AddWithValue("@userId", userId);
                var book = new Gradebook();
                decimal weightedMarkSum = 0m;   // Σ (marks/max * weight)
                decimal gradedWeight = 0m;       // Σ weight of graded
                using (var reader = cmd.ExecuteReader())
                {
                    while (reader.Read())
                    {
                        var row = new AssessmentRow
                        {
                            Name = reader["name"].ToString(),
                            Type = reader["type"].ToString(),
                            Weight = (decimal)reader["weight"],
                            MaxMarks = (int)reader["max_marks"],
                            Marks = reader["marks"] == DBNull.Value
                                ? (decimal?)null : (decimal)reader["marks"]
                        };
                        book.Items.Add(row);
                        if (row.IsGraded && row.MaxMarks > 0)
                        {
                            weightedMarkSum += row.Marks.Value / row.MaxMarks * row.Weight;
                            gradedWeight += row.Weight;
                        }
                    }
                }
                book.CompletedPercent = gradedWeight;
                book.EarnedWeighted = Math.Round(weightedMarkSum, 1);
                book.OverallAverage = gradedWeight > 0
                    ? (decimal?)Math.Round(weightedMarkSum / gradedWeight * 100, 0)
                    : null;
                return book;
            }
        }
    }
}
