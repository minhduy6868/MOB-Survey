import 'package:flutter/material.dart';

import '../data/i18n.dart';
import '../data/models.dart';
import '../data/results.dart';
import '../data/store.dart';
import '../data/survey.dart';
import '../theme/tokens.dart';
import '../widgets/chrome.dart';

class ResultsScreen extends StatelessWidget {
  const ResultsScreen({
    super.key,
    required this.store,
    this.highlightId,
    required this.onNew,
    required this.onOpen,
  });

  final TroveyStore store;
  final String? highlightId;
  final VoidCallback onNew;
  final void Function(String id) onOpen;

  @override
  Widget build(BuildContext context) {
    final stats = SurveyStats.from(store.records);
    final latest = highlightId == null ? null : store.getById(highlightId!);
    final submitted = store.records.where((r) => r.status != ResponseStatus.draft).toList();

    final theme = Theme.of(context);
    return ListView(
      padding: const EdgeInsets.fromLTRB(TroveySpace.md, TroveySpace.md, TroveySpace.md, TroveySpace.xxl),
      children: [
        Text(
          store.t('resultsLead'),
          style: theme.textTheme.bodyLarge?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
            height: 1.5,
          ),
        ),
        const SizedBox(height: TroveySpace.md),
        PadCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('${stats.total}', style: theme.textTheme.displaySmall?.copyWith(color: theme.colorScheme.primary)),
              Text(store.t('submittedCount'), style: theme.textTheme.labelMedium),
            ],
          ),
        ),
        if (latest != null) ...[
          const SizedBox(height: TroveySpace.md),
          SectionLabel(store.t('thisInterview')),
          const SizedBox(height: TroveySpace.sm),
          PadCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _line(context, store.t('synced'), statusLabel(store.locale, latest.status.name)),
                _line(context, fieldLabel('siteCountry', store.locale), '${latest.answers['siteCountry'] ?? '-'}'),
                _line(context, fieldLabel('markets', store.locale), _list(latest.answers['markets'], 'markets')),
                _line(context, fieldLabel('style', store.locale), optionLabel('style', '${latest.answers['style'] ?? ''}', store.locale)),
                _line(context, fieldLabel('hoursPerWeek', store.locale), '${latest.answers['hoursPerWeek'] ?? '-'}'),
                _line(context, fieldLabel('biggestChallenge', store.locale), '${latest.answers['biggestChallenge'] ?? '-'}'),
              ],
            ),
          ),
        ],
        const SizedBox(height: TroveySpace.lg),
        _bars(context, store.t('marketsChart'), stats.markets, 'markets'),
        const SizedBox(height: TroveySpace.md),
        _bars(context, store.t('styleChart'), stats.styles, 'style'),
        const SizedBox(height: TroveySpace.md),
        PadCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(store.t('stopChart'), style: theme.textTheme.titleMedium),
              const SizedBox(height: TroveySpace.sm),
              Text('${store.t('yes')}: ${stats.stops['yes'] ?? 0}   ·   ${store.t('no')}: ${stats.stops['no'] ?? 0}'),
            ],
          ),
        ),
        const SizedBox(height: TroveySpace.lg),
        PrimaryButton(label: store.t('homeCta'), onPressed: onNew),
        const SizedBox(height: TroveySpace.lg),
        SectionLabel(store.t('recent')),
        const SizedBox(height: TroveySpace.sm),
        if (submitted.isEmpty)
          PadCard(child: Text(store.t('emptyHistory')))
        else
          Card(
            child: Column(
              children: [
                for (final row in submitted.take(8)) ...[
                  if (row != submitted.first) const Divider(),
                  ListTile(
                    onTap: () => onOpen(row.clientId),
                    contentPadding: const EdgeInsets.symmetric(horizontal: TroveySpace.md),
                    title: Text(
                      '${row.answers['siteCountry'] ?? store.t('resume')} · ${optionLabel('style', '${row.answers['style'] ?? ''}', store.locale)}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    subtitle: Text(statusLabel(store.locale, row.status.name)),
                    trailing: const Icon(Icons.chevron_right),
                  ),
                ],
              ],
            ),
          ),
      ],
    );
  }

  Widget _line(BuildContext context, String k, String v) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: TroveySpace.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(k, style: theme.textTheme.labelMedium),
          const SizedBox(height: TroveySpace.xs),
          Text(v, style: theme.textTheme.bodyLarge),
        ],
      ),
    );
  }

  String _list(dynamic value, String fieldId) {
    if (value is! List) return '-';
    return value.map((v) => optionLabel(fieldId, '$v', store.locale)).join(', ');
  }

  Widget _bars(BuildContext context, String title, List<CountRow> rows, String fieldId) {
    final theme = Theme.of(context);
    final max = rows.isEmpty ? 1 : rows.first.count;
    return PadCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: theme.textTheme.titleMedium),
          const SizedBox(height: TroveySpace.md),
          if (rows.isEmpty)
            Text(
              store.t('emptyHistory'),
              style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant),
            )
          else
            ...rows.map((row) {
              final w = row.count / max;
              return Padding(
                padding: const EdgeInsets.only(bottom: TroveySpace.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(child: Text(optionLabel(fieldId, row.key, store.locale))),
                        Text('${row.count}', style: theme.textTheme.labelMedium?.copyWith(color: theme.colorScheme.primary)),
                      ],
                    ),
                    const SizedBox(height: TroveySpace.xs),
                    ClipRRect(
                      borderRadius: TroveyRadii.card,
                      child: LinearProgressIndicator(
                        value: w,
                        minHeight: 8,
                        backgroundColor: theme.colorScheme.outlineVariant,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ],
                ),
              );
            }),
        ],
      ),
    );
  }
}
