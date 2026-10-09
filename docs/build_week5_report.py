"""Build Mini-Project 2 Week 5 Capacitor technical report (A4, Arial)."""

from __future__ import annotations

from pathlib import Path

import pymupdf

ROOT = Path(__file__).resolve().parents[1]
OUT = ROOT / "docs" / "Mini-Project-2-Technical-Report.pdf"
EV = ROOT / "docs" / "evidence-w5"
FONT = Path(r"C:\Windows\Fonts\arial.ttf")
FONT_B = Path(r"C:\Windows\Fonts\arialbd.ttf")
FONT_I = Path(r"C:\Windows\Fonts\ariali.ttf")

W, H = 595.28, 841.89
ML, MR, MT, MB = 48, 48, 50, 48
FOOTER = "Mini-Project 2 Short Technical Report  |  Trovey  |  VKU"


def page_num(doc: pymupdf.Document) -> pymupdf.Page:
    page = doc.new_page(width=W, height=H)
    return page


def footer(page: pymupdf.Page, n: int, pages: int) -> None:
    page.insert_font(fontname="F", fontfile=str(FONT))
    page.insert_text((ML, H - 28), FOOTER, fontsize=8, fontname="F", fill=(0.25, 0.25, 0.25))
    page.insert_text((W - MR - 20, H - 28), str(n), fontsize=8, fontname="F", fill=(0.25, 0.25, 0.25))


def kv(page: pymupdf.Page, y: float, label: str, value: str) -> float:
    page.insert_font(fontname="B", fontfile=str(FONT_B))
    page.insert_font(fontname="F", fontfile=str(FONT))
    page.insert_text((ML, y), label, fontsize=10, fontname="B")
    page.insert_text((ML + 132, y), value, fontsize=10, fontname="F")
    return y + 16


def para(page: pymupdf.Page, y: float, text: str, *, bold: bool = False, size: float = 10, leading: float = 13) -> float:
    name = "B" if bold else "F"
    page.insert_font(fontname="F", fontfile=str(FONT))
    page.insert_font(fontname="B", fontfile=str(FONT_B))
    rect = pymupdf.Rect(ML, y - 2, W - MR, H - MB - 8)
    unused = page.insert_textbox(rect, text, fontsize=size, fontname=name, align=0)
    used = rect.height - unused
    return y + used + 6


def heading(page: pymupdf.Page, y: float, text: str) -> float:
    return para(page, y, text, bold=True, size=11, leading=14) + 4


def table(page: pymupdf.Page, y: float, rows: list[list[str]], col_w: list[float]) -> float:
    page.insert_font(fontname="F", fontfile=str(FONT))
    page.insert_font(fontname="B", fontfile=str(FONT_B))
    x0 = ML
    header_h = 22
    # header
    x = x0
    hrect = pymupdf.Rect(x0, y, x0 + sum(col_w), y + header_h)
    page.draw_rect(hrect, color=(0.55, 0.55, 0.55), fill=(0.93, 0.93, 0.93), width=0.4)
    for i, cell in enumerate(rows[0]):
        page.insert_textbox(
            pymupdf.Rect(x + 4, y + 4, x + col_w[i] - 4, y + header_h - 2),
            cell,
            fontsize=8,
            fontname="B",
        )
        x += col_w[i]
    y += header_h
    for r, row in enumerate(rows[1:]):
        # measure
        heights = []
        for i, cell in enumerate(row):
            chars = max(8, int((col_w[i] - 8) / 4.0))
            lines = max(1, (len(cell) + chars - 1) // chars)
            heights.append(max(36, 10 + lines * 11))
        rh = max(heights)
        if y + rh > H - MB - 10:
            break
        x = x0
        bg = (0.98, 0.98, 0.98) if r % 2 else (1, 1, 1)
        page.draw_rect(pymupdf.Rect(x0, y, x0 + sum(col_w), y + rh), color=(0.55, 0.55, 0.55), fill=bg, width=0.4)
        for i, cell in enumerate(row):
            page.insert_textbox(
                pymupdf.Rect(x + 4, y + 3, x + col_w[i] - 4, y + rh - 2),
                cell,
                fontsize=8,
                fontname="F",
            )
            x += col_w[i]
        y += rh
    return y + 10


def figure(page: pymupdf.Page, img: Path, box: pymupdf.Rect, caption: str) -> None:
    page.insert_font(fontname="I", fontfile=str(FONT_I))
    if img.exists():
        page.draw_rect(box, color=(0.75, 0.75, 0.75), width=0.4)
        page.insert_image(box, filename=str(img), keep_proportion=True)
    page.insert_textbox(
        pymupdf.Rect(box.x0, box.y1 + 4, box.x1, box.y1 + 36),
        caption,
        fontsize=8,
        fontname="I",
    )


def main() -> None:
    doc = pymupdf.open()
    tw = W - ML - MR

    # --- page 1 ---
    p = page_num(doc)
    p.insert_font(fontname="B", fontfile=str(FONT_B))
    p.insert_font(fontname="F", fontfile=str(FONT))
    y = MT
    y = para(p, y, "MINI-PROJECT SHORT TECHNICAL REPORT", bold=True, size=16) + 8
    y = kv(p, y, "Course:", "Cross-Platform Mobile App Development (VKU)")
    y = kv(p, y, "Mini-Project Title:", "Mini-Project 2 — Week 5 Capacitor (Trovey Native Shell)")
    y = kv(p, y, "Team / Student Name:", "Nguyễn Minh Duy")
    y = kv(p, y, "Submission Date:", "10/09/2026")
    y += 6
    y = heading(p, y, "1. GENERAL INFORMATION & DELIVERABLE LINKS")
    y = para(
        p,
        y,
        "Team Members:\n"
        "1. Nguyễn Minh Duy — Student ID: 23IT038 — Role: Solo (PWA HTML/JS, Capacitor Android, sync, deploy) — Contribution: 100%",
    )
    y = kv(p, y, "Live Demo URL:", "https://pwa.puretrovey.net/")
    y = kv(p, y, "Flutter PWA (branch):", "https://app.puretrovey.net/   git checkout mob-flutter")
    y = kv(p, y, "GitHub Repository:", "https://github.com/minhduy6868/MOB-Survey")
    y = kv(p, y, "Android APK:", "https://pwa.puretrovey.net/downloads/trovey.apk")
    y = kv(p, y, "Video Demo:", "Not submitted.")
    y += 4
    y = heading(p, y, "2. FEATURE IMPLEMENTATION CHECKLIST")
    rows = [
        ["#", "Required Feature", "Status", "Implementation Details & Acceptance Level"],
        ["1", "Capacitor + Android platform", "Complete", "npx cap add android. Project android/. capacitor.config.json webDir = pwa/. AppId net.puretrovey.trovey."],
        ["2", "Camera plugin replaces file input", "Complete", "pwa/native.js troveyTakePhoto: Camera.getPhoto({ resultType: base64, source: CAMERA }) when Capacitor.isNativePlatform(); else <input capture>."],
        ["3", "Geolocation plugin", "Complete", "troveyGetGps uses @capacitor/geolocation on native; navigator.geolocation on the browser PWA."],
        ["4", "Filesystem before sync", "Complete", "After camera, Filesystem.writeFile to DATA/photos/field-{ts}.jpg. New capability vs Week 3."],
        ["5", "Sync-success notification", "Complete", "Lab asked Push. Repo has no google-services.json / FCM. Local Notifications fire when status becomes synced. Same user goal, app need not stay in a browser tab."],
        ["6", "Build APK", "Complete", "npx cap sync && gradle assembleDebug. File pwa/downloads/trovey.apk. Trovey clipboard launcher + splash (not the default Capacitor mark)."],
        ["7", "Device test path", "Complete", "Permissions screen on first launch (Camera, GPS, Notifications, Files). Form still 3 steps. Queue draft|queued|syncing|synced|failed unchanged."],
        ["8", "Do not rewrite the app", "Complete", "Sync engine, dynamic form, IndexedDB (trovey-pwa / tickets) are the Week 3/HTML PWA. Capacitor only wraps them."],
    ]
    y = table(p, y, rows, [22, 128, 52, tw - 22 - 128 - 52])
    footer(p, 1, 3)

    # --- page 1 continued architecture if table ate space ---
    p2 = page_num(doc)
    y = MT
    y = heading(p2, y, "3. TECHNICAL ARCHITECTURE & PROJECT STRUCTURE")
    y = para(
        p2,
        y,
        "The web app (HTML/CSS/JS in pwa/) runs unchanged in the Android WebView. "
        "pwa/native.js is the Capacitor bridge: it calls Camera, Geolocation, Filesystem, and LocalNotifications "
        "only when Capacitor.isNativePlatform() is true. The browser PWA keeps file input, navigator.geolocation, and Notification.",
    )
    y = para(
        p2,
        y,
        "Directory map:\n"
        "pwa/                       Web app copied into the native shell (webDir)\n"
        "pwa/native.js               JS ↔ native plugins (camera, GPS, files, notify)\n"
        "pwa/app.js                  Form, IndexedDB queue, results charts, drain()\n"
        "android/                    Editable Android Studio project (Capacitor 7)\n"
        "android/.../AndroidManifest.xml  CAMERA, LOCATION, POST_NOTIFICATIONS\n"
        "functions/api/sync.js       POST /api/sync → Cloudflare KV (unchanged)\n"
        "functions/api/records.js    GET /api/records JSON/CSV (unchanged)\n"
        "capacitor.config.json       appId net.puretrovey.trovey, webDir pwa",
    )
    y = para(
        p2,
        y,
        "State flow: form edit → IndexedDB draft → Submit → status queued → POST https://app.puretrovey.net/api/sync → "
        "KV put ticket:{clientId} → status synced → Local Notification (native) or Web Notification (browser). "
        "clientId is a UUID, so retry does not create a second row. On online, pullCloud() merges remote rows, then drain() sends queued/failed.",
    )
    y = para(
        p2,
        y,
        "Exception handling: HTTP or body ok!=true / kv!=true throws. sendOne() sets failed + lastError. "
        "pullCloud() swallows network errors. A ticket is accepted when KV write succeeds. "
        "Sheet webhook 401 does not fail the ticket (same as Week 3).",
    )
    y = para(
        p2,
        y,
        "What the Week 5 slides said must not change: sync engine, dynamic form, IndexedDB. "
        "Those live in pwa/app.js + functions/api/. Week 5 changed the three hardware APIs plus a local photo write, and wrapped the PWA in Capacitor.",
    )
    y += 6
    y = heading(p2, y, "4. EMPIRICAL EVIDENCE & SCREENSHOTS")
    y = para(
        p2,
        y,
        "Screenshots from https://pwa.puretrovey.net/ on a 390×844 viewport (Chromium). Captured 10/09/2026. "
        "Four field interviews were filled on the same web form the APK embeds (three steps, skip GPS like a rushed site visit) and synced with kv:true:",
    )
    y = para(
        p2,
        y,
        "• Phạm Thị Hạnh — Đà Nẵng, quán, 25–34, cổ phiếu+forex, swing, VNDirect, stop-loss có, lãi nhẹ.\n"
        "• Trần Quốc Bảo — TP.HCM, văn phòng, 35–44, futures+chỉ số, day, DNSE, không stop, thua 3 tháng.\n"
        "• Lê Minh Châu — Huế, ký túc, 18–24, crypto, copy, Binance, stop-loss có, hòa vốn.\n"
        "• Nguyễn Hoàng Nam — Hà Nội, gọi từ xa, 25–34, forex+hàng hóa, position, MetaTrader 5, lãi rõ.",
    )
    gap = 12
    fw = (tw - gap) / 2
    fh = 268
    top = y + 4
    figure(p2, EV / "fig1-home.jpg", pymupdf.Rect(ML, top, ML + fw, top + fh), "Figure 1. Home: topic, start CTA, 6 submitted / 0 queued, install + APK.")
    figure(p2, EV / "fig-perms.jpg", pymupdf.Rect(ML + fw + gap, top, ML + fw + gap + fw, top + fh), "Figure 2. First-launch permissions (Camera, GPS, Notifications, Files) before any ticket.")
    footer(p2, 2, 3)

    p3 = page_num(doc)
    top = MT
    fh = 250
    figure(p3, EV / "fig2-form-site.jpg", pymupdf.Rect(ML, top, ML + fw, top + fh), "Figure 3. Form step 1 (site): Việt Nam, Đà Nẵng, quán — GPS skipped. Draft saved on device.")
    figure(p3, EV / "fig4-results-top.jpg", pymupdf.Rect(ML + fw + gap, top, ML + fw + gap + fw, top + fh), "Figure 4. Results overview: sample KPIs, market bars, style chart — not a flat list.")
    top = top + fh + 44
    figure(p3, EV / "fig5-settings-top.jpg", pymupdf.Rect(ML, top, ML + fw, top + fh), "Figure 5. Settings: collector 23IT038, shell label (PWA trình duyệt vs vỏ native), APK download.")
    icon_box = pymupdf.Rect(ML + fw + gap + 40, top + 20, ML + fw + gap + fw - 40, top + 20 + (fw - 80))
    figure(p3, EV / "fig-launcher.jpg", icon_box, "Figure 6. Android round launcher after branding (Trovey clipboard, not Capacitor default).")
    footer(p3, 3, 4)

    p4 = page_num(doc)
    y = MT
    y = heading(p4, y, "5. TECHNICAL CHALLENGES & RESOLUTIONS")
    y = para(p4, y, "5.1 Capacitor 7 needs JDK 21+", bold=True, size=10)
    y = para(
        p4,
        y,
        "assembleDebug with JDK 17 failed: invalid source release: 21 (capacitor.build.gradle compileOptions VERSION_21). "
        "Resolution: build with JDK 22 (JAVA_HOME). README states JDK 17 is not enough.",
    )
    y = para(p4, y, "5.2 APK launcher showed the Capacitor mark", bold=True, size=10)
    y = para(
        p4,
        y,
        "Legacy ic_launcher.png was Trovey, but Android 8+ adaptive icons use mipmap foreground + splash drawables that were still the default Capacitor logo. "
        "Resolution: logos/apply_android_brand.py rasterizes pwa/icons/Icon-512.png and Icon-maskable-512.png into all mipmap densities and splash sizes; ic_launcher_background = sampled teal.",
    )
    y = para(p4, y, "5.3 Push Notifications vs Local Notifications", bold=True, size=10)
    y = para(
        p4,
        y,
        "The slide asks @capacitor/push-notifications so the alert works without the browser staying open. "
        "FCM needs google-services.json, which is not in the repo. "
        "Resolution: @capacitor/local-notifications on native (and Web Notification on the PWA) when a ticket becomes synced. Same lab goal; no Firebase project.",
    )
    y = para(p4, y, "5.4 Cloudflare Pages 25 MiB file limit on the APK", bold=True, size=10)
    y = para(
        p4,
        y,
        "A debug APK that had already been copied into pwa/downloads/ was then packed again into android assets (webDir = pwa), so the next APK grew past 25 MiB and Pages rejected downloads/trovey.apk. "
        "Resolution: ignore *.apk in aapt; scripts/build-apk.cjs deletes the web APK before cap sync, then copies the new APK after assembleDebug. Upload is 17.5 MiB at https://pwa.puretrovey.net/downloads/trovey.apk.",
    )
    footer(p4, 4, 4)

    OUT.parent.mkdir(parents=True, exist_ok=True)
    doc.save(OUT)
    print(f"wrote {OUT}  {OUT.stat().st_size} bytes  pages={doc.page_count}")
    doc.close()


if __name__ == "__main__":
    main()
