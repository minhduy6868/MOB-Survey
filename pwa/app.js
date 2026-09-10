const DB_NAME = 'trovey-pwa';
const STORE = 'tickets';
let db;
let records = [];
let settings = { locale: 'vi', theme: 'paper' };
let online = navigator.onLine;
let view = 'home';
let form = null;
let formStep = 0;
let deferredInstall = null;
let permState = { camera: 'prompt', geo: 'prompt', notify: 'prompt', files: 'granted' };
let permBusy = '';
let showIosSteps = false;
let listFilter = 'all';
const APK_URL = '/downloads/trovey.apk';
const splashAt = Date.now();
const PERM_ITEMS = [
  { id: 'camera', title: 'Camera', why: 'Chụp ảnh hiện trường gắn vào phiếu.' },
  { id: 'geo', title: 'Vị trí', why: 'Gắn tọa độ nơi gặp người được hỏi.' },
  { id: 'notify', title: 'Thông báo', why: 'Báo khi phiếu gửi xong, kể cả vừa có mạng lại.' },
  { id: 'files', title: 'Lưu ảnh', why: 'Ghi ảnh vào bộ nhớ máy trước khi gửi lên máy chủ.' },
];

function permLabel(state) {
  if (state === 'granted' || state === 'limited') return 'Đã cấp';
  if (state === 'denied') return 'Bị từ chối';
  return 'Chưa hỏi';
}

function permTone(state) {
  if (state === 'granted' || state === 'limited') return 'ok';
  if (state === 'denied') return 'no';
  return 'wait';
}

function needsPermScreen() {
  return localStorage.getItem('trovey-perm-seen') !== '1';
}

function finishPermScreen() {
  localStorage.setItem('trovey-perm-seen', '1');
  localStorage.setItem('trovey-perm-asked', '1');
  view = 'home';
  render();
}

async function refreshPerms() {
  if (window.troveyPermissionState) {
    permState = await window.troveyPermissionState();
  }
}

async function askOne(kind) {
  if (permBusy) return;
  permBusy = kind;
  const btn = document.querySelector(`[data-perm="${kind}"]`);
  if (btn) {
    btn.disabled = true;
    btn.textContent = 'Đang hỏi';
  }
  try {
    if (window.troveyRequestOne) {
      permState = await window.troveyRequestOne(kind);
    }
  } finally {
    permBusy = '';
    render();
  }
}

async function askPerms(refreshUi) {
  if (permBusy) return;
  permBusy = 'all';
  const allBtn = document.getElementById('ask') || document.getElementById('ask-all');
  if (allBtn) {
    allBtn.disabled = true;
    allBtn.textContent = 'Đang hỏi';
  }
  document.querySelectorAll('[data-perm]').forEach((btn) => { btn.disabled = true; });
  try {
    if (window.troveyRequestPermissions) {
      permState = await window.troveyRequestPermissions();
    }
    localStorage.setItem('trovey-perm-asked', '1');
  } finally {
    permBusy = '';
    if (refreshUi !== false) render();
  }
}

function permRows(withActions) {
  return PERM_ITEMS.map((item) => {
    const state = permState[item.id] || 'prompt';
    const busy = permBusy === item.id || permBusy === 'all';
    return `
      <li class="perm-row">
        <div>
          <strong>${item.title}</strong>
          <p>${item.why}</p>
        </div>
        <div class="perm-side">
          <em class="${permTone(state)}">${permLabel(state)}</em>
          ${withActions ? `<button class="ghost" type="button" data-perm="${item.id}" ${busy ? 'disabled' : ''}>${busy && permBusy === item.id ? 'Đang hỏi' : 'Cho phép'}</button>` : ''}
        </div>
      </li>`;
  }).join('');
}

function installCard() {
  if (window.troveyIsStandalone && window.troveyIsStandalone()) {
    return `<div class="panel card-pad"><p class="hint">Đã cài. Đang mở như ứng dụng.</p></div>`;
  }
  const ios = window.troveyIsIos && window.troveyIsIos();
  return `
    <div class="panel card-pad">
      <p class="eyebrow">Cài ra máy</p>
      <p class="hint" style="margin-bottom:16px">${ios ? 'Trên iPhone: Share, rồi Thêm vào Màn hình chính.' : 'Cài ra màn hình chính, hoặc tải file Android.'}</p>
      <button class="btn" id="install" type="button">${ios ? 'Cách thêm trên iPhone' : 'Cài ra màn hình chính'}</button>
      ${ios ? '' : `<a class="apk" id="apk" href="${APK_URL}" download="trovey.apk">Tải file cài Android</a>`}
      ${ios && showIosSteps ? '<p class="hint" style="margin-top:16px">1. Mở trang này bằng Safari<br />2. Chạm nút Chia sẻ<br />3. Thêm vào Màn hình chính<br />4. Đặt tên Trovey, chạm Thêm</p>' : ''}
    </div>`;
}

function permCard() {
  return `
    <div class="panel card-pad">
      <p class="eyebrow">Quyền hiện trường</p>
      <p class="hint">Bốn quyền theo bài Capacitor: camera, vị trí, thông báo, lưu ảnh. Hệ thống chỉ hỏi sau khi bạn chạm Cho phép.</p>
      <ul class="perm-list">${permRows(true)}</ul>
      <button class="btn" id="ask" type="button" style="margin-top:8px" ${permBusy ? 'disabled' : ''}>${permBusy === 'all' ? 'Đang hỏi' : 'Cho phép tất cả'}</button>
      <button class="ghost" id="open-perms" type="button" style="margin-top:8px">Mở form quyền</button>
    </div>`;
}

function renderPerms() {
  document.getElementById('app').innerHTML = `
    <header class="dawn slim">
      <i class="dawn-orb" aria-hidden="true"></i>
      <div class="dawn-bar">
        <img class="mark" src="icons/icon.svg" alt="" />
        <h1 class="wordmark">Quyền hiện trường</h1>
      </div>
    </header>
    <main class="lift">
      <article class="ticket">
        <i class="sun" aria-hidden="true"></i>
        <p class="eyebrow">Trước khi làm phiếu</p>
        <h2>Cho phép từng quyền</h2>
        <p class="lead">Trovey cần camera, GPS, thông báo và chỗ lưu ảnh. Chạm Cho phép từng dòng. Máy sẽ hiện hộp thoại hệ thống ngay sau đó.</p>
        <ul class="perm-list">${permRows(true)}</ul>
      </article>
    </main>
    <div class="form-actions">
      <button class="ghost" id="ask-all" type="button" ${permBusy ? 'disabled' : ''}>${permBusy === 'all' ? 'Đang hỏi' : 'Cho phép tất cả'}</button>
      <button class="btn" id="skip-perm" type="button">Vào phiếu</button>
    </div>
  `;
}

function openDb() {
  return new Promise((resolve, reject) => {
    const req = indexedDB.open(DB_NAME, 1);
    req.onupgradeneeded = () => req.result.createObjectStore(STORE, { keyPath: 'clientId' });
    req.onsuccess = () => resolve(req.result);
    req.onerror = () => reject(req.error);
  });
}

function tx(mode) {
  return db.transaction(STORE, mode).objectStore(STORE);
}

async function loadAll() {
  records = await new Promise((resolve) => {
    const req = tx('readonly').getAll();
    req.onsuccess = () => {
      const rows = req.result || [];
      rows.sort((a, b) => String(b.updatedAt).localeCompare(String(a.updatedAt)));
      resolve(rows);
    };
  });
}

async function put(row) {
  await new Promise((resolve, reject) => {
    const req = tx('readwrite').put(row);
    req.onsuccess = () => resolve();
    req.onerror = () => reject(req.error);
  });
  await loadAll();
}

function queueCount() {
  return records.filter((r) => r.status === 'queued' || r.status === 'failed').length;
}

function submittedCount() {
  return records.filter((r) => r.status !== 'draft').length;
}

async function newDraft() {
  const now = new Date().toISOString();
  form = {
    clientId: crypto.randomUUID(),
    status: 'draft',
    answers: { ...emptyAnswers(), siteCountry: 'Việt Nam' },
    photoB64: '',
    createdAt: now,
    updatedAt: now,
    submittedAt: null,
  };
  formStep = 0;
  await put(form);
  view = 'form';
  render();
}

async function saveForm() {
  form.updatedAt = new Date().toISOString();
  await put(form);
}

function flatten(answers) {
  const out = {};
  Object.keys(answers).forEach((key) => {
    const value = answers[key];
    if (value && typeof value === 'object' && value.lat != null) {
      out.lat = String(value.lat);
      out.lng = String(value.lng);
      out.gpsAccuracy = String(value.accuracy || '');
    } else if (Array.isArray(value)) {
      out[key] = value.join('|');
    } else {
      out[key] = value == null ? '' : String(value);
    }
  });
  return out;
}

async function sendOne(row) {
  row.status = 'syncing';
  await put(row);
  const body = {
    clientId: row.clientId,
    surveyId: SURVEY_ID,
    collectorName: COLLECTOR.fullName,
    collectorId: COLLECTOR.id,
    locale: settings.locale,
    createdAt: row.createdAt,
    submittedAt: row.submittedAt || new Date().toISOString(),
    hasPhoto: Boolean(row.photoB64),
    ...flatten(row.answers),
  };
  const res = await fetch(`${API}/api/sync`, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify(body),
  });
  const decoded = await res.json().catch(() => ({}));
  if (!res.ok || decoded.ok !== true || decoded.kv !== true) {
    throw new Error(decoded.error || `HTTP ${res.status}`);
  }
  row.status = 'synced';
  row.syncedAt = new Date().toISOString();
  row.lastError = '';
  await put(row);
  if (window.troveyNotifySync) window.troveyNotifySync('Đã gửi phiếu', 'Phiếu đã vào Cloudflare.');
}

async function drain() {
  if (!online) return;
  const pending = records.filter((r) => r.status === 'queued' || r.status === 'failed');
  for (const row of pending) {
    try {
      await sendOne(row);
    } catch (err) {
      row.status = 'failed';
      row.lastError = String(err);
      await put(row);
    }
  }
  await pullCloud();
  render();
}

async function pullCloud() {
  if (!online) return;
  try {
    const res = await fetch(`${API}/api/records`);
    const decoded = await res.json();
    if (!decoded.ok || !Array.isArray(decoded.records)) return;
    for (const remote of decoded.records) {
      const id = String(remote.clientId || '');
      if (!id) continue;
      const existing = records.find((r) => r.clientId === id);
      if (existing && ['draft', 'queued', 'syncing', 'failed'].includes(existing.status)) continue;
      await put({
        clientId: id,
        status: 'synced',
        answers: { ...emptyAnswers(), ...pickAnswers(remote) },
        photoB64: '',
        createdAt: remote.createdAt || remote.storedAt || new Date().toISOString(),
        updatedAt: remote.storedAt || remote.submittedAt || new Date().toISOString(),
        submittedAt: remote.submittedAt || null,
      });
    }
  } catch (_) {
    /* keep local */
  }
}

function pickAnswers(remote) {
  const answers = emptyAnswers();
  Object.keys(answers).forEach((key) => {
    if (remote[key] == null) return;
    if (key === 'markets' || key === 'informationSources') {
      answers[key] = Array.isArray(remote[key])
        ? remote[key]
        : String(remote[key]).split('|').filter(Boolean);
    } else {
      answers[key] = remote[key];
    }
  });
  return answers;
}

function placeLabel(value) {
  const hit = PLACES.find((p) => p[0] === value);
  return hit ? hit[1] : value;
}

function statusShort(status) {
  return {
    draft: 'Nháp',
    queued: 'Chờ gửi',
    syncing: 'Đang gửi',
    synced: 'Đã gửi',
    failed: 'Lỗi gửi',
  }[status] || status;
}

function statusLabel(status) {
  return {
    draft: 'Nháp',
    queued: 'Sẽ gửi khi có mạng',
    syncing: 'Đang gửi',
    synced: 'Đã gửi',
    failed: 'Chưa gửi được. Thử lại.',
  }[status] || status;
}

function optLabel(pairs, value) {
  if (value == null || value === '') return '—';
  const hit = pairs.find((row) => row[0] === value);
  return hit ? hit[1] : String(value);
}

function optLabels(pairs, values) {
  if (!Array.isArray(values) || !values.length) return '—';
  return values.map((value) => optLabel(pairs, value)).join(', ');
}

function countBy(rows, pick) {
  const map = new Map();
  rows.forEach((row) => {
    const raw = pick(row);
    const keys = Array.isArray(raw) ? raw : [raw];
    keys.forEach((key) => {
      if (key == null || key === '') return;
      map.set(key, (map.get(key) || 0) + 1);
    });
  });
  return [...map.entries()].sort((a, b) => b[1] - a[1]);
}

function avgHours(rows) {
  const nums = rows
    .map((row) => parseFloat(row.answers.hoursPerWeek))
    .filter((n) => Number.isFinite(n) && n >= 0);
  if (!nums.length) return '—';
  return (nums.reduce((a, b) => a + b, 0) / nums.length).toFixed(1);
}

function barChart(title, rows, labelOf) {
  if (!rows.length) {
    return `<section class="panel card-pad chart"><p class="eyebrow">${title}</p><p class="empty-inline">Chưa đủ dữ liệu để vẽ.</p></section>`;
  }
  const top = Math.max(...rows.map((row) => row[1]), 1);
  return `
    <section class="panel card-pad chart">
      <p class="eyebrow">${title}</p>
      <ul class="bars">
        ${rows.map(([key, count], index) => `
          <li>
            <div class="bar-meta">
              <span>${esc(labelOf ? labelOf(key) : key)}</span>
              <strong>${count}</strong>
            </div>
            <div class="bar-track" aria-hidden="true">
              <i class="${index === 0 ? 'hot' : ''}" style="width:${Math.max(8, Math.round((count / top) * 100))}%"></i>
            </div>
          </li>`).join('')}
      </ul>
    </section>`;
}

function donutChart(yes, no) {
  const total = yes + no;
  const r = 38;
  const c = 2 * Math.PI * r;
  const yesLen = total ? (yes / total) * c : 0;
  return `
    <section class="panel card-pad chart">
      <p class="eyebrow">Stop-loss gần như mọi lệnh</p>
      <div class="donut-wrap">
        <svg viewBox="0 0 100 100" class="donut" role="img" aria-label="Có ${yes}, không ${no}">
          <circle cx="50" cy="50" r="${r}" class="donut-bg"></circle>
          <circle cx="50" cy="50" r="${r}" class="donut-yes"
            stroke-dasharray="${yesLen} ${c}"
            transform="rotate(-90 50 50)"></circle>
          <text x="50" y="48" text-anchor="middle">${total ? Math.round((yes / total) * 100) : 0}%</text>
          <text x="50" y="64" text-anchor="middle" class="donut-sub">có dùng</text>
        </svg>
        <ul class="legend">
          <li><i class="swatch yes"></i>Có · ${yes}</li>
          <li><i class="swatch no"></i>Không · ${no}</li>
        </ul>
      </div>
    </section>`;
}

function el(html) {
  const box = document.createElement('div');
  box.innerHTML = html.trim();
  return box.firstElementChild;
}

function header(title, back) {
  return `
    <header class="dawn slim">
      <i class="dawn-orb" aria-hidden="true"></i>
      <div class="dawn-bar">
        ${back ? `<button class="back" id="back" type="button" aria-label="Về">‹</button>` : `<img class="mark" src="icons/icon.svg" alt="" />`}
        <h1 class="wordmark">${title}</h1>
        <span class="live"><i class="dot ${online ? '' : 'off'}"></i>${online ? 'Có mạng' : 'Mất mạng'}</span>
      </div>
    </header>`;
}

function navIcon(name) {
  if (name === 'home') return '<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8"><path d="M4 10.5 12 4l8 6.5V20a1 1 0 0 1-1 1h-5v-6H10v6H5a1 1 0 0 1-1-1z"/></svg>';
  if (name === 'results') return '<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8"><path d="M4 20V10M10 20V4M16 20v-7M22 20H3"/></svg>';
  return '<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8"><circle cx="12" cy="12" r="3"/><path d="M12 4v2M12 18v2M4 12h2M18 12h2M6.2 6.2l1.4 1.4M16.4 16.4l1.4 1.4M6.2 17.8l1.4-1.4M16.4 7.6l1.4-1.4"/></svg>';
}

function nav(active) {
  return `
    <nav class="nav">
      <button type="button" data-go="home" class="${active === 'home' ? 'on' : ''}">${navIcon('home')}Trang chủ</button>
      <button type="button" data-go="results" class="${active === 'results' ? 'on' : ''}">${navIcon('results')}Kết quả</button>
      <button type="button" data-go="settings" class="${active === 'settings' ? 'on' : ''}">${navIcon('settings')}Cài đặt</button>
    </nav>`;
}

function chips(name, options, multi) {
  const selected = multi ? form.answers[name] : form.answers[name];
  return `<div class="choices">${options
    .map(([value, label]) => {
      const on = multi ? selected.includes(value) : selected === value;
      return `<button type="button" class="choice ${on ? 'on' : ''}" data-chip="${name}" data-value="${value}" data-multi="${multi ? '1' : '0'}">${label}</button>`;
    })
    .join('')}</div>`;
}

function stepErrors() {
  return requiredOf(formStep).filter((key) => !isFilled(form.answers, key));
}

function renderHome() {
  const draft = records.find((r) => r.status === 'draft');
  const recent = records.slice(0, 5);
  document.getElementById('app').innerHTML = `
    <header class="dawn">
      <i class="dawn-orb" aria-hidden="true"></i>
      <div class="dawn-bar">
        <div class="dawn-brand">
          <img class="mark" src="icons/icon.svg" alt="" />
          <p class="wordmark">Trovey</p>
        </div>
        <span class="live"><i class="dot ${online ? '' : 'off'}"></i>${online ? 'Có mạng' : 'Mất mạng'}</span>
      </div>
    </header>
    <main class="lift">
      <article class="ticket">
        <i class="sun" aria-hidden="true"></i>
        <p class="eyebrow">Phiếu hiện trường</p>
        <h2>Thói quen giao dịch trên thế giới</h2>
        <p class="lead">Gặp người. Hỏi. Ghi phiếu. Ba bước trên điện thoại, gửi khi có mạng.</p>
        <div class="stamps">
          <span class="stamp">Hiện trường</span>
          <span class="stamp">Người được hỏi</span>
          <span class="stamp">Thói quen</span>
        </div>
        <div class="cut" aria-hidden="true"></div>
        <p class="who">
          <strong>${COLLECTOR.name}</strong>
          <a href="${COLLECTOR.url}" target="_blank" rel="noopener">${COLLECTOR.site}</a>
          <span class="mssv">${COLLECTOR.id}</span>
        </p>
        <button class="btn" id="start" type="button">Bắt đầu phỏng vấn</button>
      </article>
      <div class="panel stats" style="margin-top:16px">
        <div><strong>${submittedCount()}</strong><span>đã gửi</span></div>
        <div class="split"></div>
        <div><strong>${queueCount()}</strong><span>chờ gửi</span></div>
      </div>
      <p class="section">Cài đặt máy</p>
      ${installCard()}
      ${draft ? `<p class="section">Nháp</p><div class="panel card-pad"><button class="btn" id="resume" type="button">Tiếp tục nháp</button></div>` : ''}
      <p class="section">Phiếu gần đây</p>
      <div class="panel list">
        ${recent.length ? recent.map((r) => `
          <button type="button" data-open="${r.clientId}">
            <span><strong>${esc(r.answers.respondentName || 'Chưa tên')}</strong><span class="muted">${esc(r.answers.siteCountry || '')} · ${statusLabel(r.status)}</span></span>
            <span class="chev">›</span>
          </button>`).join('') : '<p class="empty">Chưa có phiếu. Bắt đầu phỏng vấn đầu tiên.</p>'}
      </div>
    </main>
    ${nav('home')}
  `;
}

function renderForm() {
  const titles = ['Hiện trường', 'Người được hỏi', 'Thói quen'];
  const errors = stepErrors();
  let body = '';
  if (formStep === 0) {
    body = `
      <div class="block"><label>Quốc gia phỏng vấn *</label>
      <select class="field" data-field="siteCountry">${COUNTRIES.map((c) => `<option value="${c}" ${form.answers.siteCountry === c ? 'selected' : ''}>${c}</option>`).join('')}</select></div>
      <div class="block"><label>Thành phố / vùng</label>
      <input class="field" data-field="siteCity" value="${esc(form.answers.siteCity)}" /></div>
      <div class="block"><label>Nơi gặp *</label>${chips('interviewPlace', PLACES, false)}</div>
      <div class="block"><label>Tọa độ hiện trường</label>
      ${form.answers.gps ? `<p class="hint" style="margin-bottom:8px">${form.answers.gps.lat}, ${form.answers.gps.lng}</p>` : ''}
      <div class="row">
        <button class="ghost" id="gps" type="button">Lấy tọa độ</button>
        <button class="ghost" id="skip-gps" type="button">Bỏ qua vị trí</button>
      </div></div>
      <div class="block"><label>Ảnh hiện trường</label>
      ${form.photoB64 ? `<img class="thumb" alt="" src="data:image/jpeg;base64,${form.photoB64}" />` : ''}
      <div class="row">
        <button class="ghost" id="photo" type="button">Chụp / chọn ảnh</button>
        <input id="file" type="file" accept="image/*" capture="environment" hidden />
      </div></div>
    `;
  } else if (formStep === 1) {
    body = `
      <div class="block"><label>Tên người được hỏi *</label>
      <input class="field" data-field="respondentName" value="${esc(form.answers.respondentName)}" /></div>
      <div class="block"><label>Số điện thoại</label>
      <input class="field" data-field="respondentPhone" type="tel" value="${esc(form.answers.respondentPhone)}" /></div>
      <div class="block"><label>Độ tuổi *</label>${chips('ageRange', AGES, false)}</div>
      <div class="block"><label>Số năm giao dịch *</label>${chips('yearsTrading', YEARS, false)}</div>
      <div class="block"><label>Thị trường đang chơi *</label>${chips('markets', MARKETS, true)}</div>
      <div class="block"><label>Phong cách chính *</label>${chips('style', STYLES, false)}</div>
      <div class="block"><label>Giờ/tuần dành cho thị trường *</label>
      <input class="field" data-field="hoursPerWeek" inputmode="decimal" value="${esc(form.answers.hoursPerWeek)}" /></div>
    `;
  } else {
    body = `
      <div class="block"><label>Sàn / app chính *</label>
      <input class="field" data-field="platform" value="${esc(form.answers.platform)}" /></div>
      <div class="block"><label>Có dùng stop-loss gần như mọi lệnh? *</label>${chips('usesStop', [['yes', 'Có'], ['no', 'Không']], false)}</div>
      <div class="block"><label>Nguồn thông tin *</label>${chips('informationSources', SOURCES, true)}</div>
      <div class="block"><label>Khó khăn lớn nhất khi trade *</label>
      <textarea class="field" data-field="biggestChallenge">${esc(form.answers.biggestChallenge)}</textarea></div>
      <div class="block"><label>Kết quả 3 tháng gần nhất</label>${chips('resultBand', RESULTS, false)}</div>
      <div class="block"><label>Ghi chú người điều tra</label>
      <textarea class="field" data-field="notes">${esc(form.answers.notes)}</textarea></div>
    `;
  }
  document.getElementById('app').innerHTML = `
    ${header('Phỏng vấn mới', true)}
    <main>
      <div class="stepper">
        <div class="stepper-top">
          ${titles.map((_, i) => `
            <span class="step-dot ${i === formStep ? 'on' : i < formStep ? 'done' : ''}">${i + 1}</span>
            ${i < 2 ? '<span class="step-line"></span>' : ''}
          `).join('')}
        </div>
        <h2>${titles[formStep]}</h2>
        <p class="muted">Đã lưu trên máy</p>
      </div>
      <div class="ticket">
        <i class="sun" aria-hidden="true"></i>
        ${body}
        ${errors.length ? '<p class="err">Còn mục bắt buộc chưa điền trên bước này.</p>' : ''}
      </div>
    </main>
    <div class="form-actions">
      <button class="ghost" id="draft" type="button">Lưu nháp</button>
      <button class="btn" id="next" type="button">${formStep < 2 ? 'Tiếp' : 'Gửi phiếu'}</button>
    </div>
  `;
}

function renderResults() {
  const submitted = records.filter((r) => r.status !== 'draft');
  const synced = submitted.filter((r) => r.status === 'synced');
  const pending = submitted.filter((r) => r.status === 'queued' || r.status === 'failed' || r.status === 'syncing');
  const visible = submitted.filter((r) => {
    if (listFilter === 'synced') return r.status === 'synced';
    if (listFilter === 'pending') return r.status !== 'synced';
    return true;
  });
  const markets = countBy(submitted, (r) => r.answers.markets);
  const styles = countBy(submitted, (r) => r.answers.style);
  const ages = countBy(submitted, (r) => r.answers.ageRange);
  const places = countBy(submitted, (r) => r.answers.interviewPlace);
  const countries = countBy(submitted, (r) => r.answers.siteCountry);
  const bands = countBy(submitted, (r) => r.answers.resultBand);
  const sources = countBy(submitted, (r) => r.answers.informationSources);
  const yes = submitted.filter((r) => r.answers.usesStop === 'yes').length;
  const no = submitted.filter((r) => r.answers.usesStop === 'no').length;
  const topMarket = markets[0];
  const topStyle = styles[0];
  const insight = submitted.length
    ? `Trong ${submitted.length} phiếu, nhiều nhất là ${optLabel(MARKETS, topMarket ? topMarket[0] : '')}${topStyle ? `, phong cách ${optLabel(STYLES, topStyle[0])}` : ''}.`
    : 'Gửi phiếu đầu tiên — trang này sẽ thành bảng tổng của cả mẫu.';

  document.getElementById('app').innerHTML = `
    ${header('Kết quả')}
    <main>
      <article class="ticket overview">
        <i class="sun" aria-hidden="true"></i>
        <p class="eyebrow">Tổng mẫu</p>
        <h2>Nhìn cả cuộc điều tra</h2>
        <p class="lead">${esc(insight)}</p>
        <div class="kpis">
          <div><strong>${submitted.length}</strong><span>phiếu</span></div>
          <div><strong>${synced.length}</strong><span>đã gửi</span></div>
          <div><strong>${pending.length}</strong><span>chờ / lỗi</span></div>
          <div><strong>${avgHours(submitted)}</strong><span>giờ/tuần TB</span></div>
        </div>
      </article>
      ${submitted.length ? `
        ${barChart('Thị trường đang chơi', markets, (key) => optLabel(MARKETS, key))}
        ${barChart('Phong cách', styles, (key) => optLabel(STYLES, key))}
        ${donutChart(yes, no)}
        ${barChart('Độ tuổi', ages, (key) => optLabel(AGES, key))}
        ${barChart('Nơi gặp', places, (key) => placeLabel(key))}
        ${barChart('Quốc gia', countries)}
        ${barChart('Kết quả 3 tháng', bands, (key) => optLabel(RESULTS, key))}
        ${barChart('Nguồn thông tin', sources, (key) => optLabel(SOURCES, key))}
      ` : `<div class="panel"><p class="empty">Chưa có số để vẽ biểu đồ. Phỏng vấn xong, gửi phiếu, rồi quay lại đây.</p></div>`}
      <p class="section">Từng phiếu</p>
      <div class="seg" role="tablist">
        <button type="button" data-filter="all" class="${listFilter === 'all' ? 'on' : ''}">Tất cả · ${submitted.length}</button>
        <button type="button" data-filter="synced" class="${listFilter === 'synced' ? 'on' : ''}">Đã gửi · ${synced.length}</button>
        <button type="button" data-filter="pending" class="${listFilter === 'pending' ? 'on' : ''}">Chờ · ${pending.length}</button>
      </div>
      <div class="panel list">
        ${visible.length ? visible.map((r) => `
          <button type="button" data-open="${r.clientId}">
            <span>
              <strong>${esc(r.answers.respondentName || 'Chưa tên')}</strong>
              <span class="muted">${esc(r.answers.siteCountry || '—')} · ${esc(optLabels(MARKETS, r.answers.markets))} · ${esc(optLabel(STYLES, r.answers.style))}</span>
            </span>
            <span class="status ${r.status === 'failed' ? 'fail' : r.status === 'queued' || r.status === 'syncing' ? 'wait' : ''}">${statusShort(r.status)}</span>
          </button>`).join('') : '<p class="empty">Không có phiếu trong nhóm này.</p>'}
      </div>
      <button class="btn" id="start" type="button" style="margin-top:20px">Bắt đầu phỏng vấn</button>
    </main>
    ${nav('results')}
  `;
}

function renderSettings() {
  document.getElementById('app').innerHTML = `
    ${header('Cài đặt')}
    <main>
      <div class="ticket">
        <i class="sun" aria-hidden="true"></i>
        <p class="eyebrow">Người điều tra</p>
        <h2>${COLLECTOR.name}</h2>
        <p class="hint">MSSV ${COLLECTOR.id} · ${window.troveyIsNative && window.troveyIsNative() ? 'Vỏ native' : 'PWA trình duyệt'}</p>
        <p class="who"><a href="${COLLECTOR.url}" target="_blank" rel="noopener">${COLLECTOR.site}</a></p>
      </div>
      <p class="section">Cài máy</p>
      ${installCard()}
      <p class="section">Quyền</p>
      ${permCard()}
      <p class="section">Giao diện</p>
      <div class="panel card-pad">
        <div class="row">
          <button class="choice ${settings.theme === 'paper' ? 'on' : ''}" id="day" type="button">Trời sáng</button>
          <button class="choice ${settings.theme === 'night' ? 'on' : ''}" id="night" type="button">Đêm</button>
        </div>
      </div>
    </main>
    ${nav('settings')}
  `;
}

function fact(label, value) {
  return `<div class="fact"><dt>${label}</dt><dd>${esc(value || '—')}</dd></div>`;
}

function renderDetail(id) {
  const row = records.find((r) => r.clientId === id);
  if (!row) { view = 'results'; render(); return; }
  const a = row.answers;
  const gps = a.gps && a.gps.lat != null
    ? `<a href="https://maps.google.com/?q=${encodeURIComponent(`${a.gps.lat},${a.gps.lng}`)}" target="_blank" rel="noopener">${a.gps.lat}, ${a.gps.lng}</a>`
    : 'Không lấy';
  document.getElementById('app').innerHTML = `
    ${header('Phiếu', true)}
    <main>
      <div class="ticket">
        <i class="sun" aria-hidden="true"></i>
        <p class="eyebrow">Người được hỏi</p>
        <h2>${esc(a.respondentName || 'Chưa tên')}</h2>
        <p class="hint">${esc(a.respondentPhone || 'Không số điện thoại')}</p>
        <span class="status ${row.status === 'failed' ? 'fail' : row.status === 'queued' || row.status === 'syncing' ? 'wait' : ''}">${statusLabel(row.status)}</span>
        ${row.lastError ? `<p class="err">${esc(row.lastError)}</p>` : ''}
      </div>
      ${row.photoB64 ? `<img class="thumb field-photo" alt="Ảnh hiện trường" src="data:image/jpeg;base64,${row.photoB64}" />` : ''}
      <section class="panel card-pad">
        <p class="eyebrow">Hiện trường</p>
        <dl class="facts">
          ${fact('Quốc gia', a.siteCountry)}
          ${fact('Thành phố', a.siteCity)}
          ${fact('Nơi gặp', placeLabel(a.interviewPlace))}
          <div class="fact"><dt>Tọa độ</dt><dd>${gps}</dd></div>
        </dl>
      </section>
      <section class="panel card-pad">
        <p class="eyebrow">Thói quen</p>
        <dl class="facts">
          ${fact('Độ tuổi', optLabel(AGES, a.ageRange))}
          ${fact('Số năm giao dịch', optLabel(YEARS, a.yearsTrading))}
          ${fact('Thị trường', optLabels(MARKETS, a.markets))}
          ${fact('Phong cách', optLabel(STYLES, a.style))}
          ${fact('Giờ/tuần', a.hoursPerWeek)}
          ${fact('Sàn / app', a.platform)}
          ${fact('Stop-loss', a.usesStop === 'yes' ? 'Có' : a.usesStop === 'no' ? 'Không' : '—')}
          ${fact('Nguồn tin', optLabels(SOURCES, a.informationSources))}
          ${fact('Kết quả 3 tháng', optLabel(RESULTS, a.resultBand))}
          ${fact('Khó khăn lớn nhất', a.biggestChallenge)}
          ${fact('Ghi chú', a.notes)}
        </dl>
      </section>
      ${row.status === 'failed' || row.status === 'queued' ? `<button class="btn" id="retry" type="button">Gửi lại</button>` : ''}
    </main>
  `;
  const retry = document.getElementById('retry');
  if (retry) {
    retry.onclick = async () => {
      row.status = 'queued';
      await put(row);
      await drain();
    };
  }
}

function esc(value) {
  return String(value || '')
    .replace(/&/g, '&amp;')
    .replace(/</g, '&lt;')
    .replace(/"/g, '&quot;');
}

function render() {
  document.body.classList.toggle('night', settings.theme === 'night');
  const root = document.getElementById('app');
  root.classList.toggle('form-mode', view === 'form' || view === 'perms');
  if (view === 'perms') renderPerms();
  else if (view === 'form') renderForm();
  else if (view === 'results') renderResults();
  else if (view === 'settings') renderSettings();
  else if (view.startsWith('detail:')) renderDetail(view.slice(7));
  else renderHome();
  bind();
}

function bind() {
  document.querySelectorAll('[data-go]').forEach((btn) => {
    btn.onclick = () => { view = btn.dataset.go; form = null; render(); };
  });
  const back = document.getElementById('back');
  if (back) {
    back.onclick = () => {
      if (String(view).startsWith('detail:')) view = 'results';
      else { view = 'home'; form = null; }
      render();
    };
  }
  document.querySelectorAll('[data-filter]').forEach((btn) => {
    btn.onclick = () => { listFilter = btn.dataset.filter; render(); };
  });
  const start = document.getElementById('start');
  if (start) start.onclick = () => newDraft();
  const resume = document.getElementById('resume');
  if (resume) {
    resume.onclick = () => {
      form = records.find((r) => r.status === 'draft');
      formStep = 0;
      view = 'form';
      render();
    };
  }
  const install = document.getElementById('install');
  if (install) {
    install.onclick = async () => {
      if (window.troveyIsIos && window.troveyIsIos()) {
        showIosSteps = true;
        render();
        return;
      }
      if (deferredInstall) {
        deferredInstall.prompt();
        deferredInstall = null;
        return;
      }
      alert('Dùng menu trình duyệt: Cài ứng dụng hoặc Thêm vào màn hình chính.');
    };
  }
  document.querySelectorAll('[data-open]').forEach((btn) => {
    btn.onclick = () => { view = `detail:${btn.dataset.open}`; render(); };
  });
  const ask = document.getElementById('ask');
  if (ask) ask.onclick = () => askPerms();
  const askAll = document.getElementById('ask-all');
  if (askAll) askAll.onclick = () => askPerms();
  const skipPerm = document.getElementById('skip-perm');
  if (skipPerm) skipPerm.onclick = () => finishPermScreen();
  const openPerms = document.getElementById('open-perms');
  if (openPerms) openPerms.onclick = () => { view = 'perms'; render(); };
  document.querySelectorAll('[data-perm]').forEach((btn) => {
    btn.onclick = () => askOne(btn.dataset.perm);
  });
  const day = document.getElementById('day');
  const night = document.getElementById('night');
  if (day) day.onclick = () => { settings.theme = 'paper'; localStorage.setItem('trovey-theme', 'paper'); render(); };
  if (night) night.onclick = () => { settings.theme = 'night'; localStorage.setItem('trovey-theme', 'night'); render(); };

  document.querySelectorAll('[data-field]').forEach((input) => {
    input.oninput = () => {
      form.answers[input.dataset.field] = input.value;
      saveForm();
    };
  });
  document.querySelectorAll('[data-chip]').forEach((btn) => {
    btn.onclick = () => {
      const name = btn.dataset.chip;
      const value = btn.dataset.value;
      if (btn.dataset.multi === '1') {
        const list = form.answers[name];
        form.answers[name] = list.includes(value) ? list.filter((v) => v !== value) : [...list, value];
      } else {
        form.answers[name] = value;
      }
      saveForm();
      render();
    };
  });
  const gps = document.getElementById('gps');
  if (gps) {
    gps.onclick = async () => {
      const pos = await window.troveyGetGps();
      form.answers.gps = pos;
      await saveForm();
      render();
    };
  }
  const skip = document.getElementById('skip-gps');
  if (skip) {
    skip.onclick = async () => {
      form.answers.gps = null;
      await saveForm();
      render();
    };
  }
  const photo = document.getElementById('photo');
  const file = document.getElementById('file');
  if (photo && file) {
    photo.onclick = async () => {
      const native = await window.troveyTakePhoto();
      if (native) {
        form.photoB64 = native;
        await saveForm();
        render();
        return;
      }
      file.click();
    };
    file.onchange = async () => {
      const picked = file.files && file.files[0];
      if (!picked) return;
      form.photoB64 = await fileToB64(picked);
      await saveForm();
      render();
    };
  }
  const draftBtn = document.getElementById('draft');
  if (draftBtn) draftBtn.onclick = async () => { await saveForm(); view = 'home'; render(); };
  const next = document.getElementById('next');
  if (next) {
    next.onclick = async () => {
      if (stepErrors().length) { render(); return; }
      if (formStep < 2) {
        formStep += 1;
        await saveForm();
        render();
        return;
      }
      form.status = 'queued';
      form.submittedAt = new Date().toISOString();
      await saveForm();
      view = 'results';
      render();
      drain();
    };
  }
}

function fileToB64(file) {
  return new Promise((resolve) => {
    const reader = new FileReader();
    reader.onload = () => {
      const text = String(reader.result || '');
      resolve(text.includes(',') ? text.split(',')[1] : text);
    };
    reader.readAsDataURL(file);
  });
}

window.addEventListener('beforeinstallprompt', (event) => {
  event.preventDefault();
  deferredInstall = event;
});

window.addEventListener('online', () => { online = true; drain(); render(); });
window.addEventListener('offline', () => { online = false; render(); });
navigator.serviceWorker && navigator.serviceWorker.addEventListener('message', (event) => {
  if (event.data && event.data.type === 'DRAIN_QUEUE') drain();
});

async function seedDemo() {
  if (!/demo=1/.test(location.search) || records.length) return;
  const now = new Date().toISOString();
  const samples = [
    { respondentName: 'Lan', siteCountry: 'Việt Nam', siteCity: 'Đà Nẵng', interviewPlace: 'cafe', ageRange: '18-24', yearsTrading: '1-3', markets: ['crypto', 'forex'], style: 'day', hoursPerWeek: '14', platform: 'Binance', usesStop: 'yes', informationSources: ['chart', 'social'], biggestChallenge: 'FOMO khi thị trường xanh', resultBand: 'small' },
    { respondentName: 'Minh', siteCountry: 'Việt Nam', siteCity: 'Hà Nội', interviewPlace: 'office', ageRange: '25-34', yearsTrading: '3-7', markets: ['stocks', 'indices'], style: 'swing', hoursPerWeek: '8', platform: 'SSI', usesStop: 'yes', informationSources: ['news', 'broker'], biggestChallenge: 'Kiên nhẫn giữ lệnh', resultBand: 'strong' },
    { respondentName: 'Huy', siteCountry: 'Singapore', siteCity: 'Singapore', interviewPlace: 'floor', ageRange: '25-34', yearsTrading: '7p', markets: ['futures', 'options', 'forex'], style: 'algo', hoursPerWeek: '20', platform: 'Interactive Brokers', usesStop: 'no', informationSources: ['chart', 'paid'], biggestChallenge: 'Overfitting chiến lược', resultBand: 'flat' },
    { respondentName: 'Trang', siteCountry: 'Việt Nam', siteCity: 'TP.HCM', interviewPlace: 'campus', ageRange: '18-24', yearsTrading: 'lt1', markets: ['crypto'], style: 'copy', hoursPerWeek: '5', platform: 'MEXC', usesStop: 'no', informationSources: ['social', 'friends'], biggestChallenge: 'Không có kế hoạch vốn', resultBand: 'loss' },
    { respondentName: 'Kenji', siteCountry: 'Nhật Bản', siteCity: 'Osaka', interviewPlace: 'home', ageRange: '35-44', yearsTrading: '3-7', markets: ['stocks', 'commodities'], style: 'position', hoursPerWeek: '6', platform: 'Rakuten', usesStop: 'yes', informationSources: ['news', 'chart'], biggestChallenge: 'Tin tức đêm Mỹ', resultBand: 'small' },
  ];
  for (const answers of samples) {
    await put({
      clientId: crypto.randomUUID(),
      status: 'synced',
      answers: { ...emptyAnswers(), ...answers },
      photoB64: '',
      createdAt: now,
      updatedAt: now,
      submittedAt: now,
    });
  }
}

(async function boot() {
  try {
    settings.theme = localStorage.getItem('trovey-theme') || 'paper';
    db = await openDb();
    await loadAll();
    await seedDemo();
    if (window.troveyWaitNative && !/demo=1/.test(location.search)) await window.troveyWaitNative(1800);
    await refreshPerms();
    if (/demo=1/.test(location.search)) view = 'results';
    else if (needsPermScreen()) view = 'perms';
    if (online) drain();
    if ('serviceWorker' in navigator && 'sync' in window.ServiceWorkerRegistration.prototype) {
      try {
        const native = window.troveyIsNative && window.troveyIsNative();
        if (!native) {
          const reg = await navigator.serviceWorker.ready;
          await reg.sync.register('trovey-sync');
        }
      } catch (_) {}
    }
    render();
  } catch (err) {
    console.error(err);
    document.getElementById('app').innerHTML = `<main><p class="err">${esc(err)}</p></main>`;
  }
  hideSplash();
})();

function hideSplash() {
  const splash = document.getElementById('splash');
  if (!splash) return;
  if (/demo=1/.test(location.search)) {
    splash.remove();
    return;
  }
  const wait = Math.max(0, 700 - (Date.now() - splashAt));
  window.setTimeout(() => {
    splash.classList.add('out');
    window.setTimeout(() => splash.remove(), 400);
  }, wait);
}
