using System;
using System.Collections.Concurrent;
using System.Collections.Generic;
using System.Configuration;
using System.IO;
using System.Linq;
using System.Net;
using System.Text;
using System.Web.Hosting;
using System.Web.Script.Serialization;
using System.Xml;

namespace src.services
{
    /// <summary>
    /// Translates UI strings through the Google Cloud Translation API (v2 REST).
    ///
    /// The API key is read directly from the external, gitignored "translate.config"
    /// (same pattern as ai.config) so it can be changed without rebuilding, falling
    /// back to Web.config appSettings ("GoogleTranslate:ApiKey").
    ///
    /// Results are cached in-memory keyed by (target, sourceText) so the same label
    /// rendered on many pages is only billed to Google once per process lifetime.
    /// </summary>
    public static class TranslationService
    {
        private const string Endpoint = "https://translation.googleapis.com/language/translate/v2";

        private static readonly JavaScriptSerializer Json =
            new JavaScriptSerializer { MaxJsonLength = 20_000_000 };

        // key = target + "" + sourceText  ->  translated text
        private static readonly ConcurrentDictionary<string, string> Cache =
            new ConcurrentDictionary<string, string>();

        /// <summary>Language codes the portal offers, with their English display names.</summary>
        public static readonly IDictionary<string, string> SupportedLanguages =
            new Dictionary<string, string>
            {
                ["en"] = "English",
                ["ms"] = "Bahasa Melayu",
                ["zh-CN"] = "中文 (简体)",
                ["zh-TW"] = "中文 (繁體)",
                ["ta"] = "தமிழ்",
                ["hi"] = "हिन्दी",
                ["ar"] = "العربية",
                ["ja"] = "日本語",
                ["ko"] = "한국어",
                ["es"] = "Español",
                ["fr"] = "Français",
            };

        public static bool IsConfigured => !string.IsNullOrEmpty(GetApiKey());

        public static bool IsSupported(string lang) =>
            !string.IsNullOrEmpty(lang) && SupportedLanguages.ContainsKey(lang);

        /// <summary>
        /// Translates <paramref name="texts"/> into <paramref name="target"/>. The
        /// returned array lines up 1:1 with the input. Cached entries are served
        /// locally; only the uncached strings are sent to Google in a single call.
        /// Translating into "en" (or an empty/unknown target) is a no-op echo.
        /// </summary>
        public static string[] Translate(IList<string> texts, string target)
        {
            if (texts == null) return new string[0];
            var result = new string[texts.Count];

            if (string.IsNullOrEmpty(target) || target == "en" || !IsSupported(target))
            {
                for (int i = 0; i < texts.Count; i++) result[i] = texts[i] ?? "";
                return result;
            }

            // Figure out which inputs still need a network translation.
            var pending = new List<string>();      // distinct uncached source strings
            var pendingIndex = new Dictionary<string, int>();
            for (int i = 0; i < texts.Count; i++)
            {
                string src = texts[i] ?? "";
                if (src.Length == 0) { result[i] = ""; continue; }

                string cacheKey = target + "" + src;
                if (Cache.TryGetValue(cacheKey, out string hit))
                {
                    result[i] = hit;
                }
                else if (!pendingIndex.ContainsKey(src))
                {
                    pendingIndex[src] = pending.Count;
                    pending.Add(src);
                }
            }

            if (pending.Count > 0)
            {
                string[] translated = CallGoogle(pending, target);
                for (int p = 0; p < pending.Count; p++)
                    Cache[target + "" + pending[p]] = translated[p];

                for (int i = 0; i < texts.Count; i++)
                {
                    if (result[i] != null) continue;            // served from cache above
                    string src = texts[i] ?? "";
                    result[i] = src.Length == 0 ? "" : translated[pendingIndex[src]];
                }
            }

            return result;
        }

        /// <summary>One POST to the Google endpoint; throws on transport/HTTP errors.</summary>
        private static string[] CallGoogle(IList<string> texts, string target)
        {
            string apiKey = GetApiKey();
            if (string.IsNullOrEmpty(apiKey))
                throw new InvalidOperationException(
                    "Google Translate API key is not configured (translate.config / GoogleTranslate:ApiKey).");

            var payload = new Dictionary<string, object>
            {
                ["q"] = texts,
                ["target"] = target,
                ["format"] = "text"
            };
            byte[] body = Encoding.UTF8.GetBytes(Json.Serialize(payload));

            ServicePointManager.SecurityProtocol = SecurityProtocolType.Tls12;

            var request = (HttpWebRequest)WebRequest.Create(Endpoint + "?key=" + Uri.EscapeDataString(apiKey));
            request.Method = "POST";
            request.ContentType = "application/json; charset=utf-8";
            request.Accept = "application/json";
            request.ContentLength = body.Length;
            request.Timeout = 30000;

            using (var stream = request.GetRequestStream())
                stream.Write(body, 0, body.Length);

            string responseText;
            using (var response = (HttpWebResponse)request.GetResponse())
            using (var reader = new StreamReader(response.GetResponseStream(), Encoding.UTF8))
                responseText = reader.ReadToEnd();

            // { "data": { "translations": [ { "translatedText": "..." }, ... ] } }
            var root = (Dictionary<string, object>)Json.DeserializeObject(responseText);
            var data = (Dictionary<string, object>)root["data"];
            var translations = (object[])data["translations"];

            return translations
                .Cast<Dictionary<string, object>>()
                .Select(t => Convert.ToString(t["translatedText"]))
                .ToArray();
        }

        /// <summary>Reads the API key from translate.config, falling back to appSettings.</summary>
        private static string GetApiKey()
        {
            const string key = "GoogleTranslate:ApiKey";
            try
            {
                string path = HostingEnvironment.MapPath("~/translate.config");
                if (path != null && File.Exists(path))
                {
                    var doc = new XmlDocument();
                    doc.Load(path);
                    var node = doc.DocumentElement?.SelectSingleNode("add[@key='" + key + "']") as XmlElement;
                    if (node != null) return node.GetAttribute("value").Trim();
                }
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine("Reading translate.config failed: " + ex.Message);
            }
            return (ConfigurationManager.AppSettings[key] ?? "").Trim();
        }
    }
}
