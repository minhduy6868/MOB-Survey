import { listTickets, toCsv } from '../_lib/tickets.js';

export async function onRequestGet({ request, env }) {
  const cors = { 'Access-Control-Allow-Origin': '*' };
  if (!env.TROVEY_RECORDS) {
    return Response.json({ ok: false, error: 'Cloudflare KV not bound' }, { status: 503, headers: cors });
  }

  const records = await listTickets(env.TROVEY_RECORDS);
  const url = new URL(request.url);
  if (url.searchParams.get('format') === 'csv') {
    return new Response(toCsv(records), {
      headers: {
        ...cors,
        'Content-Type': 'text/csv; charset=utf-8',
        'Content-Disposition': 'inline; filename="trovey-tickets.csv"',
        'Cache-Control': 'no-store',
      },
    });
  }

  return Response.json({ ok: true, count: records.length, database: 'cloudflare-kv', records }, { headers: cors });
}

export async function onRequestOptions() {
  return new Response(null, {
    headers: {
      'Access-Control-Allow-Origin': '*',
      'Access-Control-Allow-Methods': 'GET, OPTIONS',
      'Access-Control-Allow-Headers': 'Content-Type',
    },
  });
}
