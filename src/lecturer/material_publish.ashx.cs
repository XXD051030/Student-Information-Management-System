using System;
using System.Globalization;
using System.IO;
using System.Web;
using System.Web.Script.Serialization;
using System.Web.SessionState;
using src.services;

namespace student_information_management_system
{
    public class MaterialPublishHandler : IHttpHandler, IRequiresSessionState
    {
        public bool IsReusable { get { return false; } }

        public void ProcessRequest(HttpContext context)
        {
            context.Response.ContentType = "application/json";
            var serializer = new JavaScriptSerializer();
            string savedFileUrl = "";

            try
            {
                var user = UserContextFactory.FromSession(context.Session);
                if (user == null || !user.IsLecturer)
                {
                    Write(context, serializer, false, "Your lecturer session has expired.", 0);
                    return;
                }

                int offeringId;
                int.TryParse(context.Request.Form["offeringId"], out offeringId);
                string materialType = (context.Request.Form["materialType"] ?? "").Trim();
                string title = (context.Request.Form["title"] ?? "").Trim();
                string description = (context.Request.Form["description"] ?? "").Trim();
                bool lectureNotes = materialType.Equals("Lecture Notes", StringComparison.OrdinalIgnoreCase);
                bool quiz = materialType.Equals("Quiz", StringComparison.OrdinalIgnoreCase);
                bool assessment = materialType.Equals("Assignment", StringComparison.OrdinalIgnoreCase) ||
                                  materialType.Equals("Test", StringComparison.OrdinalIgnoreCase);

                int weekValue;
                int? week = lectureNotes && int.TryParse(context.Request.Form["week"], out weekValue)
                    ? (int?)weekValue
                    : null;
                DateTime dueValue;
                DateTime? dueDate = DateTime.TryParse(context.Request.Form["dueDate"], out dueValue)
                    ? (DateTime?)dueValue
                    : null;
                decimal weightValue;
                decimal? weight = decimal.TryParse(
                    context.Request.Form["weight"],
                    NumberStyles.Number,
                    CultureInfo.InvariantCulture,
                    out weightValue) ? (decimal?)weightValue : null;

                if (offeringId <= 0) throw new InvalidOperationException("No course is available for publishing materials.");
                if (string.IsNullOrWhiteSpace(title)) throw new InvalidOperationException("Title is required.");
                if (lectureNotes && (!week.HasValue || week.Value < 1 || week.Value > 14))
                    throw new InvalidOperationException("Please choose a week between Week 1 and Week 14 for lecture notes.");
                if (assessment && !dueDate.HasValue)
                    throw new InvalidOperationException("Due date is required for assignments and tests.");
                if (assessment && !weight.HasValue)
                    throw new InvalidOperationException("Course weight is required for assignments and tests.");
                if (assessment && weight.Value <= 0m)
                    throw new InvalidOperationException("Course weight for assignments and tests must be greater than 0%.");
                if (dueDate.HasValue && dueDate.Value.Date < DateTime.Today)
                    throw new InvalidOperationException("Due date cannot be before today.");
                if (weight.HasValue && (weight.Value < 0m || weight.Value > 100m))
                    throw new InvalidOperationException("Course weight must be between 0 and 100.");

                Uri quizUrl;
                bool validQuizUrl = IsGoogleFormsUrl(description, out quizUrl);
                if (quiz && !validQuizUrl)
                    throw new InvalidOperationException(
                        "Quiz links must use Google Forms. Please paste a forms.gle or docs.google.com/forms sharing link.");

                decimal currentWeight = LecturerPortalService.GetMaterialWeightTotal(user, offeringId);
                if (assessment && currentWeight >= 100m)
                    throw new InvalidOperationException(
                        "This course has already reached 100% course weight. " +
                        "Assignments and Tests cannot be added until the course weight is below 100%.");
                if (weight.HasValue && currentWeight + weight.Value > 100m)
                    throw new InvalidOperationException(
                        "This course already uses " + currentWeight.ToString("0.##", CultureInfo.InvariantCulture) +
                        "% weight. You can add at most " +
                        Math.Max(0m, 100m - currentWeight).ToString("0.##", CultureInfo.InvariantCulture) + "%.");

                string fileType = quiz ? "link" : "";
                int fileSize = 0;
                savedFileUrl = quiz ? description : SaveFile(context, offeringId, out fileType, out fileSize);

                int materialId = LecturerPortalService.AddMaterial(user, new LecturerMaterialInput
                {
                    OfferingId = offeringId,
                    Title = title,
                    Description = description,
                    MaterialType = materialType,
                    Week = week,
                    DueDate = lectureNotes ? null : dueDate,
                    Weight = lectureNotes ? null : weight,
                    FileUrl = savedFileUrl,
                    FileType = fileType,
                    FileSizeBytes = fileSize,
                    UploadedAt = DateTime.Now
                });

                if (materialId == -1)
                    throw new InvalidOperationException("This material would make the course weight exceed 100%.");
                if (materialId <= 0)
                    throw new InvalidOperationException("Material could not be published for this course.");

                Write(context, serializer, true, "Material published for enrolled students.", materialId);
            }
            catch (InvalidOperationException ex)
            {
                DeleteSavedFile(context, savedFileUrl);
                Write(context, serializer, false, ex.Message, 0);
            }
            catch
            {
                DeleteSavedFile(context, savedFileUrl);
                Write(context, serializer, false, "Material could not be published.", 0);
            }
        }

        private static string SaveFile(HttpContext context, int offeringId, out string fileType, out int fileSize)
        {
            var upload = context.Request.Files["file"];
            if (upload == null || upload.ContentLength <= 0)
                throw new InvalidOperationException("Please choose a file to upload.");

            string extension = Path.GetExtension(upload.FileName);
            if (string.IsNullOrWhiteSpace(extension))
                throw new InvalidOperationException("Uploaded file needs a file extension.");
            extension = extension.ToLowerInvariant();
            string[] allowed = { ".pdf", ".doc", ".docx", ".ppt", ".pptx", ".xls", ".xlsx", ".zip", ".sql", ".txt", ".png", ".jpg", ".jpeg", ".mp4" };
            if (Array.IndexOf(allowed, extension) < 0)
                throw new InvalidOperationException("File type is not supported for course materials.");
            if (upload.ContentLength > 25 * 1024 * 1024)
                throw new InvalidOperationException("Material file is larger than 25 MB.");

            string folder = context.Server.MapPath("~/uploads/materials");
            Directory.CreateDirectory(folder);
            string baseName = Path.GetFileNameWithoutExtension(upload.FileName);
            foreach (char c in Path.GetInvalidFileNameChars()) baseName = baseName.Replace(c, '-');
            if (string.IsNullOrWhiteSpace(baseName)) baseName = "material";

            string fileName = "off" + offeringId + "-" +
                DateTime.Now.ToString("yyyyMMddHHmmssfff", CultureInfo.InvariantCulture) +
                "-" + baseName + extension;
            upload.SaveAs(Path.Combine(folder, fileName));
            fileType = extension.TrimStart('.');
            fileSize = upload.ContentLength;
            return "~/uploads/materials/" + fileName;
        }

        private static bool IsGoogleFormsUrl(string value, out Uri uri)
        {
            if (!Uri.TryCreate(value, UriKind.Absolute, out uri) ||
                (uri.Scheme != Uri.UriSchemeHttp && uri.Scheme != Uri.UriSchemeHttps))
                return false;

            string host = uri.Host.TrimEnd('.').ToLowerInvariant();
            if (host == "forms.gle") return true;
            return host == "docs.google.com" &&
                uri.AbsolutePath.StartsWith("/forms/", StringComparison.OrdinalIgnoreCase);
        }

        private static void DeleteSavedFile(HttpContext context, string url)
        {
            if (string.IsNullOrWhiteSpace(url) ||
                !url.StartsWith("~/uploads/materials/", StringComparison.OrdinalIgnoreCase)) return;
            string path = context.Server.MapPath(url);
            if (File.Exists(path)) File.Delete(path);
        }

        private static void Write(HttpContext context, JavaScriptSerializer serializer, bool success, string message, int materialId)
        {
            context.Response.Write(serializer.Serialize(new
            {
                success = success,
                message = message,
                materialId = materialId
            }));
        }
    }
}
