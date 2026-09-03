const dict = <String, ({String vi, String en})>{
  'brand': (vi: 'Trovey', en: 'Trovey'),
  'tagline': (
    vi: 'Phiếu điều tra hiện trường — thói quen trading của người trên thế giới.',
    en: 'Field interviews on how people trade, worldwide.',
  ),
  'homeCta': (vi: 'Bắt đầu phỏng vấn', en: 'Start interview'),
  'homeEyebrow': (vi: 'Phiếu hiện trường', en: 'Field kit'),
  'homeLead': (
    vi: 'Điền 3 bước trên máy, dùng offline. Có mạng thì Trovey gửi lên Google Sheet.',
    en: 'Three steps on this device, offline. When you are online, Trovey sends the ticket to Google Sheet.',
  ),
  'queueHint': (vi: 'đang chờ gửi', en: 'waiting to send'),
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
  'synced': (vi: 'Đã lên Google Sheet', en: 'On Google Sheet'),
  'failed': (vi: 'Gửi lỗi — thử lại', en: 'Send failed — retry'),
  'syncing': (vi: 'Đang đồng bộ', en: 'Syncing'),
  'draft': (vi: 'Nháp', en: 'Draft'),
  'online': (vi: 'ONLINE', en: 'ONLINE'),
  'offline': (vi: 'OFFLINE', en: 'OFFLINE'),
  'queue': (vi: 'QUEUE', en: 'QUEUE'),
  'lastSync': (vi: 'SYNC', en: 'SYNC'),
  'required': (vi: 'Cần điền mục này', en: 'This field is required'),
  'resume': (vi: 'Tiếp tục nháp', en: 'Resume draft'),
  'emptyHistory': (
    vi: 'Chưa có phiếu. Bắt đầu phỏng vấn đầu tiên.',
    en: 'No records yet. Start the first interview.',
  ),
  'collectorName': (vi: 'Tên người điều tra', en: 'Collector name'),
  'collectorId': (vi: 'Mã SV / ID (tuỳ chọn)', en: 'Student / staff ID (optional)'),
  'language': (vi: 'Ngôn ngữ', en: 'Language'),
  'theme': (vi: 'Giao diện', en: 'Theme'),
  'paper': (vi: 'Trời sáng', en: 'Day sky'),
  'night': (vi: 'Đêm', en: 'Night'),
  'captureGps': (vi: 'Lấy tọa độ', en: 'Capture location'),
  'skipGps': (vi: 'Bỏ qua GPS', en: 'Skip GPS'),
  'skipReason': (vi: 'Lý do bỏ qua', en: 'Skip reason'),
  'takePhoto': (vi: 'Chụp / chọn ảnh', en: 'Take / choose photo'),
  'removePhoto': (vi: 'Xóa ảnh', en: 'Remove photo'),
  'yes': (vi: 'Có', en: 'Yes'),
  'no': (vi: 'Không', en: 'No'),
  'retry': (vi: 'Gửi lại', en: 'Retry'),
  'delete': (vi: 'Xóa khỏi máy', en: 'Delete on device'),
  'confirmDelete': (
    vi: 'Xóa phiếu này trên máy? Sheet đã sync sẽ không bị xóa.',
    en: 'Delete this record on the device? Synced sheet rows stay.',
  ),
  'diagnostics': (vi: 'Chẩn đoán PWA', en: 'PWA diagnostics'),
  'filterAll': (vi: 'Tất cả', en: 'All'),
  'back': (vi: 'Về', en: 'Back'),
  'installHint': (
    vi: 'Cài ra màn hình chính để mở như app, dùng offline.',
    en: 'Install to the home screen to open like an app, offline.',
  ),
  'installTitle': (vi: 'Cài Trovey ra màn hình chính', en: 'Install Trovey on the home screen'),
  'installAndroidCta': (vi: 'Cài ứng dụng', en: 'Install app'),
  'installIosCta': (vi: 'Cách thêm trên iPhone', en: 'How to add on iPhone'),
  'installAndroidHint': (
    vi: 'Chrome / Edge: bấm Cài ứng dụng. Lần sau mở icon Trovey, không cần trình duyệt.',
    en: 'Chrome / Edge: tap Install app. Next time open the Trovey icon, no browser chrome.',
  ),
  'installIosHint': (
    vi: 'Safari trên iPhone / iPad không có nút cài sẵn. Thêm bằng Share → Add to Home Screen.',
    en: 'Safari on iPhone / iPad has no install prompt. Use Share → Add to Home Screen.',
  ),
  'installIosSteps': (
    vi: '1. Mở trang này bằng Safari\n2. Chạm nút Chia sẻ (ô vuông + mũi tên)\n3. Kéo xuống → Thêm vào Màn hình chính\n4. Đặt tên Trovey → Thêm\n5. Mở icon trên màn hình — chạy standalone, offline.',
    en: '1. Open this page in Safari\n2. Tap Share (square with arrow)\n3. Scroll → Add to Home Screen\n4. Name it Trovey → Add\n5. Open the icon — standalone, offline.',
  ),
  'installManual': (
    vi: 'Trình duyệt không hiện hộp thoại cài. Dùng menu (⋮) → Cài ứng dụng / Thêm vào màn hình chính.',
    en: 'This browser has no install dialog. Use the menu (⋮) → Install app / Add to Home screen.',
  ),
  'installed': (vi: 'Đã cài — đang mở như ứng dụng.', en: 'Installed — running as an app.'),
  'hoursUnit': (vi: 'giờ', en: 'hours'),
  'recent': (vi: 'Phiếu gần đây', en: 'Recent records'),
  'lastDraft': (vi: 'Nháp đang mở', en: 'Open draft'),
  'open': (vi: 'Mở', en: 'Open'),
  'never': (vi: 'chưa', en: 'never'),
  'submitting': (vi: 'Đang gửi…', en: 'Submitting…'),
  'webhook': (vi: 'Đích đồng bộ', en: 'Sync target'),
  'webhookReady': (vi: 'Cloudflare → Google Sheet', en: 'Cloudflare → Google Sheet'),
  'next': (vi: 'Tiếp', en: 'Next'),
  'seeResults': (vi: 'Gửi và xem kết quả', en: 'Submit and see results'),
  'step': (vi: 'Bước', en: 'Step'),
  'results': (vi: 'Kết quả', en: 'Results'),
  'resultsLead': (
    vi: 'Tổng hợp phiếu đã gửi trên máy này — thị trường, phong cách, stop-loss.',
    en: 'Totals from submitted tickets on this device — markets, style, stops.',
  ),
  'submittedCount': (vi: 'phiếu đã gửi', en: 'submitted tickets'),
  'thisInterview': (vi: 'Phiếu vừa gửi', en: 'This interview'),
  'marketsChart': (vi: 'Thị trường được chọn', en: 'Markets chosen'),
  'styleChart': (vi: 'Phong cách giao dịch', en: 'Trading styles'),
  'stopChart': (vi: 'Có dùng stop-loss', en: 'Uses a stop-loss'),
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
