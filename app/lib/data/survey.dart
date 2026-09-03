import 'countries.dart';
import 'models.dart';

const surveyId = 'trading-world-v1';

const sections = <SectionDef>[
  SectionDef(
    id: 'field',
    vi: 'Hiện trường',
    en: 'Field site',
    hintVi: 'Như phiếu điều tra xã hội học: nơi gặp người được hỏi.',
    hintEn: 'Where this interview is taking place.',
    fields: [
      FieldDef(id: 'siteCountry', type: FieldType.dropdown, required: true, options: countryOptions),
      FieldDef(id: 'siteCity', type: FieldType.text),
      FieldDef(
        id: 'interviewPlace',
        type: FieldType.single,
        required: true,
        options: [
          FieldOption('home', 'Nhà riêng', 'Home'),
          FieldOption('office', 'Văn phòng / công ty', 'Office'),
          FieldOption('cafe', 'Quán / không gian công cộng', 'Cafe / public'),
          FieldOption('floor', 'Sàn / phòng giao dịch', 'Trading floor'),
          FieldOption('campus', 'Trường / ký túc', 'Campus'),
          FieldOption('remote', 'Gọi từ xa', 'Remote call'),
          FieldOption('other', 'Khác', 'Other'),
        ],
      ),
      FieldDef(id: 'gps', type: FieldType.gps),
      FieldDef(id: 'photo', type: FieldType.photo),
    ],
  ),
  SectionDef(
    id: 'profile',
    vi: 'Người được hỏi',
    en: 'Respondent',
    fields: [
      FieldDef(id: 'respondentName', type: FieldType.text, required: true),
      FieldDef(id: 'respondentPhone', type: FieldType.phone),
      FieldDef(
        id: 'ageRange',
        type: FieldType.single,
        required: true,
        options: [
          FieldOption('u18', 'Dưới 18', 'Under 18'),
          FieldOption('18-24', '18–24', '18–24'),
          FieldOption('25-34', '25–34', '25–34'),
          FieldOption('35-44', '35–44', '35–44'),
          FieldOption('45-54', '45–54', '45–54'),
          FieldOption('55p', '55+', '55+'),
        ],
      ),
      FieldDef(
        id: 'yearsTrading',
        type: FieldType.single,
        required: true,
        options: [
          FieldOption('lt1', 'Dưới 1 năm', 'Under 1 year'),
          FieldOption('1-3', '1–3 năm', '1–3 years'),
          FieldOption('3-7', '3–7 năm', '3–7 years'),
          FieldOption('7p', 'Trên 7 năm', '7+ years'),
        ],
      ),
      FieldDef(
        id: 'markets',
        type: FieldType.multi,
        required: true,
        options: [
          FieldOption('stocks', 'Cổ phiếu', 'Stocks'),
          FieldOption('forex', 'Forex', 'Forex'),
          FieldOption('crypto', 'Crypto', 'Crypto'),
          FieldOption('futures', 'Futures', 'Futures'),
          FieldOption('options', 'Options', 'Options'),
          FieldOption('commodities', 'Hàng hóa', 'Commodities'),
          FieldOption('indices', 'Chỉ số', 'Indices'),
        ],
      ),
      FieldDef(
        id: 'style',
        type: FieldType.single,
        required: true,
        options: [
          FieldOption('day', 'Day trade', 'Day trade'),
          FieldOption('swing', 'Swing', 'Swing'),
          FieldOption('position', 'Position / đầu tư', 'Position / invest'),
          FieldOption('algo', 'Algo / bot', 'Algo / bot'),
          FieldOption('copy', 'Copy / signal', 'Copy / signal'),
        ],
      ),
      FieldDef(id: 'hoursPerWeek', type: FieldType.number, required: true),
    ],
  ),
  SectionDef(
    id: 'practice',
    vi: 'Thói quen',
    en: 'Practice',
    fields: [
      FieldDef(id: 'platform', type: FieldType.text, required: true),
      FieldDef(id: 'usesStop', type: FieldType.yesno, required: true),
      FieldDef(
        id: 'informationSources',
        type: FieldType.multi,
        required: true,
        options: [
          FieldOption('chart', 'Tự đọc chart', 'Own charting'),
          FieldOption('news', 'Tin tức / calendar', 'News / calendar'),
          FieldOption('social', 'Mạng xã hội / Telegram', 'Social / Telegram'),
          FieldOption('paid', 'Nhóm trả phí / mentor', 'Paid group / mentor'),
          FieldOption('broker', 'Broker / research', 'Broker research'),
          FieldOption('friends', 'Bạn bè / gia đình', 'Friends / family'),
        ],
      ),
      FieldDef(id: 'biggestChallenge', type: FieldType.long, required: true),
      FieldDef(
        id: 'resultBand',
        type: FieldType.single,
        options: [
          FieldOption('na', 'Không muốn nói', 'Prefer not to say'),
          FieldOption('loss', 'Thua trong 3 tháng gần nhất', 'Net loss last 3 months'),
          FieldOption('flat', 'Hòa vốn', 'Roughly flat'),
          FieldOption('small', 'Lãi nhẹ', 'Small net gain'),
          FieldOption('strong', 'Lãi rõ', 'Clear net gain'),
        ],
      ),
      FieldDef(id: 'notes', type: FieldType.long),
    ],
  ),
];

const fieldLabels = <String, ({String vi, String en})>{
  'respondentName': (vi: 'Tên người được hỏi', en: 'Respondent name'),
  'respondentPhone': (vi: 'Số điện thoại (nếu có)', en: 'Phone (optional)'),
  'siteCountry': (vi: 'Quốc gia phỏng vấn', en: 'Interview country'),
  'siteCity': (vi: 'Thành phố / vùng', en: 'City / region'),
  'interviewPlace': (vi: 'Nơi gặp', en: 'Meeting place'),
  'gps': (vi: 'Tọa độ hiện trường', en: 'Field coordinates'),
  'photo': (vi: 'Ảnh hiện trường (bàn, quán, sàn…)', en: 'Field photo (desk, cafe, floor…)'),
  'ageRange': (vi: 'Độ tuổi', en: 'Age range'),
  'yearsTrading': (vi: 'Số năm giao dịch', en: 'Years trading'),
  'markets': (vi: 'Thị trường đang chơi', en: 'Markets traded'),
  'style': (vi: 'Phong cách chính', en: 'Primary style'),
  'hoursPerWeek': (vi: 'Giờ/tuần dành cho thị trường', en: 'Hours per week on markets'),
  'platform': (vi: 'Sàn / app chính', en: 'Main broker / app'),
  'usesStop': (vi: 'Có dùng stop-loss gần như mọi lệnh?', en: 'Uses a stop on almost every trade?'),
  'informationSources': (vi: 'Nguồn thông tin', en: 'Information sources'),
  'biggestChallenge': (vi: 'Khó khăn lớn nhất khi trade', en: 'Biggest challenge while trading'),
  'resultBand': (vi: 'Kết quả 3 tháng gần nhất (tuỳ chọn)', en: 'Last 3 months result (optional)'),
  'notes': (vi: 'Ghi chú người điều tra', en: 'Collector notes'),
};

String fieldLabel(String id, String locale) {
  final row = fieldLabels[id];
  if (row == null) return id;
  return locale == 'en' ? row.en : row.vi;
}

Map<String, dynamic> emptyAnswers() => {
      'respondentName': '',
      'respondentPhone': '',
      'siteCountry': '',
      'siteCity': '',
      'interviewPlace': '',
      'gps': null,
      'gpsSkipped': '',
      'photoSkipped': '',
      'ageRange': '',
      'yearsTrading': '',
      'markets': <String>[],
      'style': '',
      'hoursPerWeek': '',
      'platform': '',
      'usesStop': '',
      'informationSources': <String>[],
      'biggestChallenge': '',
      'resultBand': '',
      'notes': '',
    };

Map<String, String> validate(Map<String, dynamic> answers) {
  final errors = <String, String>{};
  for (final section in sections) {
    for (final field in section.fields) {
      if (!field.required) continue;
      final value = answers[field.id];
      if (field.type == FieldType.multi) {
        if (value is! List || value.isEmpty) errors[field.id] = 'required';
      } else if (field.type == FieldType.number) {
        if (value == null || value.toString().isEmpty || double.tryParse(value.toString()) == null) {
          errors[field.id] = 'required';
        }
      } else if (value == null || value.toString().isEmpty) {
        errors[field.id] = 'required';
      }
    }
  }
  return errors;
}

Map<String, String> flattenAnswers(Map<String, dynamic> answers) {
  final out = <String, String>{};
  answers.forEach((key, value) {
    if (value is Map && value['lat'] != null) {
      out['lat'] = '${value['lat']}';
      out['lng'] = '${value['lng']}';
      out['gpsAccuracy'] = '${value['accuracy']}';
    } else if (value is List) {
      out[key] = value.join('|');
    } else {
      out[key] = value?.toString() ?? '';
    }
  });
  return out;
}
