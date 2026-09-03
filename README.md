# Trovey

**Course:** Cross-Platform Mobile App Development (VKU)  
**Mini-Project:** 1 — Week 3 PWA  
**Student:** Nguyễn Minh Duy — 23IT038

| Deliverable | URL |
|---|---|
| Live demo | https://app.puretrovey.net/ |
| GitHub | https://github.com/minhduy6868/MOB-Survey |
| Technical report | [docs/Mini-Project-1-Technical-Report.pdf](docs/Mini-Project-1-Technical-Report.pdf) |

PWA phỏng vấn hiện trường về thói quen giao dịch. Phiếu lưu local bằng Hive (IndexedDB trên web). Khi có mạng, client gửi `POST /api/sync` vào Cloudflare KV. Google Sheet đọc `GET /api/records`.

## Chạy local

Cần Flutter SDK.

```bash
cd app
flutter pub get
flutter run -d chrome
```

Máy local không chạy Functions. Muốn sync lên cloud:

```bash
flutter run -d chrome --dart-define=SYNC_URL=https://app.puretrovey.net/api/sync
```

## Cấu trúc

```
app/lib/             UI, Hive, hàng đợi sync
app/web/             manifest.json, sw.js, icon
functions/api/       /api/sync, /api/records
sheets/Code.gs       kéo dữ liệu KV vào Sheet
```

## Offline và cache

| Thành phần | Vị trí |
|---|---|
| Manifest `display: standalone` | `app/web/manifest.json` |
| Service Worker | `app/web/sw.js` (`trovey-shell-v9`) |
| Cache-First | shell, JS, icon |
| Network-First | `/survey-template.json` |
| Stale-While-Revalidate | `/sw-stats.json` |
| Cache-Only | `/offline` |
| Network-Only | `/api/*` |
| Hive | box `tickets-v3`, `settings`, `meta` |
| Background Sync | tag `trovey-sync` |

Chrome DevTools → Application: Manifest, Service Workers, Cache Storage, IndexedDB.

## Deploy

Không commit token.

```powershell
cd app
flutter build web --release --base-href /
cd ..
npx wrangler pages deploy app/build/web --project-name trovey
```

Chạy từ thư mục gốc để Wrangler biên dịch `functions/`.

## Google Sheet

1. Dán `sheets/Code.gs` vào Apps Script.
2. Chạy `beautifyAndSync`.
3. (Tuỳ chọn) `installTrigger`.

CSV: https://app.puretrovey.net/api/records?format=csv

## Android (ngoài phạm vi tuần 3)

```bash
cd app
flutter build apk --release --split-per-abi --dart-define=SYNC_URL=https://app.puretrovey.net/api/sync
```
