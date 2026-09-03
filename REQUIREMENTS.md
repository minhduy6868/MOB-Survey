# VKU Field Survey — Product Requirements

**Course:** Cross-Platform Mobile App Development, Week 3 — Progressive Web Apps  
**Instructor:** Nguyen Thanh Tuan, PhD — Faculty of Computer Science, VKU  
**Product type:** Complete offline-first PWA (survey / field inspection)  
**Status:** Topic locked — worldwide trading field interviews (Trovey). Stack: Flutter web PWA, Hive offline, Cloudflare Pages sync, Google Sheets archive.

---

## 1. Goal

Build a **complete Progressive Web App** that a field worker can open on a phone, **install to the home screen**, fill a survey **with zero network**, save drafts locally, and **sync automatically** when the network returns.

The app must demonstrate the Week 3 stack in a real product, not a slide demo:

- Web App Manifest + standalone display
- Service Worker lifecycle (install → activate → fetch)
- The 5 caching strategies
- IndexedDB for structured offline data
- Offline draft persistence
- Background Sync / offline submit queue
- Live HTTPS deploy + public GitHub repo + short technical report

Next week (out of this spec): wrap the same PWA in an Android APK with Capacitor.

---

## 2. Topic (you choose later)

The **engine stays the same**. Only the survey schema, copy, and brand change.

### Default (lecture)

**VKU campus facility inspection** — staff walk buildings, record condition, photo, GPS, and severity.

### Topic plugin

Fill this block when you decide. Implementation must not hard-code “building / classroom” in the data layer.

| Field | Value |
|---|---|
| Domain | Trading practices worldwide |
| Survey object | One field interview with a trader |
| Primary questions | Site, profile, markets, style, hours, platform, stops, sources, challenge |
| Severity / score | Optional 3-month result band |
| Photo required? | Optional field photo |
| GPS required? | Optional, skip with reason |
| Brand name | Trovey |
| Audience | Field collectors interviewing traders |

### Ready-to-pick topics

1. **Campus facilities** (default) — lights, AC, toilets, accessibility
2. **Cafeteria / food hygiene** — stall, temperature, cleanliness
3. **Event feedback** — session rating after a workshop
4. **Library seat / noise** — study-space quality
5. **Green campus** — waste bins, trees, water leaks
6. **Dormitory maintenance** — room defects
7. **Lab equipment checkout** — device condition before/after class

Until you pick, all examples below use topic **1**.

---

## 3. Users

| Role | Device | Network | Job |
|---|---|---|---|
| **Field collector** | Phone, often one-handed | Often offline in basement / remote building | Fill, save draft, submit, retry |
| **Reviewer (same device or later dashboard)** | Phone or laptop | Online | See local history, filter by status, export |
| **Guest / first-time** | Phone browser | Online once to install | Add to home screen, grant camera/GPS if asked |

No login in v1. Collector identity is a **display name + optional student/staff ID** stored locally. Enough for the report; keeps the PWA demo focused on offline, not auth.

---

## 4. Product principles

1. **Offline is the happy path.** Opening the app with airplane mode on must still show the form and saved records.
2. **Never lose a draft.** Every field change persists to IndexedDB within 500ms.
3. **Submit is a queue, not a hope.** Offline submit → `queued`. Online → try sync → `synced` or `failed` with retry.
4. **Installable in under 30 seconds.** Manifest, icons 192/512, standalone, theme color.
5. **Mobile-first, thumb-reachable.** Primary actions at the bottom. Touch targets ≥ 44px.
6. **Honest status.** Always show Online / Offline, draft saved, queue count, last sync time.

---

## 5. Functional requirements

### 5.1 App shell & install

| ID | Requirement | Priority |
|---|---|---|
| FR-01 | App has a named shell: Home, New survey, History, Settings | Must |
| FR-02 | `manifest.webmanifest` with `name`, `short_name`, `start_url`, `display: standalone`, `theme_color`, `background_color`, icons 192 + 512 (any + maskable) | Must |
| FR-03 | Service Worker registered from the main entry; install pre-caches the app shell | Must |
| FR-04 | HTTPS production URL; install prompt / “Add to Home Screen” instructions on first visit | Must |
| FR-05 | Custom logo + favicon generated from the brand (logo-designer + web-asset-generator) | Must |

### 5.2 Survey form

| ID | Requirement | Priority |
|---|---|---|
| FR-10 | Start a new response in one tap from Home | Must |
| FR-11 | Question types: short text, long text, single choice, multiple choice, Likert 1–5, number, date/time, yes/no, photo, GPS | Must (at least 6 types used) |
| FR-12 | Required-field validation before submit; inline errors; do not wipe filled fields | Must |
| FR-13 | Auto-save draft on every change (IndexedDB) | Must |
| FR-14 | Resume an in-progress draft from History | Must |
| FR-15 | Discard draft with confirm | Must |
| FR-16 | Photo: camera or gallery, compress before store, show thumbnail | Must |
| FR-17 | GPS: capture lat/lng + accuracy + timestamp; allow skip with reason if permission denied | Must |
| FR-18 | Progress indicator (e.g. 4/10) and sticky Submit / Save draft | Must |
| FR-19 | Prevent double-submit | Must |

### 5.3 Offline queue & sync

| ID | Requirement | Priority |
|---|---|---|
| FR-20 | Submit while offline stores the record as `queued` and never shows a fatal error | Must |
| FR-21 | When online, drain the queue (Background Sync if supported, else `online` event + periodic retry) | Must |
| FR-22 | Each record has status: `draft` \| `queued` \| `syncing` \| `synced` \| `failed` | Must |
| FR-23 | Failed items show error + Retry | Must |
| FR-24 | Idempotent sync (stable `clientId` so a retry does not duplicate) | Must |
| FR-25 | Queue badge on the nav (count of `queued` + `failed`) | Should |
| FR-26 | Optional mock sync endpoint in-app if no backend yet (still exercises SW + queue) | Must for class demo |

### 5.4 History & review

| ID | Requirement | Priority |
|---|---|---|
| FR-30 | List all local responses, newest first | Must |
| FR-31 | Filter by status and by date | Must |
| FR-32 | Open a record read-only after submit; edit only drafts | Must |
| FR-33 | Delete a local record with confirm | Should |
| FR-34 | Export all records as JSON (and CSV if no photos-only fields) | Should |
| FR-35 | Empty state with a clear “Start first survey” action | Must |

### 5.5 Settings

| ID | Requirement | Priority |
|---|---|---|
| FR-40 | Collector display name + optional ID | Must |
| FR-41 | Language: Vietnamese + English | Should |
| FR-42 | Theme: light / dark / system | Should |
| FR-43 | Clear local data (destructive, typed confirm) | Should |
| FR-44 | Show SW version, cache version, last sync, storage estimate | Must (for the technical report) |

### 5.6 Notifications (lecture “Engaging”)

| ID | Requirement | Priority |
|---|---|---|
| FR-50 | After sync success, show an in-app toast | Must |
| FR-51 | Web Push + Badge API when queued items sync in background | Could (nice for lecture criterion 4) |

---

## 6. PWA / technical requirements (map to Week 3)

### 6.1 Five PWA criteria

| Criterion | How this app proves it |
|---|---|
| Installable | Manifest + icons + standalone; installable from Chrome Android |
| Offline-first | SW + Cache API + IndexedDB; form works in airplane mode |
| Fast & responsive | App shell cache-first; first paint from cache; mobile viewports 360–430px |
| Engaging | Install UX, status badge, toast; Push optional |
| Secure | HTTPS only (Vercel or Cloudflare Pages) |

### 6.2 Service Worker lifecycle

| Event | Behavior |
|---|---|
| `install` | Precache app shell: HTML, CSS, JS, fonts, icons, offline fallback page |
| `activate` | Delete old cache versions (`survey-shell-vN`) |
| `fetch` | Route by strategy below |

### 6.3 Caching strategies (must implement and document)

| Strategy | Used for |
|---|---|
| **Cache-First** | App shell: `/`, JS/CSS bundles, fonts, icons |
| **Network-First** | Live catalog of survey template / config JSON |
| **Stale-While-Revalidate** | Home stats, recent list metadata, optional CMS copy |
| **Cache-Only** | Offline fallback page, precached empty-state art |
| **Network-Only** | Sync POST, auth-like tokens if added later |

### 6.4 IndexedDB stores

| Store | Key | Value |
|---|---|---|
| `survey_templates` | `templateId` | Topic schema (questions, validation) — this is the topic plugin |
| `responses` | `clientId` (UUID) | Answers, photos (blobs), GPS, status, timestamps, sync attempts |
| `sync_queue` | `clientId` | Payload pointer + nextRetryAt + lastError |
| `settings` | `key` | collectorName, theme, locale |
| `meta` | `key` | schemaVersion, lastSyncAt, swVersion |

Schema versioning: bump `schemaVersion` and migrate; never drop unsynced responses.

### 6.5 Suggested stack (v1)

| Layer | Choice | Why |
|---|---|---|
| UI | Vite + React + TypeScript | Matches `react-best-practices` skill; easy Capacitor next week |
| Style | CSS variables + one distinctive theme (`frontend-design` + `using-ui-stack`) | Not a generic AI template |
| SW | `vite-plugin-pwa` (Workbox) **or** a hand-written SW | Hand-written is stronger for the report if you comment the 5 strategies |
| DB | IndexedDB via `idb` | Small, typed, async |
| Hosting | Vercel or Cloudflare Pages | Course deliverable |
| Sync target | Mock worker route `/api/sync` that stores in memory/KV **or** local “synced” flag if backend is out of scope | Must still show Network-Only + queue |

Keep the first version **frontend + SW + IndexedDB**. A real database can wait; the course grades offline behavior.

---

## 7. Information architecture

```
Home
  ├─ Network status + queue badge
  ├─ CTA: New survey
  ├─ Last draft card (if any)
  └─ Recent 3 responses
New / Edit survey
  ├─ Sectioned questions
  ├─ Photo + GPS blocks
  └─ Save draft | Submit
History
  ├─ Filters
  └─ Record detail
Settings
  ├─ Profile
  ├─ Theme / language
  └─ Diagnostics (SW, cache, storage)
Offline fallback
  └─ Shown only if a navigation miss is not in cache
```

---

## 8. Non-functional requirements

| ID | Requirement |
|---|---|
| NFR-01 | Usable at 360px width; no horizontal scroll on form |
| NFR-02 | Contrast ≥ 4.5:1; visible focus; `prefers-reduced-motion` |
| NFR-03 | Cold start from cache feels instant; no blank white flash |
| NFR-04 | Photo stored ≤ ~400KB after compress |
| NFR-05 | 200+ local records must still list smoothly (virtualize if needed) |
| NFR-06 | No secrets in the repo; no analytics that break offline |
| NFR-07 | Vietnamese UI by default; English toggle |
| NFR-08 | Code and README in a public GitHub repo; one-command local run |

---

## 9. Acceptance criteria (demo script)

These are the checks for “complete”, aligned with the lecture.

1. Open the HTTPS URL on Android Chrome → **Install** → icon on home screen → opens **standalone** (no browser chrome).
2. Turn on **airplane mode** → kill the app → reopen → Home and New survey still work.
3. Fill a form, leave mid-way, kill the app → draft is still there.
4. Submit while offline → status `queued`, toast “Sẽ gửi khi có mạng”.
5. Turn network on → queue drains → status `synced` (or mock-synced) without a second tap.
6. DevTools → Application: Manifest valid; SW activated; Cache Storage has shell; IndexedDB has `responses`.
7. Lighthouse PWA category is installable (or document why a lab HTTP origin fails install).
8. README has install, run, deploy, and a short “how offline works” section.
9. Technical report (2–4 pages) explains lifecycle, the 5 strategies with this app’s URL map, and IndexedDB schema.

---

## 10. Course deliverables

| # | Deliverable | Notes |
|---|---|---|
| i | Live HTTPS link | Cloudflare Pages or Vercel |
| ii | Public GitHub repo | Clean code + README setup |
| iii | Technical report PDF, 2–4 pages | SW, cache map, IndexedDB, screenshots of offline demo |
| Later | Capacitor Android APK | Week 4 — do not block v1 on this |

---

## 11. Out of scope (v1)

- Real user accounts / OAuth
- Multi-user admin dashboard in the cloud
- Push notifications if time is short (FR-51)
- Native BLE / NFC
- iOS install polish beyond standard A2HS
- Capacitor / Play Store (next week)

---

## 12. Implementation order

1. You pick the topic (section 2).
2. Brand + logo (`logo-designer`) → PWA icons (`web-asset-generator`).
3. Vite React shell + manifest + SW with Cache-First app shell.
4. IndexedDB + draft auto-save + history.
5. Form UI (`frontend-design`, `using-ui-stack`) + validation (`form-testing`).
6. Offline queue + Network-Only sync + remaining cache strategies.
7. Deploy HTTPS, verify in browser (`verifying-in-browser`), write report.

---

## 13. Open decisions (reply with your picks)

1. **Topic** — number 1–7 or your own domain.
2. **Brand name** — or I propose 3 names after the topic.
3. **Service Worker** — hand-written (better for the report) vs Workbox (faster).
4. **Sync backend** — mock `/api/sync` on the same host vs local-only “fake sync”.
5. **Language default** — vi or en.
