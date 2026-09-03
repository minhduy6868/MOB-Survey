# Trovey

PWA phỏng vấn hiện trường về thói quen giao dịch trên thế giới.  
Offline-first: phiếu lưu trên máy (Hive / IndexedDB), có mạng thì ghi vào Cloudflare KV.

**Live:** https://app.puretrovey.net/  
**GitHub:** https://github.com/minhduy6868/MOB-Survey

Người điều tra: Nguyễn Minh Duy · [minhduyy.id.vn](https://minhduyy.id.vn) · 23IT038

## Tính năng

- Cài ra màn hình chính (`standalone`)
- Điền phiếu khi mất mạng, gửi lại khi có mạng
- Service Worker đủ 5 chiến lược cache
- Đồng bộ Cloudflare KV, Sheet chỉ là bản sao
- Tiếng Việt / English, sáng / tối

## Stack

| Lớp | Công cụ |
|---|---|
| UI | Flutter web |
| Offline | Hive (IndexedDB trên web) |
| PWA | `app/web/manifest.json` + `sw.js` viết tay |
| Host | Cloudflare Pages |
| Database | Cloudflare KV `TROVEY_RECORDS` |
| Bản sao | Google Sheet kéo từ `/api/records` |

## Cấu trúc

```
app/                 Flutter PWA + Android (tuỳ chọn)
  lib/               Màn hình, form, Hive, sync
  web/               Manifest, service worker, icon
functions/           Cloudflare Pages Functions
  api/sync           Ghi phiếu vào KV
  api/records        JSON / CSV
sheets/Code.gs       Apps Script làm đẹp Sheet
```

## Chạy local

Cần [Flutter](https://docs.flutter.dev/get-started/install) ổn định.

```bash
cd app
flutter pub get
flutter run -d chrome
```

Local không có API. Để phiếu lên cloud khi chạy máy:

```bash
flutter run -d chrome --dart-define=SYNC_URL=https://app.puretrovey.net/api/sync
```

## PWA (Week 3)

| Tiêu chí | File |
|---|---|
| Manifest standalone | `app/web/manifest.json` |
| Icon 192 / 512 + maskable | `app/web/icons/` |
| SW install → activate → fetch | `app/web/sw.js` |
| 5 chiến lược cache | cache-first, network-first, SWR, cache-only, network-only |
| Offline data | Hive box `tickets-v3` |
| Background Sync | tag `trovey-sync` trong `sw.js` + `install.js` |

Chrome → DevTools → Application: Manifest + Service Workers (`trovey-shell-v9`).

## Deploy

Không commit token. Trong PowerShell:

```powershell
cd app
flutter build web --release --base-href /
cd ..
npx wrangler pages deploy app/build/web --project-name trovey
```

Chạy lệnh deploy từ thư mục gốc để Wrangler biên dịch `functions/`.

## Google Sheet (bản sao)

Dữ liệu gốc ở Cloudflare, không ở Sheet.

1. Dán `sheets/Code.gs` vào Extensions → Apps Script.
2. Chạy `beautifyAndSync` một lần (cho phép quyền).
3. Chạy `installTrigger` nếu muốn Sheet tự cập nhật.

CSV: https://app.puretrovey.net/api/records?format=csv

## Android (thêm, không thay PWA)

```bash
cd app
flutter build apk --release --split-per-abi --dart-define=SYNC_URL=https://app.puretrovey.net/api/sync
```
