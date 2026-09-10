const COLLECTOR = {
  name: 'Nguyễn Minh Duy',
  id: '23IT038',
  site: 'minhduyy.id.vn',
  url: 'https://minhduyy.id.vn',
  fullName: 'Nguyễn Minh Duy - minhduyy.id.vn',
};

const API = 'https://app.puretrovey.net';
const SURVEY_ID = 'trading-world-v1';

const COUNTRIES = [
  'Việt Nam', 'Hoa Kỳ', 'Trung Quốc', 'Nhật Bản', 'Hàn Quốc', 'Đài Loan', 'Hồng Kông',
  'Singapore', 'Thái Lan', 'Malaysia', 'Indonesia', 'Philippines', 'Campuchia', 'Lào',
  'Myanmar', 'Ấn Độ', 'Úc', 'New Zealand', 'Anh', 'Đức', 'Pháp', 'Ý', 'Tây Ban Nha',
  'Hà Lan', 'Thụy Sĩ', 'Thụy Điển', 'Na Uy', 'Đan Mạch', 'Phần Lan', 'Nga', 'Ukraina',
  'Ba Lan', 'Thổ Nhĩ Kỳ', 'UAE', 'Ả Rập Xê Út', 'Israel', 'Nam Phi', 'Ai Cập',
  'Nigeria', 'Brazil', 'Argentina', 'Mexico', 'Canada', 'Khác',
];

const PLACES = [
  ['home', 'Nhà riêng'],
  ['office', 'Văn phòng / công ty'],
  ['cafe', 'Quán / không gian công cộng'],
  ['floor', 'Sàn / phòng giao dịch'],
  ['campus', 'Trường / ký túc'],
  ['remote', 'Gọi từ xa'],
  ['other', 'Khác'],
];

const AGES = [
  ['u18', 'Dưới 18'],
  ['18-24', '18–24'],
  ['25-34', '25–34'],
  ['35-44', '35–44'],
  ['45-54', '45–54'],
  ['55p', '55+'],
];

const YEARS = [
  ['lt1', 'Dưới 1 năm'],
  ['1-3', '1–3 năm'],
  ['3-7', '3–7 năm'],
  ['7p', 'Trên 7 năm'],
];

const MARKETS = [
  ['stocks', 'Cổ phiếu'],
  ['forex', 'Forex'],
  ['crypto', 'Crypto'],
  ['futures', 'Futures'],
  ['options', 'Options'],
  ['commodities', 'Hàng hóa'],
  ['indices', 'Chỉ số'],
];

const STYLES = [
  ['day', 'Day trade'],
  ['swing', 'Swing'],
  ['position', 'Position / đầu tư'],
  ['algo', 'Algo / bot'],
  ['copy', 'Copy / signal'],
];

const SOURCES = [
  ['chart', 'Tự đọc chart'],
  ['news', 'Tin tức / calendar'],
  ['social', 'Mạng xã hội / Telegram'],
  ['paid', 'Nhóm trả phí / mentor'],
  ['broker', 'Broker / research'],
  ['friends', 'Bạn bè / gia đình'],
];

const RESULTS = [
  ['na', 'Không muốn nói'],
  ['loss', 'Thua trong 3 tháng gần nhất'],
  ['flat', 'Hòa vốn'],
  ['small', 'Lãi nhẹ'],
  ['strong', 'Lãi rõ'],
];

function emptyAnswers() {
  return {
    respondentName: '',
    respondentPhone: '',
    siteCountry: '',
    siteCity: '',
    interviewPlace: '',
    gps: null,
    gpsSkipped: '',
    ageRange: '',
    yearsTrading: '',
    markets: [],
    style: '',
    hoursPerWeek: '',
    platform: '',
    usesStop: '',
    informationSources: [],
    biggestChallenge: '',
    resultBand: '',
    notes: '',
  };
}

function requiredOf(step) {
  if (step === 0) return ['siteCountry', 'interviewPlace'];
  if (step === 1) return ['respondentName', 'ageRange', 'yearsTrading', 'markets', 'style', 'hoursPerWeek'];
  return ['platform', 'usesStop', 'informationSources', 'biggestChallenge'];
}

function isFilled(answers, key) {
  const value = answers[key];
  if (Array.isArray(value)) return value.length > 0;
  return value != null && String(value).trim() !== '';
}
