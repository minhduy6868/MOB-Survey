# Trovey

**Môn:** Cross-Platform Mobile App Development (VKU)  
**Sinh viên:** Nguyễn Minh Duy — 23IT038

PWA phỏng vấn hiện trường về thói quen giao dịch. Phiếu lưu trên máy (IndexedDB / Hive). Có mạng thì `POST /api/sync` vào Cloudflare KV.

Repo này có **hai bản cùng một đề bài**, hai link live. Chọn một bản để mở — không phải hai app khác nhau về nghiệp vụ.

## Chọn bản nào?

| | **PWA HTML/JS** — nhánh `main` | **PWA Flutter** — nhánh `mob-flutter` |
|---|---|---|
| Dùng khi | Muốn bản vanilla, không cần Flutter SDK | Muốn bản làm bằng Flutter |
| Live | https://pwa.puretrovey.net/ | https://app.puretrovey.net/ |
| Fallback | https://trovey-pwa.pages.dev/ | https://trovey.pages.dev/ |
| Mã nguồn | folder `pwa/` | folder `app/` |
| Cài Android | APK Capacitor bọc `pwa/` | Capacitor bọc Flutter web |

- Người dùng / giảng viên: bấm **một** trong hai link trên. Cả hai cùng sync về `https://app.puretrovey.net/api/sync`.
- Lập trình: clone xong đang ở `main` (HTML/JS). Bản Flutter:

```bash
git checkout mob-flutter
```

GitHub: https://github.com/minhduy6868/MOB-Survey  
Báo cáo tuần 3: [docs/Mini-Project-1-Technical-Report.pdf](docs/Mini-Project-1-Technical-Report.pdf)

Week 5: cùng web app chạy trong vỏ Capacitor (Android). Sync và form không đổi. Plugin native: Camera, Geolocation, Filesystem, Local Notifications.

---

## PWA HTML/JS (`main`)

Mở `pwa/index.html` qua HTTP (không mở file://).

```powershell
npx --yes serve pwa -p 4173
```

Trình duyệt: http://localhost:4173/

Có nút **Tải file cài Android** (`/downloads/trovey.apk`). Lần đầu mở, app hỏi Camera / GPS / thông báo. Trang **Kết quả** vẽ biểu đồ tổng mẫu (thị trường, phong cách, stop-loss, tuổi, nơi gặp…).

## Capacitor Android — bản HTML/JS

Cần Android SDK và **JDK 21+** (Capacitor 7). JDK 17 sẽ lỗi `invalid source release: 21`.

```powershell
npm install
python logos/apply_android_brand.py
npx cap sync android
cd android
.\gradlew.bat assembleDebug
```

APK: `android/app/build/outputs/apk/debug/app-debug.apk`  
Copy thành `pwa/downloads/trovey.apk` nếu muốn nút tải trên PWA trỏ đúng file mới.

Trên máy: cấp Camera, Vị trí, Thông báo. Icon launcher và màn hình splash là logo Trovey (clipboard), không phải logo Capacitor.

| Plugin | Trên web | File |
|---|---|---|
| `@capacitor/camera` | file input | `pwa/native.js` |
| `@capacitor/geolocation` | `navigator.geolocation` | `pwa/native.js` |
| `@capacitor/filesystem` | — | JPEG vào `DATA/photos/` |
| `@capacitor/local-notifications` | Web Notification | khi phiếu `synced` |

PWA trình duyệt không đi plugin native. Capacitor chỉ khi `Capacitor.isNativePlatform()`.

## PWA Flutter (`mob-flutter`)

```powershell
git checkout mob-flutter
cd app
flutter pub get
flutter run -d chrome --dart-define=SYNC_URL=https://app.puretrovey.net/api/sync
```

Build web rồi bọc Capacitor (webDir lúc đó là `app/build/web`):

```powershell
cd app
flutter build web --release --base-href /
cd ..
npx cap sync android
npx cap open android
```

## Cấu trúc trên `main`

```
pwa/                 PWA HTML/JS → pwa.puretrovey.net
android/             Capacitor Android (bọc pwa/)
functions/api/       /api/sync, /api/records
sheets/Code.gs       kéo KV vào Sheet
capacitor.config.json
wrangler.toml        API + Flutter Pages (app.puretrovey.net)
wrangler.pwa.toml    PWA HTML/JS (pwa.puretrovey.net)
```

Folder `app/` vẫn là mã Flutter (để đối chiếu). Nhánh làm việc của Flutter là **`mob-flutter`**.

## Offline (PWA HTML/JS)

| Thành phần | Vị trí |
|---|---|
| Manifest standalone | `pwa/manifest.json` |
| Service Worker | `pwa/sw.js` (`trovey-pwa-shell-v9`) |
| IndexedDB | `trovey-pwa` / `tickets` |
| Native shell | Capacitor, không đăng ký SW |

## Deploy

Không commit token.

PWA HTML/JS:

```powershell
npx wrangler pages deploy pwa --project-name trovey-pwa --commit-dirty=true
npx wrangler deploy -c wrangler.pwa.toml
```

Flutter web (từ nhánh `mob-flutter`, sau `flutter build web`):

```powershell
npx wrangler pages deploy app/build/web --project-name trovey
```

## Google Sheet

1. Dán `sheets/Code.gs` vào Apps Script.
2. Chạy `beautifyAndSync`.

CSV: https://app.puretrovey.net/api/records?format=csv
