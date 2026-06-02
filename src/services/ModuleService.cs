using System;
using System.Collections.Generic;
using System.Data.SqlClient;
using src.db;

namespace src.services
{
    /// <summary>One weekly module (accordion header) and its material items.</summary>
    public class Module
    {
        public int Week { get; set; }
        public string Title { get; set; }
        public string Description { get; set; }
        public List<MaterialItem> Items { get; set; } = new List<MaterialItem>();
    }

    /// <summary>One downloadable material under a module.</summary>
    public class MaterialItem
    {
        public string Title { get; set; }
        public string FileType { get; set; }
        public int? FileSizeBytes { get; set; }
        public string FileUrl { get; set; }
    }

    /// <summary>
    /// Read-only access to an offering's weekly modules with their materials.
    /// Returns an empty list when the offering has no modules. SQL exceptions
    /// propagate to the caller.
    /// </summary>
    public static class ModuleService
    {
        // Modules left-joined to their materials, ordered so a single pass in C#
        // groups items under each module in display order.
        private const string SelectModules =
            "SELECT m.week, m.title, m.description, " +
            "cm.title AS item_title, cm.file_type, cm.file_size_bytes, cm.file_url " +
            "FROM MODULES m " +
            "LEFT JOIN COURSE_MATERIALS cm ON cm.module_id = m.module_id " +
            "WHERE m.offering_id = @offeringId " +
            "ORDER BY m.week, cm.material_id";

        public static List<Module> GetModules(int offeringId)
        {
            using (var conn = Db.OpenConnection())
            using (var cmd = new SqlCommand(SelectModules, conn))
            {
                cmd.Parameters.AddWithValue("@offeringId", offeringId);
                var modules = new List<Module>();
                Module current = null;
                int currentWeek = int.MinValue;
                using (var reader = cmd.ExecuteReader())
                {
                    while (reader.Read())
                    {
                        int week = (int)reader["week"];
                        if (current == null || week != currentWeek)
                        {
                            current = new Module
                            {
                                Week = week,
                                Title = reader["title"].ToString(),
                                Description = reader["description"] == DBNull.Value
                                    ? "" : reader["description"].ToString()
                            };
                            modules.Add(current);
                            currentWeek = week;
                        }
                        if (reader["item_title"] != DBNull.Value)
                        {
                            current.Items.Add(new MaterialItem
                            {
                                Title = reader["item_title"].ToString(),
                                FileType = reader["file_type"] == DBNull.Value
                                    ? "" : reader["file_type"].ToString(),
                                FileSizeBytes = reader["file_size_bytes"] == DBNull.Value
                                    ? (int?)null : (int)reader["file_size_bytes"],
                                FileUrl = reader["file_url"] == DBNull.Value
                                    ? null : reader["file_url"].ToString()
                            });
                        }
                    }
                }
                return modules;
            }
        }
    }
}
