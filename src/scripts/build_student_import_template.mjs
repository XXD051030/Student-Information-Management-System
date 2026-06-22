import fs from "node:fs/promises";
import path from "node:path";
import os from "node:os";
import { SpreadsheetFile, Workbook } from "@oai/artifact-tool";

const outputDir = path.resolve("admin/templates");
await fs.mkdir(outputDir, { recursive: true });

const workbook = Workbook.create();
const sheet = workbook.worksheets.add("Student Import");
sheet.showGridLines = false;
sheet.freezePanes.freezeRows(4);

sheet.getRange("A1:F1").merge();
sheet.getRange("A1").values = [["Student Bulk Import Template"]];
sheet.getRange("A1:F1").format = {
  fill: "#E0162B",
  font: { bold: true, color: "#FFFFFF", size: 16 },
  verticalAlignment: "center",
};
sheet.getRange("A1:F1").format.rowHeight = 30;

sheet.getRange("A2:F2").merge();
sheet.getRange("A2").values = [[
  "Enter one student per row. Do not rename the headers. Programme Code must match a programme already configured in the system."
]];
sheet.getRange("A2:F2").format = {
  fill: "#FFF1F2",
  font: { color: "#9F1239", italic: true },
  wrapText: true,
};
sheet.getRange("A2:F2").format.rowHeight = 32;

sheet.getRange("A4:F6").values = [
  ["Full Name", "Institutional Email", "Personal Email", "Phone", "Programme Code", "Status"],
  ["", "", "", "", "", ""],
  ["", "", "", "", "", ""],
];
sheet.getRange("A4:F4").format = {
  fill: "#1E293B",
  font: { bold: true, color: "#FFFFFF" },
  verticalAlignment: "center",
};
sheet.getRange("A4:F4").format.rowHeight = 25;
sheet.getRange("A5:F205").format.borders = {
  insideHorizontal: { style: "thin", color: "#E2E8F0" },
  bottom: { style: "thin", color: "#CBD5E1" },
};
sheet.getRange("F5:F205").dataValidation = {
  rule: { type: "list", values: ["Active", "Pending", "Inactive"] },
};
sheet.getRange("A5:F205").format.font = { color: "#334155" };
sheet.getRange("A:A").format.columnWidth = 24;
sheet.getRange("B:C").format.columnWidth = 30;
sheet.getRange("D:D").format.columnWidth = 20;
sheet.getRange("E:E").format.columnWidth = 19;
sheet.getRange("F:F").format.columnWidth = 14;

const preview = await workbook.render({
  sheetName: "Student Import",
  range: "A1:F8",
  scale: 1.5,
  format: "png",
});
await fs.writeFile(path.join(os.tmpdir(), "student_bulk_import_template_preview.png"),
  new Uint8Array(await preview.arrayBuffer()));

const output = await SpreadsheetFile.exportXlsx(workbook);
await output.save(path.join(outputDir, "student_bulk_import_template.xlsx"));

const inspection = await workbook.inspect({
  kind: "table",
  range: "Student Import!A1:F6",
  include: "values,formulas",
  tableMaxRows: 8,
  tableMaxCols: 6,
});
console.log(inspection.ndjson);
