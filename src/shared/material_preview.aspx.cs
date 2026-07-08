using System;
using System.Globalization;
using System.Web;
using src.services;

namespace src.shared
{
    public partial class material_preview : src.security.SecurePage
    {
        protected LecturerMaterialRow Material;
        protected string BackUrl = "~/login/login.aspx";

        protected void Page_PreInit(object sender, EventArgs e)
        {
            string role = Session["role"] as string ?? "";
            MasterPageFile = string.Equals(role, src.security.RoleRoutes.Lecturer, StringComparison.OrdinalIgnoreCase)
                ? "~/lecturer/LecturerLayout.master"
                : "~/student/StudentLayout.master";
        }

        protected void Page_Load(object sender, EventArgs e)
        {
            int materialId;
            if (!int.TryParse(Request.QueryString["id"], out materialId))
            {
                ShowMissing();
                return;
            }

            var user = UserContextFactory.FromSession(Session);
            Material = LecturerPortalService.GetMaterial(user, materialId);
            if (Material == null || string.IsNullOrWhiteSpace(Material.FileUrl))
            {
                ShowMissing();
                return;
            }

            BackUrl = user.IsLecturer
                ? ResolveUrl("~/lecturer/lecturer_materials.aspx")
                : ResolveUrl("~/student/course_detail.aspx?offering=" + Material.OfferingId.ToString(CultureInfo.InvariantCulture));

            bool isQuiz = string.Equals(Material.MaterialType, "Quiz", StringComparison.OrdinalIgnoreCase);
            bool isTest = string.Equals(Material.MaterialType, "Test", StringComparison.OrdinalIgnoreCase);
            string targetUrl = ResolveMaterialUrl(Material.FileUrl);

            primaryActionLink.NavigateUrl = targetUrl;
            primaryActionText.Text = isQuiz ? "Open quiz" : "Download";
            primaryActionLink.Visible = isQuiz || !isTest;
            if (!isQuiz)
                primaryActionLink.Attributes["download"] = "";
            fileTypeLabel.Text = Html(isQuiz ? "GOOGLE FORMS" : (Material.FileType ?? "FILE").ToUpperInvariant());
            fileSizeLabel.Text = FormatSize(Material.FileSizeBytes);

            if (isQuiz)
            {
                previewFrame.Visible = false;
                limitedPreviewPanel.Visible = true;
                limitedPreviewMessage.Text = "Use “Open quiz” to launch the Google Form.";
            }
            else if (CanPreviewInline(Material.FileType))
            {
                previewFrame.Attributes["src"] = isTest && string.Equals(Material.FileType, "pdf", StringComparison.OrdinalIgnoreCase)
                    ? targetUrl + "#toolbar=0&navpanes=0"
                    : targetUrl;
                previewFrame.Visible = true;
                limitedPreviewPanel.Visible = false;
            }
            else
            {
                previewFrame.Visible = false;
                limitedPreviewPanel.Visible = true;
                limitedPreviewMessage.Text = isTest
                    ? "This test file cannot be previewed in the browser."
                    : "Use the Download button to open the file.";
            }

            previewPanel.Visible = true;
        }

        private string ResolveMaterialUrl(string url)
        {
            Uri absolute;
            return Uri.TryCreate(url, UriKind.Absolute, out absolute) ? url : ResolveUrl(url);
        }

        private void ShowMissing()
        {
            missingPanel.Visible = true;
            previewPanel.Visible = false;
            primaryActionLink.Visible = false;
        }

        private static bool CanPreviewInline(string fileType)
        {
            string type = (fileType ?? "").ToLowerInvariant();
            return type == "pdf" || type == "png" || type == "jpg" || type == "jpeg"
                || type == "gif" || type == "txt" || type == "sql" || type == "mp4";
        }

        private static string FormatSize(int? bytes)
        {
            if (!bytes.HasValue || bytes.Value <= 0) return "";
            if (bytes.Value >= 1048576) return Math.Round(bytes.Value / 1048576.0, 1) + " MB";
            if (bytes.Value >= 1024) return Math.Round(bytes.Value / 1024.0) + " KB";
            return bytes.Value + " B";
        }

        protected string Html(object value)
        {
            return HttpUtility.HtmlEncode(value == null ? "" : value.ToString());
        }
    }
}
