/**
 * Cloudflare Pages Function — Network-Only sync.
 * Accepts a field ticket, stores a copy in KV (if bound),
 * then appends a row to Google Sheets via Apps Script webhook.
 */
export async function onRequestPost({ request, env }) {
  const cors = {
    'Access-Control-Allow-Origin': '*',
    'Access-Control-Allow-Headers': 'Content-Type',
  };

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

  if (env.TROVEY_RECORDS) {
    await env.TROVEY_RECORDS.put(clientId, JSON.stringify(body));
  }

  let sheet = false;
  if (env.SHEETS_WEBHOOK) {
    const hook = await fetch(env.SHEETS_WEBHOOK, {
      method: 'POST',
      redirect: 'follow',
      headers: { 'Content-Type': 'text/plain;charset=utf-8' },
      body: JSON.stringify(body),
    });
    sheet = hook.ok;
    if (!hook.ok) {
      return Response.json(
        {
          ok: true,
          clientId,
          sheet: false,
          sheetStatus: hook.status,
          hint: 'Apps Script must be deployed as Execute: Me, Who has access: Anyone',
        },
        { headers: cors },
      );
    }
  }

  return Response.json({ ok: true, clientId, sheet, kv: Boolean(env.TROVEY_RECORDS) }, { headers: cors });
}

export async function onRequestOptions() {
  return new Response(null, {
    headers: {
      'Access-Control-Allow-Origin': '*',
      'Access-Control-Allow-Methods': 'POST, OPTIONS',
      'Access-Control-Allow-Headers': 'Content-Type',
    },
  });
}
