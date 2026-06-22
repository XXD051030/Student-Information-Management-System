using System;
using System.Collections.Generic;
using System.Globalization;
using System.Linq;
using System.Web.UI;
using src.services;

namespace src.student
{
    public partial class payment : src.security.StudentPage
    {
        protected void Page_Load(object sender, EventArgs e) { }

        protected void PayBtn_Click(object sender, EventArgs e)
        {
            decimal amount;
            if (!decimal.TryParse(hfAmount.Value, NumberStyles.Any, CultureInfo.InvariantCulture, out amount) || amount <= 0m)
                return;

            var user = UserContextFactory.FromSession(Session);

            // No real gateway — "Pay" always succeeds: record the payment...
            StudentPortalService.RecordPayment(
                user,
                amount,
                string.IsNullOrEmpty(hfDescription.Value) ? "Tuition payment" : hfDescription.Value,
                "Y2 · Semester 2 (Sep 2026)",
                string.IsNullOrEmpty(hfMethod.Value) ? "card" : hfMethod.Value);

            // ...then enrol the student in the carried courses.
            var ids = ParseOfferingIds(hfOfferingIds.Value);
            if (ids.Length > 0) StudentPortalService.Enrol(user, ids);

            Response.Redirect("payment-history.aspx");
        }

        private static int[] ParseOfferingIds(string csv)
        {
            if (string.IsNullOrWhiteSpace(csv)) return new int[0];
            var ids = new List<int>();
            foreach (var part in csv.Split(','))
            {
                int id;
                if (int.TryParse(part.Trim(), out id)) ids.Add(id);
            }
            return ids.Distinct().ToArray();
        }
    }
}
