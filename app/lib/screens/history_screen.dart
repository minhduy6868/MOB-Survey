import 'package:flutter/material.dart';

import '../data/models.dart';
import '../data/store.dart';
import '../theme/tokens.dart';
import '../widgets/chrome.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key, required this.store, required this.onOpen});

  final TroveyStore store;
  final void Function(String id) onOpen;

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  String _filter = 'all';

  @override
  Widget build(BuildContext context) {
    final store = widget.store;
    final rows = store.records.where((r) {
      if (_filter == 'all') return true;
      return r.status.name == _filter;
    }).toList();

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 48),
      children: [
        Text(store.t('history'), style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w600)),
        const SizedBox(height: 16),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final value in ['all', 'draft', 'queued', 'synced', 'failed'])
              ChoiceChip(
                label: Text(value == 'all' ? store.t('filterAll') : store.t(value)),
                selected: _filter == value,
                onSelected: (_) => setState(() => _filter = value),
                shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
              ),
          ],
        ),
        const SizedBox(height: 16),
        if (rows.isEmpty)
          TicketCard(stub: '0', child: Text(store.t('emptyHistory')))
        else
          ...rows.map(
            (row) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: TicketCard(
                stub: row.clientId.substring(0, 8).toUpperCase(),
                onTap: () => widget.onOpen(row.clientId),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            '${row.answers['siteCountry'] ?? '—'} · ${row.answers['siteCity'] ?? ''}',
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                        ),
                        StatusStamp(status: row.status, locale: store.locale),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      row.updatedAt.replaceFirst('T', '  ').split('.').first,
                      style: TroveyTheme.mono(size: 11, color: TroveyColors.muted),
                    ),
                    if (row.status == ResponseStatus.failed && row.lastError != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text(row.lastError!, style: const TextStyle(color: TroveyColors.stamp, fontSize: 12)),
                      ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }
}
