/**
 * Cloudflare KV is the database.
 * Google Sheets is a mirror. Webhook Anyone is optional.
 * Sheet pulls from Cloudflare: Run syncFromCloudflare() once, then installTrigger().
 */
import { PREFIX, COLLECTOR_NAME, COLLECTOR_ID, listTickets } from '../_lib/tickets.js';

const cors = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'Content-Type',
};

export async function onRequestPost({ request, env }) {
  let body;
  try {
    body = await request.json();
  } catch {
    return Response.json({ ok: false, error: 'invalid json' }, { status: 400, headers: cors });
  }

  const clientId = String(body.clientId || '');
  if (!clientId) {
    return Response.json({ ok: false, error: 'clientId required' }, { status: 400, headers: cors });
  }

  if (!env.TROVEY_RECORDS) {
    return Response.json({ ok: false, error: 'Cloudflare KV not bound' }, { status: 503, headers: cors });
  }

  const stored = {
    ...body,
    clientId,
    collectorName: COLLECTOR_NAME,
    collectorId: COLLECTOR_ID,
    storedAt: new Date().toISOString(),
    database: 'cloudflare-kv',
  };

  const sheetResult = await pushSheet(env.SHEETS_WEBHOOK, stored);
  stored.sheetOk = sheetResult.ok;
  stored.sheetStatus = sheetResult.status || 0;
  await env.TROVEY_RECORDS.put(`${PREFIX}${clientId}`, JSON.stringify(stored));

  if (sheetResult.ok) {
    await flushPendingSheets(env);
  }

  return Response.json(
    {
      ok: true,
      clientId,
      database: 'cloudflare-kv',
      kv: true,
      sheet: sheetResult.ok,
      sheetStatus: sheetResult.status || undefined,
    },
    { headers: cors },
  );
}

async function flushPendingSheets(env) {
  const rows = await listTickets(env.TROVEY_RECORDS);
  for (const row of rows) {
    if (row.sheetOk) continue;
    const result = await pushSheet(env.SHEETS_WEBHOOK, row);
    if (!result.ok) continue;
    row.sheetOk = true;
    row.sheetStatus = result.status;
    await env.TROVEY_RECORDS.put(`${PREFIX}${row.clientId}`, JSON.stringify(row));
  }
}

function readScriptJson(text) {
  try {
    return JSON.parse(text);
  } catch {
    return null;
  }
}

async function pushSheet(url, body) {
  if (!url) return { ok: false, status: 0 };
  const hook = await fetch(url, {
    method: 'POST',
    redirect: 'follow',
    headers: { 'Content-Type': 'text/plain;charset=utf-8' },
    body: JSON.stringify(body),
  });
  const text = await hook.text();
  const parsed = readScriptJson(text);
  return {
    ok: Boolean(hook.ok && parsed && parsed.ok === true),
    status: hook.status,
  };
}

export async function onRequestGet({ env }) {
  const kv = Boolean(env.TROVEY_RECORDS);
  let kvCount = 0;
  if (env.TROVEY_RECORDS) {
    kvCount = (await listTickets(env.TROVEY_RECORDS)).length;
  }

  let sheet = { ok: false, sheetStatus: 0 };
  if (env.SHEETS_WEBHOOK) {
    const ping = await fetch(env.SHEETS_WEBHOOK, { method: 'GET', redirect: 'follow' });
    const text = await ping.text();
    const parsed = readScriptJson(text);
    sheet = {
      ok: Boolean(parsed && parsed.ok === true && parsed.service === 'trovey-sheets'),
      sheetStatus: ping.status,
    };
  }

  return Response.json(
    {
      ok: kv,
      database: 'cloudflare-kv',
      namespace: 'TROVEY_RECORDS',
      kv,
      kvCount,
      sheet: sheet.ok,
      sheetStatus: sheet.sheetStatus,
      canonical: 'https://app.puretrovey.net/',
      csv: 'https://app.puretrovey.net/api/records?format=csv',
      records: 'https://app.puretrovey.net/api/records',
    },
    { headers: cors },
  );
}

export async function onRequestOptions() {
  return new Response(null, {
    headers: {
      'Access-Control-Allow-Origin': '*',
      'Access-Control-Allow-Methods': 'GET, POST, OPTIONS',
      'Access-Control-Allow-Headers': 'Content-Type',
    },
  });
}
