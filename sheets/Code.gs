/**
 * Trovey Sheet: bản đẹp của Cloudflare KV.
 *
 * 1. Dán đè file này vào Apps Script.
 * 2. Chạy beautifyAndSync (cho phép quyền).
 * 3. Menu Trovey → Đồng bộ và làm đẹp.
 *
 * Xóa tab Cloudflare (IMPORTDATA). Dữ liệu nằm tab Phiếu.
 */
const SPREADSHEET_ID = '1IjhJndE__6zrPtDAAtlTfKvcHkVr1esCJWpGSR26w2g';
const CLOUD_JSON = 'https://app.puretrovey.net/api/records';
const TEAL = '#0E6E8A';
const INK = '#12262D';
const MIST = '#F4F7F8';
const WHITE = '#FFFFFF';
const LINE = '#D5DEE2';
const COLLECTOR = 'Nguyễn Minh Duy · minhduyy.id.vn · 23IT038';

const KEYS = [
  'collectorName',
  'collectorId',
  'respondentName',
  'respondentPhone',
  'submittedAt',
  'siteCountry',
  'siteCity',
  'interviewPlace',
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
];

const LABELS = [
  'Người điều tra',
  'MSSV',
  'Người được hỏi',
  'SĐT',
  'Thời điểm gửi',
  'Quốc gia',
  'Thành phố',
  'Nơi gặp',
  'Độ tuổi',
  'Số năm GD',
  'Thị trường',
  'Phong cách',
  'Giờ / tuần',
  'Sàn / app',
  'Cắt lỗ',
  'Nguồn tin',
  'Khó khăn lớn nhất',
  'Kết quả 3 tháng',
  'Ghi chú',
];

const WIDTHS = [220, 90, 160, 120, 150, 110, 110, 110, 90, 110, 140, 110, 90, 120, 80, 140, 220, 130, 180];

function onOpen() {
  SpreadsheetApp.getUi()
    .createMenu('Trovey')
    .addItem('Đồng bộ và làm đẹp', 'beautifyAndSync')
    .addToUi();
}

function doGet() {
  return json_({ ok: true, service: 'trovey-sheets' });
}

function doPost(e) {
  const lock = LockService.getScriptLock();
  lock.waitLock(15000);
  try {
    const data = parseBody_(e);
    if (!data.clientId) return json_({ ok: false, error: 'clientId required' });
    beautifyAndSync();
    return json_({ ok: true, clientId: data.clientId });
  } catch (err) {
    return json_({ ok: false, error: String(err) });
  } finally {
    lock.releaseLock();
  }
}

function syncFromCloudflare() {
  return beautifyAndSync();
}

function beautifyAndSync() {
  const ss = SpreadsheetApp.openById(SPREADSHEET_ID);
  retireOldTabs_(ss);
  const sheet = ensurePhieu_(ss);
  const records = fetchRecords_();
  paint_(sheet, records);
  return records.length;
}

function installTrigger() {
  ScriptApp.getProjectTriggers().forEach(function (t) {
    if (t.getHandlerFunction() === 'beautifyAndSync' || t.getHandlerFunction() === 'syncFromCloudflare') {
      ScriptApp.deleteTrigger(t);
    }
  });
  ScriptApp.newTrigger('beautifyAndSync').timeBased().everyMinutes(1).create();
}

function fetchRecords_() {
  const res = UrlFetchApp.fetch(CLOUD_JSON, { muteHttpExceptions: true });
  const body = JSON.parse(res.getContentText());
  if (!body || !body.ok || !body.records) {
    throw new Error('Cloudflare records not ok: ' + res.getResponseCode());
  }
  return body.records.filter(function (row) {
    const id = String(row.clientId || '');
    return id && id.indexOf('logo-smoke') !== 0 && id.indexOf('kv-check') !== 0;
  });
}

function retireOldTabs_(ss) {
  ['Cloudflare', 'Trang tính1'].forEach(function (name) {
    const tab = ss.getSheetByName(name);
    if (!tab) return;
    tab.clear();
    tab.getRange(1, 1).setValue('Đã chuyển sang tab Phiếu. Có thể xóa tab này.');
    tab.setTabColor('#D5DEE2');
  });
}

function ensurePhieu_(ss) {
  let sheet = ss.getSheetByName('Phiếu');
  if (!sheet) {
    sheet = ss.insertSheet('Phiếu', 0);
  }
  ss.setActiveSheet(sheet);
  return sheet;
}

function cell_(data, key) {
  if (key === 'collectorName') return 'Nguyễn Minh Duy - minhduyy.id.vn';
  if (key === 'collectorId') return '23IT038';
  if (key === 'submittedAt') {
    const raw = String(data.submittedAt || data.storedAt || '');
    return raw.replace('T', ' ').replace(/\.\d+Z$/, ' UTC').replace(/Z$/, ' UTC');
  }
  if (key === 'lat' && data.gps && data.gps.lat != null) return String(data.gps.lat);
  if (key === 'lng' && data.gps && data.gps.lng != null) return String(data.gps.lng);
  var value = data[key];
  if (value === undefined || value === null) return '';
  if (Object.prototype.toString.call(value) === '[object Array]') return value.join(', ');
  return String(value);
}

function paint_(sheet, records) {
  sheet.clear();
  sheet.clearConditionalFormatRules();
  sheet.setHiddenGridlines(true);
  sheet.setFrozenRows(3);
  sheet.setTabColor(TEAL);

  const cols = LABELS.length;
  sheet.getRange(1, 1, 1, cols).merge();
  sheet
    .getRange(1, 1)
    .setValue('TROVEY  ·  Thói quen giao dịch trên thế giới')
    .setBackground(TEAL)
    .setFontColor(WHITE)
    .setFontFamily('Arial')
    .setFontSize(16)
    .setFontWeight('bold')
    .setVerticalAlignment('middle')
    .setHorizontalAlignment('left');
  sheet.setRowHeight(1, 40);

  sheet.getRange(2, 1, 1, cols).merge();
  sheet
    .getRange(2, 1)
    .setValue('Người điều tra: ' + COLLECTOR + '    ·    Nguồn: Cloudflare KV    ·    ' + records.length + ' phiếu')
    .setBackground('#D5E6EC')
    .setFontColor(INK)
    .setFontFamily('Arial')
    .setFontSize(10)
    .setVerticalAlignment('middle');
  sheet.setRowHeight(2, 28);

  const header = sheet.getRange(3, 1, 1, cols);
  header
    .setValues([LABELS])
    .setBackground(TEAL)
    .setFontColor(WHITE)
    .setFontFamily('Arial')
    .setFontSize(10)
    .setFontWeight('bold')
    .setWrap(true)
    .setVerticalAlignment('middle')
    .setHorizontalAlignment('center');
  sheet.setRowHeight(3, 36);

  if (records.length === 0) {
    sheet.getRange(4, 1, 1, cols).merge();
    sheet
      .getRange(4, 1)
      .setValue('Chưa có phiếu thật. Khi gửi phỏng vấn trên app.puretrovey.net, chạy Trovey → Đồng bộ và làm đẹp.')
      .setBackground(MIST)
      .setFontColor(INK)
      .setFontFamily('Arial')
      .setFontSize(11);
  } else {
    const values = records.map(function (row) {
      return KEYS.map(function (key) {
        return cell_(row, key);
      });
    });
    const body = sheet.getRange(4, 1, values.length, cols);
    body
      .setValues(values)
      .setFontFamily('Arial')
      .setFontSize(10)
      .setFontColor(INK)
      .setWrap(true)
      .setVerticalAlignment('middle');
    body.setBorder(true, true, true, true, true, true, LINE, SpreadsheetApp.BorderStyle.SOLID);
    for (var r = 0; r < values.length; r++) {
      sheet.getRange(4 + r, 1, 1, cols).setBackground(r % 2 === 0 ? WHITE : MIST);
    }
    sheet.getRange(4, 1, values.length, 2).setFontWeight('bold');
  }

  for (var c = 0; c < WIDTHS.length; c++) {
    sheet.setColumnWidth(c + 1, WIDTHS[c]);
  }

  const lastRow = Math.max(4, 3 + records.length);
  sheet.getRange(3, 1, lastRow - 2, cols).createFilter();
  sheet.setRowHeights(4, Math.max(1, records.length), 28);
}

function parseBody_(e) {
  if (e && e.postData && e.postData.contents) return JSON.parse(e.postData.contents);
  if (e && e.parameter && e.parameter.payload) return JSON.parse(e.parameter.payload);
  return {};
}

function json_(obj) {
  return ContentService.createTextOutput(JSON.stringify(obj)).setMimeType(ContentService.MimeType.JSON);
}
