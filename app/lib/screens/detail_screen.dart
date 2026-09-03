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
    final place = '${row.answers['interviewPlace'] ?? ''}'.trim();
    final title = '${row.answers['siteCountry'] ?? store.t('resume')} · ${row.answers['siteCity'] ?? place}';
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
        Text(title.trim(), style: theme.textTheme.headlineSmall),
        const SizedBox(height: TroveySpace.md),
        PadCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (final field in fieldLabels.keys)
                if ('${row.answers[field] ?? ''}'.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(bottom: TroveySpace.md),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          fieldLabel(field, store.locale),
                          style: theme.textTheme.labelMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                        ),
                        const SizedBox(height: TroveySpace.xs),
                        Text(_display(row.answers[field]), style: theme.textTheme.bodyLarge),
                      ],
                    ),
                  ),
            ],
          ),
        ),
        const SizedBox(height: TroveySpace.md),
        if (canEdit) PrimaryButton(label: store.t('resume'), onPressed: onEdit),
        if (row.status == ResponseStatus.failed || row.status == ResponseStatus.queued) ...[
          const SizedBox(height: TroveySpace.sm),
          PrimaryButton(label: store.t('retry'), onPressed: () => store.sendOne(row.clientId)),
        ],
        const SizedBox(height: TroveySpace.sm),
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
