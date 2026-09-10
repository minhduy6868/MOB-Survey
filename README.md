# Trovey (Flutter)

**Nhánh này là bản Flutter.** Repo có hai lựa chọn:

| Bản | Nhánh | Live |
|---|---|---|
| **PWA HTML/JS** | `main` | https://pwa.puretrovey.net/ |
| **PWA Flutter** (đây) | `mob-flutter` | https://app.puretrovey.net/ |

Cùng một phiếu, cùng `POST /api/sync`. Muốn bản không cần Flutter SDK thì `git checkout main`.

---

**Course:** Cross-Platform Mobile App Development (VKU)  
**Student:** Nguyễn Minh Duy — 23IT038

| Deliverable | URL |
|---|---|
| Live PWA (Flutter, nhánh này) | https://app.puretrovey.net/ |
| Live PWA (HTML/JS, nhánh `main`) | https://pwa.puretrovey.net/ |
| Fallback Flutter | https://trovey.pages.dev/ |
| Fallback HTML/JS | https://trovey-pwa.pages.dev/ |
| GitHub | https://github.com/minhduy6868/MOB-Survey |
| Week 3 report | [docs/Mini-Project-1-Technical-Report.pdf](docs/Mini-Project-1-Technical-Report.pdf) |

PWA phỏng vấn hiện trường. Phiếu lưu Hive (IndexedDB trên web). Có mạng thì `POST /api/sync` vào Cloudflare KV.

Week 5: cùng web app đó chạy trong vỏ Capacitor (Android). Sync, form, Hive không đổi. Đổi 3 API phần cứng: Camera, Geolocation, Filesystem + thông báo khi sync xong.

## Chạy PWA (Chrome)

```bash
cd app
flutter pub get
flutter run -d chrome --dart-define=SYNC_URL=https://app.puretrovey.net/api/sync
```

## Capacitor Android (Week 5)

Cần Flutter SDK, Android SDK, và **JDK 21** (Capacitor 7). Máy đang JDK 17 sẽ lỗi `invalid source release: 21`.

```bash
npm install
cd app
flutter build web --release --base-href /
cd ..
npx cap sync android
npx cap open android
```

Hoặc APK debug:

```bash
cd android
.\gradlew.bat assembleDebug
```

File ra: `android/app/build/outputs/apk/debug/app-debug.apk`

Trên máy: cấp quyền Camera, Vị trí, Thông báo. Chụp ảnh / lấy GPS / gửi phiếu khi mất mạng rồi bật mạng.

| Plugin | Thay | File |
|---|---|---|
| `@capacitor/camera` | `image_picker` / file input | `app/web/native.js` → `InstallBridge.takePhoto` |
| `@capacitor/geolocation` | `navigator.geolocation` | `InstallBridge.captureGps` |
| `@capacitor/filesystem` | (mới) | lưu JPEG vào `DATA/photos/` trước khi Hive |
| `@capacitor/local-notifications` | Web Push | thông báo khi `synced` |

PWA trên trình duyệt vẫn dùng `image_picker` / `geolocator`. Capacitor chỉ khi `Capacitor.isNativePlatform()`.

`@capacitor/push-notifications` cần Firebase (`google-services.json`). Lab dùng Local Notifications cho cùng mục: báo khi sync xong, app không cần mở trình duyệt.

## Cấu trúc

```
app/lib/             UI, Hive, hàng đợi sync
app/web/             manifest, sw.js, native.js
android/             project Capacitor (Android Studio)
functions/api/       /api/sync, /api/records
sheets/Code.gs       kéo KV vào Sheet
capacitor.config.json
```

## Offline (PWA)

| Thành phần | Vị trí |
|---|---|
| Manifest standalone | `app/web/manifest.json` |
| Service Worker | `app/web/sw.js` (`trovey-shell-v10`) |
| Hive | `tickets-v3` |
| Native shell | Capacitor, không đăng ký SW |

## Deploy web

Không commit token.

```powershell
cd app
flutter build web --release --base-href /
cd ..
npx wrangler pages deploy app/build/web --project-name trovey
```

## Google Sheet

1. Dán `sheets/Code.gs` vào Apps Script.
2. Chạy `beautifyAndSync`.

CSV: https://app.puretrovey.net/api/records?format=csv
