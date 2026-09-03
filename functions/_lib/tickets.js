export const PREFIX = 'ticket:';
export const COLLECTOR_NAME = 'Nguyễn Minh Duy - minhduyy.id.vn';
export const COLLECTOR_ID = '23IT038';

const SKIP_IDS = new Set(['logo-smoke-20260903', 'kv-check-20260903']);

export const HEADERS = [
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

export const HEADER_LABELS = {
  collectorName: 'Người điều tra',
  collectorId: 'MSSV',
  respondentName: 'Người được hỏi',
  respondentPhone: 'SĐT',
  submittedAt: 'Thời điểm gửi',
  siteCountry: 'Quốc gia',
  siteCity: 'Thành phố',
  interviewPlace: 'Nơi gặp',
  ageRange: 'Độ tuổi',
  yearsTrading: 'Số năm giao dịch',
  markets: 'Thị trường',
  style: 'Phong cách',
  hoursPerWeek: 'Giờ / tuần',
  platform: 'Sàn / app',
  usesStop: 'Cắt lỗ',
  informationSources: 'Nguồn tin',
  biggestChallenge: 'Khó khăn lớn nhất',
  resultBand: 'Kết quả 3 tháng',
  notes: 'Ghi chú',
};

function prettyTime(value) {
  const text = String(value || '');
  if (!text) return '';
  return text.replace('T', ' ').replace(/\.\d+Z$/, ' UTC').replace(/Z$/, ' UTC');
}

export function flattenTicket(row) {
  const gps = row.gps && typeof row.gps === 'object' ? row.gps : null;
  const cell = (value) => {
    if (value === undefined || value === null) return '';
    if (Array.isArray(value)) return value.join(', ');
    return String(value);
  };
  return {
    collectorName: COLLECTOR_NAME,
    collectorId: COLLECTOR_ID,
    respondentName: cell(row.respondentName),
    respondentPhone: cell(row.respondentPhone),
    submittedAt: prettyTime(row.submittedAt || row.storedAt),
    siteCountry: cell(row.siteCountry),
    siteCity: cell(row.siteCity),
    interviewPlace: cell(row.interviewPlace),
    ageRange: cell(row.ageRange),
    yearsTrading: cell(row.yearsTrading),
    markets: cell(row.markets),
    style: cell(row.style),
    hoursPerWeek: cell(row.hoursPerWeek),
    platform: cell(row.platform),
    usesStop: cell(row.usesStop),
    informationSources: cell(row.informationSources),
    biggestChallenge: cell(row.biggestChallenge),
    resultBand: cell(row.resultBand),
    notes: cell(row.notes),
    lat: cell(gps ? gps.lat : row.lat),
    lng: cell(gps ? gps.lng : row.lng),
  };
}

function csvEscape(value) {
  const text = String(value ?? '');
  if (/[",\n\r]/.test(text)) return `"${text.replace(/"/g, '""')}"`;
  return text;
}

export function toCsv(rows) {
  const lines = [HEADERS.map((key) => HEADER_LABELS[key] || key).join(',')];
  for (const row of rows) {
    const flat = flattenTicket(row);
    lines.push(HEADERS.map((key) => csvEscape(flat[key])).join(','));
  }
  return `\uFEFF${lines.join('\n')}\n`;
}

export function isTestTicket(row) {
  const id = String(row.clientId || '');
  if (SKIP_IDS.has(id)) return true;
  return id.startsWith('logo-smoke') || id.startsWith('kv-check');
}

export async function listTickets(kv, limit = 1000) {
  const listed = await kv.list({ prefix: PREFIX, limit });
  const records = [];
  for (const key of listed.keys) {
    const raw = await kv.get(key.name);
    if (!raw) continue;
    try {
      const row = JSON.parse(raw);
      if (isTestTicket(row)) continue;
      records.push(row);
    } catch {
      /* skip */
    }
  }
  records.sort((a, b) =>
    String(b.storedAt || b.submittedAt || '').localeCompare(String(a.storedAt || a.submittedAt || '')),
  );
  return records;
}
