# Trovey

PWA điều tra hiện trường (Flutter web) về thói quen trading trên thế giới.  
Phiếu lưu offline trên máy (Hive), khi có mạng đồng bộ lên Cloudflare (`/api/sync`) rồi vào Google Sheet.

**Live:** https://app.puretrovey.net · https://trovey.pages.dev

## Chạy local

```bash
cd app
flutter pub get
flutter run -d chrome
```

Local không có `/api/sync` — phiếu sẽ `queued` / `failed` cho đến khi deploy, hoặc:

```bash
flutter run -d chrome --dart-define=SYNC_URL=https://trovey.pages.dev/api/sync
```

## Google Sheet

1. Tạo spreadsheet, Extensions → Apps Script, dán `sheets/Code.gs`.
2. Deploy → Web app → Execute as **Me** → Who has access: **Anyone**.
3. Gắn URL bằng secret (không commit vào git):

```bash
npx wrangler pages secret put SHEETS_WEBHOOK --project-name trovey
```

## Deploy Cloudflare Pages

Không commit token. Trong PowerShell:

```powershell
$env:CLOUDFLARE_API_TOKEN = "<token>"
cd app
flutter build web --release --base-href /
cd ..
npx wrangler pages deploy app/build/web --project-name trovey
```

Deploy từ thư mục gốc để Wrangler biên dịch `functions/`.

## PWA (Week 3)

`app/web/sw.js` — install → activate → fetch, đủ 5 chiến lược cache.  
Manifest standalone + icon 192/512. Hive = IndexedDB trên web.
