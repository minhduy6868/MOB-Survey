# Trovey — Week 3 PWA + Week 5 Capacitor

**Môn:** Cross-Platform Mobile App Development (VKU)  
**Sinh viên:** Nguyễn Minh Duy · 23IT038

**Live:** https://app.puretrovey.net/  
**Fallback:** https://trovey.pages.dev/  
**Repo:** https://github.com/minhduy6868/MOB-Survey

## Week 3 — PWA (đã khóa)

Phiếu phỏng vấn thói quen giao dịch. Offline Hive, sync Cloudflare KV.

- Manifest standalone, icon 192/512
- SW install → activate → fetch, đủ 5 chiến lược cache
- Hàng đợi `draft | queued | syncing | synced | failed`

## Week 5 — Capacitor

Không viết lại app. Bọc `app/build/web` trong Android WebView.

1. `npx cap add android` — project `android/`
2. Camera plugin thay file / `image_picker` khi chạy native
3. Geolocation plugin thay `navigator.geolocation` khi chạy native
4. Filesystem ghi ảnh vào máy trước sync
5. Local Notifications khi phiếu `synced` (thay Web Push; FCM không có trong repo)
6. `flutter build web && npx cap sync &&` APK debug

Động cơ sync, form, Hive giữ nguyên.

## Demo trên máy Android

1. Cài `app-debug.apk`
2. Airplane mode → điền phiếu, chụp ảnh, lấy GPS
3. Gửi → `queued`
4. Bật mạng → `synced` + thông báo
5. Settings hiện "Vỏ native (Capacitor)"
