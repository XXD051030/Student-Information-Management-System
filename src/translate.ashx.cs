using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Web;
using System.Web.Script.Serialization;
using System.Web.SessionState;
using src.services;

namespace src
{
    /// <summary>
    /// Browser-facing proxy for <see cref="TranslationService"/>. The page's
    /// translate.js posts { target, q:[strings] } here; this handler calls Google
    /// server-side so the API key never reaches the client, and returns
    /// { ok, translations:[strings] } aligned 1:1 with the input.
    /// </summary>
    public class TranslateHandler : IHttpHandler, IRequiresSessionState
    {
        public bool IsReusable => false;

        private const int MaxStrings = 400;

        private static readonly JavaScriptSerializer Json =
            new JavaScriptSerializer { MaxJsonLength = 20_000_000 };

        public void ProcessRequest(HttpContext context)
        {
            context.Response.ContentType = "application/json";

            try
            {
                // Only signed-in users may spend translation quota.
                var user = UserContextFactory.FromSession(context.Session);
                if (user == null)
                {
                    Write(context, false, "Session expired. Please log in again.", null);
                    return;
                }

                string raw;
                using (var reader = new StreamReader(context.Request.InputStream))
                    raw = reader.ReadToEnd();

                var req = Json.Deserialize<TranslateRequest>(raw) ?? new TranslateRequest();
                string target = (req.target ?? "").Trim();
                var texts = req.q ?? new List<string>();

                if (!TranslationService.IsSupported(target))
                {
                    Write(context, false, "Unsupported language.", null);
                    return;
                }
                if (texts.Count > MaxStrings)
                {
                    Write(context, false, "Too many strings in one request.", null);
                    return;
                }

                string[] translations = TranslationService.Translate(texts, target);
                Write(context, true, null, translations);
            }
            catch (InvalidOperationException ex)
            {
                // Misconfiguration (e.g. missing API key) — surface the message.
                Write(context, false, ex.Message, null);
            }
            catch
            {
                Write(context, false, "Translation failed. Please try again.", null);
            }
        }

        private static void Write(HttpContext ctx, bool ok, string message, string[] translations)
        {
            ctx.Response.Write(Json.Serialize(new
            {
                ok,
                message,
                translations = translations ?? new string[0]
            }));
        }

        private class TranslateRequest
        {
            public string target { get; set; }
            public List<string> q { get; set; }
        }
    }
}
