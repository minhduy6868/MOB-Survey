# Trovey — Week 3 PWA

**Môn:** Cross-Platform Mobile App Development (VKU)  
**Tuần:** 3 — Progressive Web Apps  
**Sản phẩm:** PWA offline-first phỏng vấn thói quen giao dịch trên thế giới

**Live:** https://app.puretrovey.net/  
**Repo:** https://github.com/minhduy6868/MOB-Survey

## Mục tiêu

Người đi hiện trường mở app trên điện thoại, cài ra màn hình chính, điền phiếu khi mất mạng, lưu nháp, rồi đồng bộ khi có mạng.

## Chủ đề (đã khóa)

| | |
|---|---|
| Tên | Trovey |
| Đối tượng | Một phiếu phỏng vấn người giao dịch |
| Câu hỏi | Nơi gặp, hồ sơ, thị trường, phong cách, giờ, sàn, cắt lỗ, nguồn tin, khó khăn |
| Ảnh / GPS | Tuỳ chọn |
| Người điều tra | Nguyễn Minh Duy · minhduyy.id.vn · 23IT038 |

## PWA phải có

- Web App Manifest, `display: standalone`, icon 192 + 512 (kể cả maskable)
- Service Worker: `install` → `activate` → `fetch`
- Đủ 5 chiến lược: cache-first, network-first, stale-while-revalidate, cache-only, network-only
- Hive / IndexedDB cho phiếu và cài đặt
- Hàng đợi gửi (`queued` → `synced` / `failed`) + Background Sync
- HTTPS

## Luồng phiếu

1. Hiện trường — quốc gia, thành phố, nơi gặp, GPS, ảnh  
2. Người được hỏi — họ tên (bắt buộc), SĐT, tuổi, số năm, thị trường, phong cách, giờ  
3. Thói quen — sàn, cắt lỗ, nguồn tin, khó khăn, kết quả 3 tháng  

Gửi → Hive → `POST /api/sync` → Cloudflare KV. Sheet kéo từ `GET /api/records`.

## Stack đã chọn

Flutter web · Hive · service worker viết tay · Cloudflare Pages + KV · Google Sheet (bản sao)

Không dùng Vite/React. Android APK là bản thêm, không thay PWA.

## Tiêu chí demo

1. Mở HTTPS trên Chrome → Cài → icon standalone  
2. Airplane mode → mở lại → form vẫn chạy  
3. Nháp còn sau khi tắt app  
4. Gửi offline → `queued` → bật mạng → `synced`  
5. DevTools: Manifest, SW, Cache Storage, IndexedDB  

## Ngoài phạm vi tuần 3

Đăng nhập, dashboard admin, Web Push, Capacitor (tuần sau).
