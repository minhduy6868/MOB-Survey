/**
 * Trovey → Google Sheets
 *
 * 1. Extensions → Apps Script, paste this file.
 * 2. Deploy → New deployment → Web app
 *    Execute as: Me
 *    Who has access: Anyone
 * 3. Copy the web app URL into Cloudflare secret SHEETS_WEBHOOK.
 * 4. First row becomes the header automatically.
 */
const HEADERS = [
  'clientId',
  'surveyId',
  'collectorName',
  'collectorId',
  'locale',
  'createdAt',
  'submittedAt',
  'siteCountry',
  'siteCity',
  'interviewPlace',
  'lat',
  'lng',
  'gpsAccuracy',
  'ageRange',
  'yearsTrading',
  'markets',
  'style',
  'hoursPerWeek',
  'platform',
  'usesStop',
  'informationSources',
  'biggestChallenge',
  'resultBand',
  'notes',
  'hasPhoto',
];

function doPost(e) {
  const sheet = SpreadsheetApp.getActiveSpreadsheet().getActiveSheet();
  if (sheet.getLastRow() === 0) {
    sheet.appendRow(HEADERS);
  }
  const data = JSON.parse(e.postData.contents);
  const row = HEADERS.map(function (key) {
    var value = data[key];
    return value === undefined || value === null ? '' : String(value);
  });
  const existing = sheet.getRange(2, 1, Math.max(sheet.getLastRow() - 1, 1), 1).getValues();
  let found = -1;
  for (var i = 0; i < existing.length; i++) {
    if (existing[i][0] === data.clientId) {
      found = i + 2;
      break;
    }
  }
  if (found > 0) {
    sheet.getRange(found, 1, 1, HEADERS.length).setValues([row]);
  } else {
    sheet.appendRow(row);
  }
  return ContentService.createTextOutput(JSON.stringify({ ok: true, clientId: data.clientId })).setMimeType(
    ContentService.MimeType.JSON,
  );
}
