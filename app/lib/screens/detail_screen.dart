import 'package:flutter/material.dart';

import '../data/models.dart';
import '../data/store.dart';
import '../data/survey.dart';
import '../theme/tokens.dart';
import '../widgets/chrome.dart';

class DetailScreen extends StatelessWidget {
  const DetailScreen({
    super.key,
    required this.store,
    required this.id,
    required this.onBack,
    required this.onEdit,
  });

  final TroveyStore store;
  final String id;
  final VoidCallback onBack;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    final row = store.getById(id);
    if (row == null) {
      return Center(child: Text(store.t('emptyHistory')));
    }
    final canEdit = row.status == ResponseStatus.draft;
    final theme = Theme.of(context);
    return ListView(
      padding: const EdgeInsets.fromLTRB(TroveySpace.md, TroveySpace.md, TroveySpace.md, TroveySpace.xxl),
      children: [
        Row(
          children: [
            GhostButton(label: store.t('back'), onPressed: onBack),
            const Spacer(),
            StatusStamp(status: row.status, locale: store.locale),
          ],
        ),
        const SizedBox(height: TroveySpace.md),
        Text(row.clientId, style: theme.textTheme.labelMedium),
        const SizedBox(height: TroveySpace.md),
        TicketCard(
          stub: 'REC',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (final field in fieldLabels.keys)
                if ('${row.answers[field] ?? ''}'.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(fieldLabel(field, store.locale), style: TroveyTheme.mono(size: 11, color: TroveyColors.muted)),
                        const SizedBox(height: 4),
                        Text(_display(row.answers[field])),
                      ],
                    ),
                  ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        if (canEdit) PrimaryButton(label: store.t('resume'), onPressed: onEdit),
        if (row.status == ResponseStatus.failed || row.status == ResponseStatus.queued) ...[
          const SizedBox(height: 8),
          PrimaryButton(label: store.t('retry'), onPressed: () => store.sendOne(row.clientId)),
        ],
        const SizedBox(height: 8),
        GhostButton(
          label: store.t('delete'),
          onPressed: () async {
            final ok = await showDialog<bool>(
              context: context,
              builder: (ctx) => AlertDialog(
                title: Text(store.t('delete')),
                content: Text(store.t('confirmDelete')),
                actions: [
                  TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(store.t('back'))),
                  TextButton(onPressed: () => Navigator.pop(ctx, true), child: Text(store.t('delete'))),
                ],
              ),
            );
            if (ok == true) {
              await store.delete(row.clientId);
              onBack();
            }
          },
        ),
      ],
    );
  }

  String _display(dynamic value) {
    if (value is List) return value.join(', ');
    if (value is Map && value['lat'] != null) {
      return '${value['lat']}, ${value['lng']}';
    }
    return value?.toString() ?? '';
  }
}
