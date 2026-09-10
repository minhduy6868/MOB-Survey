const dict = <String, ({String vi, String en})>{
  'brand': (vi: 'Trovey', en: 'Trovey'),
  'tagline': (
    vi: 'Khảo sát hiện trường về thói quen giao dịch của người trên thế giới.',
    en: 'Field interviews on how people trade, worldwide.',
  ),
  'homeCta': (vi: 'Bắt đầu phỏng vấn', en: 'Start interview'),
  'homeEyebrow': (vi: 'Phiếu hiện trường', en: 'Field kit'),
  'homeLead': (
    vi: 'Ba bước trên điện thoại. Mất mạng vẫn điền được. Có mạng thì phiếu tự gửi.',
    en: 'Three steps on this phone. Works without a signal. Sends when you are back online.',
  ),
  'queueHint': (vi: 'chờ gửi', en: 'waiting to send'),
  'emptyStub': (vi: 'TRỐNG', en: 'EMPTY'),
  'errorSummary': (
    vi: 'Còn mục bắt buộc chưa điền trên bước này.',
    en: 'Required fields on this step are still empty.',
  ),
  'history': (vi: 'Lịch sử', en: 'History'),
  'settings': (vi: 'Cài đặt', en: 'Settings'),
  'home': (vi: 'Trang chủ', en: 'Home'),
  'newInterview': (vi: 'Phỏng vấn mới', en: 'New interview'),
  'saveDraft': (vi: 'Lưu nháp', en: 'Save draft'),
  'submit': (vi: 'Gửi phiếu', en: 'Submit record'),
  'draftSaved': (vi: 'Đã lưu trên máy', en: 'Saved on this device'),
  'queued': (vi: 'Sẽ gửi khi có mạng', en: 'Will send when online'),
  'synced': (vi: 'Đã gửi', en: 'Sent'),
  'failed': (vi: 'Chưa gửi được. Thử lại.', en: 'Not sent. Try again.'),
  'exportCsv': (vi: 'Tải danh sách phiếu', en: 'Download interview list'),
  'csvCopied': (vi: 'Đã tải danh sách phiếu.', en: 'Interview list downloaded.'),
  'heroKicker': (vi: 'Chủ đề phỏng vấn', en: 'Interview topic'),
  'topicTitle': (
    vi: 'Thói quen giao dịch trên thế giới',
    en: 'How people trade, worldwide',
  ),
  'topicBody': (
    vi: 'Phỏng vấn người thật tại hiện trường: họ chơi thị trường nào, phong cách ra sao, khó khăn lớn nhất là gì. Ba mục: hiện trường, người được hỏi, thói quen.',
    en: 'Live interviews in the field: which markets, what style, and the hardest part. Three parts: site, person, habits.',
  ),
  'topicField': (vi: 'Hiện trường', en: 'Field site'),
  'topicPerson': (vi: 'Người được hỏi', en: 'Respondent'),
  'topicHabits': (vi: 'Thói quen giao dịch', en: 'Trading habits'),
  'heroTitle': (vi: 'Gặp người. Hỏi. Ghi phiếu.', en: 'Meet someone. Ask. File the ticket.'),
  'syncing': (vi: 'Đang gửi', en: 'Sending'),
  'draft': (vi: 'Nháp', en: 'Draft'),
  'online': (vi: 'Có mạng', en: 'Online'),
  'offline': (vi: 'Mất mạng', en: 'Offline'),
  'queue': (vi: 'Chờ gửi', en: 'Waiting'),
  'lastSync': (vi: 'Lần gửi gần nhất', en: 'Last send'),
  'required': (vi: 'Cần điền mục này', en: 'This field is required'),
  'resume': (vi: 'Tiếp tục nháp', en: 'Resume draft'),
  'emptyHistory': (
    vi: 'Chưa có phiếu. Bắt đầu phỏng vấn đầu tiên.',
    en: 'No records yet. Start the first interview.',
  ),
  'collectorName': (vi: 'Người điều tra', en: 'Collector'),
  'collectorId': (vi: 'MSSV', en: 'Student ID'),
  'chooseCountry': (vi: 'Chọn quốc gia', en: 'Choose a country'),
  'collectorSite': (vi: 'Trang web', en: 'Website'),
  'collectorLocked': (vi: 'Gán cứng cho bài này.', en: 'Fixed for this assignment.'),
  'language': (vi: 'Ngôn ngữ', en: 'Language'),
  'theme': (vi: 'Giao diện', en: 'Theme'),
  'paper': (vi: 'Trời sáng', en: 'Day'),
  'night': (vi: 'Đêm', en: 'Night'),
  'captureGps': (vi: 'Lấy tọa độ', en: 'Capture location'),
  'skipGps': (vi: 'Bỏ qua vị trí', en: 'Skip location'),
  'skipReason': (vi: 'Lý do bỏ qua', en: 'Skip reason'),
  'syncNotifyTitle': (vi: 'Đã gửi phiếu', en: 'Interview sent'),
  'syncNotifyBody': (vi: 'Phiếu đã vào Cloudflare.', en: 'The record is in Cloudflare.'),
  'shellNative': (vi: 'Vỏ native (Capacitor)', en: 'Native shell (Capacitor)'),
  'shellWeb': (vi: 'Trình duyệt / PWA', en: 'Browser / PWA'),
  'takePhoto': (vi: 'Chụp / chọn ảnh', en: 'Take / choose photo'),
  'removePhoto': (vi: 'Xóa ảnh', en: 'Remove photo'),
  'yes': (vi: 'Có', en: 'Yes'),
  'no': (vi: 'Không', en: 'No'),
  'retry': (vi: 'Gửi lại', en: 'Retry'),
  'delete': (vi: 'Xóa khỏi máy', en: 'Delete on device'),
  'confirmDelete': (
    vi: 'Xóa phiếu này trên máy? Bản đã gửi vẫn còn.',
    en: 'Delete this record on the device? Sent copies stay.',
  ),
  'filterAll': (vi: 'Tất cả', en: 'All'),
  'back': (vi: 'Về', en: 'Back'),
  'installHint': (
    vi: 'Cài ra máy để mở như ứng dụng, dùng khi mất mạng.',
    en: 'Install on the phone to open like an app, even offline.',
  ),
  'installTitle': (vi: 'Cài Trovey lên điện thoại', en: 'Install Trovey on the phone'),
  'installLead': (
    vi: 'Hai cách trên Android: cài ra màn hình chính, hoặc tải file cài đặt.',
    en: 'On Android you can pin Trovey to the home screen, or install the app file.',
  ),
  'installHome': (vi: 'Cài ra màn hình chính', en: 'Add to home screen'),
  'installApk': (vi: 'Tải file cài Android', en: 'Download Android file'),
  'installAndroidCta': (vi: 'Cài ra màn hình chính', en: 'Add to home screen'),
  'installIosCta': (vi: 'Cách thêm trên iPhone', en: 'How to add on iPhone'),
  'installAndroidHint': (
    vi: 'Giữ icon Trovey trên màn hình chính. Lần sau mở như ứng dụng, không cần vào trình duyệt.',
    en: 'Keep the Trovey icon on the home screen. Next time it opens like an app.',
  ),
  'installIosHint': (
    vi: 'Trên iPhone: Share, rồi Thêm vào Màn hình chính.',
    en: 'On iPhone: Share, then Add to Home Screen.',
  ),
  'installIosSteps': (
    vi: '1. Mở trang này bằng Safari\n2. Chạm nút Chia sẻ (ô vuông và mũi tên)\n3. Kéo xuống, chọn Thêm vào Màn hình chính\n4. Đặt tên Trovey, chạm Thêm\n5. Mở icon trên màn hình. Dùng được khi mất mạng.',
    en: '1. Open this page in Safari\n2. Tap Share (square with arrow)\n3. Scroll, then Add to Home Screen\n4. Name it Trovey, tap Add\n5. Open the icon. It works offline.',
  ),
  'installManual': (
    vi: 'Dùng menu trình duyệt, chọn Cài ứng dụng hoặc Thêm vào màn hình chính.',
    en: 'Use the browser menu, then Install app or Add to Home screen.',
  ),
  'installed': (vi: 'Đã cài. Đang mở như ứng dụng.', en: 'Installed. Running as an app.'),
  'hoursUnit': (vi: 'giờ', en: 'hours'),
  'recent': (vi: 'Phiếu gần đây', en: 'Recent records'),
  'lastDraft': (vi: 'Nháp đang mở', en: 'Open draft'),
  'open': (vi: 'Mở', en: 'Open'),
  'never': (vi: 'chưa', en: 'never'),
  'submitting': (vi: 'Đang gửi…', en: 'Submitting…'),
  'next': (vi: 'Tiếp', en: 'Next'),
  'seeResults': (vi: 'Gửi và xem kết quả', en: 'Submit and see results'),
  'step': (vi: 'Bước', en: 'Step'),
  'results': (vi: 'Kết quả', en: 'Results'),
  'resultsLead': (
    vi: 'Tổng hợp phiếu đã gửi trên máy này: thị trường, phong cách, cắt lỗ.',
    en: 'Totals from submitted tickets on this device: markets, style, stops.',
  ),
  'submittedCount': (vi: 'phiếu đã gửi', en: 'submitted tickets'),
  'thisInterview': (vi: 'Phiếu vừa gửi', en: 'This interview'),
  'marketsChart': (vi: 'Thị trường được chọn', en: 'Markets chosen'),
  'styleChart': (vi: 'Phong cách giao dịch', en: 'Trading styles'),
  'stopChart': (vi: 'Có dùng cắt lỗ', en: 'Uses a stop'),
};

String tr(String locale, String key) {
  final row = dict[key];
  if (row == null) return key;
  return locale == 'en' ? row.en : row.vi;
}

String statusLabel(String locale, String status) {
  switch (status) {
    case 'queued':
      return tr(locale, 'queued');
    case 'synced':
      return tr(locale, 'synced');
    case 'failed':
      return tr(locale, 'failed');
    case 'syncing':
      return tr(locale, 'syncing');
    default:
      return tr(locale, 'draft');
  }
}
