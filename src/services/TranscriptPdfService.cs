using System;
using System.Collections.Generic;
using System.Drawing;
using System.Drawing.Drawing2D;
using System.Drawing.Imaging;
using System.Globalization;
using System.IO;
using System.Linq;
using System.Text;

namespace src.services
{
    public static class TranscriptPdfService
    {
        private const float PageWidth = 595f;
        private const float PageHeight = 842f;
        private const float Left = 48f;
        private const float Right = 547f;
        private const float TableRight = 540f;
        private const float GpaColumnRight = 526f;
        private static readonly CultureInfo Invariant = CultureInfo.InvariantCulture;

        public static byte[] Create(StudentAccountProfile account, StudentGradePage grades, string logoPath, DateTime generatedAt)
        {
            var pages = new List<PdfPage>();
            var page = NewPage(pages, false);
            DrawFirstHeader(page, account, logoPath, generatedAt);
            var y = 580f;
            DrawTableHeader(page, y);
            y -= 22f;

            var hasRows = false;
            foreach (var semester in grades.Semesters.OrderBy(s => s.StartDate))
            {
                var courses = semester.Courses.Where(c => c.GradePublished).ToList();
                if (courses.Count == 0) continue;
                hasRows = true;

                var semesterHeight = 20f + courses.Count * 18f;
                if (y - semesterHeight < 92f)
                {
                    page = NewPage(pages, true);
                    y = 748f;
                    DrawTableHeader(page, y);
                    y -= 22f;
                }

                FillRect(page, Left, y - 2f, TableRight - Left, 18f, 0.95f, 0.95f, 0.95f);
                Text(page, Left + 5f, y + 3f, "F2", 9.5f, SemesterLabel(semester));
                TextRight(page, TableRight - 5f, y + 3f, "F2", 9f, "Semester GPA " + Gpa(semester.Gpa));
                y -= 20f;

                foreach (var course in courses)
                {
                    if (y < 92f)
                    {
                        page = NewPage(pages, true);
                        y = 748f;
                        DrawTableHeader(page, y);
                        y -= 22f;
                    }

                    Text(page, 53f, y, "F1", 8.5f, Shorten(semester.SemesterName, 16));
                    Text(page, 143f, y, "F2", 8.5f, Shorten(course.CourseCode, 12));
                    Text(page, 208f, y, "F1", 8.5f, Shorten(course.CourseName, 34));
                    TextRight(page, 445f, y, "F1", 8.5f, course.CreditHours.ToString(Invariant));
                    TextRight(page, 490f, y, "F2", 8.5f, course.LetterGrade);
                    TextRight(page, GpaColumnRight, y, "F1", 8.5f, Gpa(course.Gpa));
                    Line(page, Left, y - 5f, TableRight, y - 5f, 0.85f, 0.85f, 0.85f, 0.35f);
                    y -= 18f;
                }
            }

            if (!hasRows)
            {
                Text(page, Left + 5f, y - 5f, "F1", 10f, "No published grades are available for this student.");
                y -= 30f;
            }

            if (y < 135f)
            {
                page = NewPage(pages, true);
                y = 735f;
            }

            DrawTotals(page, grades, y - 10f);
            for (var i = 0; i < pages.Count; i++) DrawFooter(pages[i], i + 1, pages.Count, generatedAt);
            return BuildPdf(pages, LoadLogo(logoPath));
        }

        private static PdfPage NewPage(List<PdfPage> pages, bool continued)
        {
            var page = new PdfPage();
            pages.Add(page);
            if (continued)
            {
                Text(page, Left, 795f, "F2", 15f, "INTI INTERNATIONAL UNIVERSITY & COLLEGES");
                Text(page, Left, 774f, "F2", 12f, "ACADEMIC TRANSCRIPT - CONTINUED");
                Line(page, Left, 763f, Right, 763f, 0.88f, 0.09f, 0.17f, 1.3f);
            }
            return page;
        }

        private static void DrawFirstHeader(PdfPage page, StudentAccountProfile account, string logoPath, DateTime generatedAt)
        {
            page.Content.Append("q 125 0 0 42 48 768 cm /Logo Do Q\n");
            Text(page, 195f, 798f, "F2", 14f, "INTI INTERNATIONAL UNIVERSITY & COLLEGES");
            Text(page, 195f, 773f, "F2", 18f, "ACADEMIC TRANSCRIPT");
            Text(page, 195f, 755f, "F1", 9f, "Student Services and Registrar's Office");
            Line(page, Left, 740f, Right, 740f, 0.88f, 0.09f, 0.17f, 1.5f);

            Text(page, Left, 715f, "F1", 8f, "STUDENT NAME");
            Text(page, Left, 699f, "F2", 11f, account.FullName);
            Text(page, Left, 678f, "F1", 8f, "STUDENT ID");
            Text(page, Left, 662f, "F2", 10f, account.StudentId);
            Text(page, Left, 641f, "F1", 8f, "EMAIL");
            Text(page, Left, 625f, "F1", 9f, Shorten(account.Email, 38));

            Text(page, 310f, 715f, "F1", 8f, "PROGRAMME");
            Text(page, 310f, 699f, "F2", 10f, Shorten(account.ProgrammeName, 39));
            Text(page, 310f, 678f, "F1", 8f, "CURRENT SESSION");
            Text(page, 310f, 662f, "F1", 9f, account.CurrentSession);
            Text(page, 310f, 641f, "F1", 8f, "RECORD STATUS");
            Text(page, 310f, 625f, "F1", 9f, account.Status + " - Generated " + generatedAt.ToString("dd MMM yyyy", Invariant));
        }

        private static void DrawTableHeader(PdfPage page, float y)
        {
            FillRect(page, Left, y - 4f, TableRight - Left, 20f, 0.88f, 0.09f, 0.17f);
            Text(page, 53f, y + 2f, "F2", 8f, "TERM");
            Text(page, 143f, y + 2f, "F2", 8f, "CODE");
            Text(page, 208f, y + 2f, "F2", 8f, "COURSE TITLE");
            TextRight(page, 445f, y + 2f, "F2", 8f, "CREDITS");
            TextRight(page, 490f, y + 2f, "F2", 8f, "GRADE");
            TextRight(page, GpaColumnRight, y + 2f, "F2", 8f, "GPA");
            page.Content.Append("0 0 0 rg\n");
        }

        private static void DrawTotals(PdfPage page, StudentGradePage grades, float y)
        {
            Line(page, Left, y + 18f, Right, y + 18f, 0.15f, 0.15f, 0.15f, 0.9f);
            Text(page, Left, y, "F2", 10f, "ACADEMIC SUMMARY");
            Text(page, Left, y - 22f, "F1", 9f, "Credits attempted");
            Text(page, 145f, y - 22f, "F2", 9f, grades.CreditsAttempted.ToString(Invariant));
            Text(page, 220f, y - 22f, "F1", 9f, "Credits earned");
            Text(page, 305f, y - 22f, "F2", 9f, grades.CreditsEarned.ToString(Invariant));
            Text(page, 390f, y - 22f, "F1", 9f, "CGPA");
            Text(page, 437f, y - 22f, "F2", 11f, Gpa(grades.Cgpa));
            Text(page, Left, y - 48f, "F1", 8f, "Grading scale: 4.00 maximum. GPA is calculated from published grades and course credit hours.");
            Text(page, Left, y - 67f, "F1", 8f, "This is a student-generated unofficial transcript for reference purposes.");
        }

        private static void DrawFooter(PdfPage page, int pageNumber, int pageCount, DateTime generatedAt)
        {
            Line(page, Left, 48f, Right, 48f, 0.75f, 0.75f, 0.75f, 0.5f);
            Text(page, Left, 32f, "F1", 7.5f, "INTI International University & Colleges");
            TextRight(page, Right, 32f, "F1", 7.5f, "Generated " + generatedAt.ToString("dd MMM yyyy HH:mm", Invariant) + "  |  Page " + pageNumber + " of " + pageCount);
        }

        private static string SemesterLabel(StudentGradeSemester semester)
        {
            return semester.SemesterName + "  |  " + semester.Courses.Count(c => c.GradePublished) + " graded courses";
        }

        private static string Gpa(decimal? value) { return value.HasValue ? value.Value.ToString("0.00", Invariant) : "-"; }

        private static string Shorten(string value, int max)
        {
            value = value ?? "";
            return value.Length <= max ? value : value.Substring(0, Math.Max(0, max - 3)) + "...";
        }

        private static void Text(PdfPage page, float x, float y, string font, float size, string value)
        {
            page.Content.Append("BT /").Append(font).Append(' ').Append(F(size)).Append(" Tf 1 0 0 1 ")
                .Append(F(x)).Append(' ').Append(F(y)).Append(" Tm (").Append(Escape(value)).Append(") Tj ET\n");
        }

        private static void TextRight(PdfPage page, float right, float y, string font, float size, string value)
        {
            var width = (Clean(value).Length * size * 0.48f);
            Text(page, Math.Max(Left, right - width), y, font, size, value);
        }

        private static void Line(PdfPage page, float x1, float y1, float x2, float y2, float r, float g, float b, float width)
        {
            page.Content.Append(F(r)).Append(' ').Append(F(g)).Append(' ').Append(F(b)).Append(" RG ")
                .Append(F(width)).Append(" w ").Append(F(x1)).Append(' ').Append(F(y1)).Append(" m ")
                .Append(F(x2)).Append(' ').Append(F(y2)).Append(" l S\n");
        }

        private static void FillRect(PdfPage page, float x, float y, float width, float height, float r, float g, float b)
        {
            page.Content.Append(F(r)).Append(' ').Append(F(g)).Append(' ').Append(F(b)).Append(" rg ")
                .Append(F(x)).Append(' ').Append(F(y)).Append(' ').Append(F(width)).Append(' ').Append(F(height)).Append(" re f\n");
            page.Content.Append(r < 0.3f ? "1 1 1 rg\n" : "0 0 0 rg\n");
        }

        private static string F(float value) { return value.ToString("0.###", Invariant); }

        private static string Clean(string value)
        {
            var source = value ?? "";
            var chars = source.Select(c => c >= 32 && c <= 126 ? c : '-').ToArray();
            return new string(chars);
        }

        private static string Escape(string value)
        {
            return Clean(value).Replace("\\", "\\\\").Replace("(", "\\(").Replace(")", "\\)");
        }

        private static LogoData LoadLogo(string path)
        {
            using (var source = Image.FromFile(path))
            using (var bitmap = new Bitmap(source.Width, source.Height, PixelFormat.Format24bppRgb))
            using (var graphics = Graphics.FromImage(bitmap))
            using (var stream = new MemoryStream())
            {
                graphics.Clear(Color.White);
                graphics.InterpolationMode = InterpolationMode.HighQualityBicubic;
                graphics.DrawImage(source, 0, 0, source.Width, source.Height);
                bitmap.Save(stream, ImageFormat.Jpeg);
                return new LogoData { Bytes = stream.ToArray(), Width = source.Width, Height = source.Height };
            }
        }

        private static byte[] BuildPdf(List<PdfPage> pages, LogoData logo)
        {
            var objectCount = 5 + pages.Count * 2;
            var objects = new byte[objectCount + 1][];
            objects[1] = Ascii("<< /Type /Catalog /Pages 2 0 R >>");

            var kids = new StringBuilder();
            for (var i = 0; i < pages.Count; i++) kids.Append(6 + i * 2).Append(" 0 R ");
            objects[2] = Ascii("<< /Type /Pages /Kids [ " + kids + "] /Count " + pages.Count + " >>");
            objects[3] = Ascii("<< /Type /Font /Subtype /Type1 /BaseFont /Helvetica >>");
            objects[4] = Ascii("<< /Type /Font /Subtype /Type1 /BaseFont /Helvetica-Bold >>");
            objects[5] = StreamObject(
                "<< /Type /XObject /Subtype /Image /Width " + logo.Width + " /Height " + logo.Height +
                " /ColorSpace /DeviceRGB /BitsPerComponent 8 /Filter /DCTDecode /Length " + logo.Bytes.Length + " >>",
                logo.Bytes);

            for (var i = 0; i < pages.Count; i++)
            {
                var pageId = 6 + i * 2;
                var contentId = pageId + 1;
                var content = Ascii(pages[i].Content.ToString());
                objects[pageId] = Ascii("<< /Type /Page /Parent 2 0 R /MediaBox [0 0 " + F(PageWidth) + " " + F(PageHeight) +
                    "] /Resources << /Font << /F1 3 0 R /F2 4 0 R >> /XObject << /Logo 5 0 R >> >> /Contents " + contentId + " 0 R >>");
                objects[contentId] = StreamObject("<< /Length " + content.Length + " >>", content);
            }

            using (var output = new MemoryStream())
            {
                Write(output, "%PDF-1.4\n");
                var offsets = new long[objectCount + 1];
                for (var i = 1; i <= objectCount; i++)
                {
                    offsets[i] = output.Position;
                    Write(output, i + " 0 obj\n");
                    output.Write(objects[i], 0, objects[i].Length);
                    Write(output, "\nendobj\n");
                }

                var xref = output.Position;
                Write(output, "xref\n0 " + (objectCount + 1) + "\n0000000000 65535 f \n");
                for (var i = 1; i <= objectCount; i++) Write(output, offsets[i].ToString("0000000000", Invariant) + " 00000 n \n");
                Write(output, "trailer\n<< /Size " + (objectCount + 1) + " /Root 1 0 R >>\nstartxref\n" + xref + "\n%%EOF");
                return output.ToArray();
            }
        }

        private static byte[] StreamObject(string dictionary, byte[] data)
        {
            using (var stream = new MemoryStream())
            {
                Write(stream, dictionary + "\nstream\n");
                stream.Write(data, 0, data.Length);
                Write(stream, "\nendstream");
                return stream.ToArray();
            }
        }

        private static byte[] Ascii(string value) { return Encoding.ASCII.GetBytes(value); }
        private static void Write(Stream stream, string value) { var bytes = Ascii(value); stream.Write(bytes, 0, bytes.Length); }

        private sealed class PdfPage { public readonly StringBuilder Content = new StringBuilder(); }
        private sealed class LogoData { public byte[] Bytes; public int Width; public int Height; }
    }
}
