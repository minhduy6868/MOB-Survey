import 'package:flutter/material.dart';

import '../data/models.dart';
import '../data/store.dart';
import '../theme/tokens.dart';
import '../widgets/chrome.dart';
import '../widgets/install_card.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key, required this.store, required this.onOpen});

  final TroveyStore store;
  final void Function(String route, {String? id}) onOpen;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final draft = store.openDraft;
    final recent = store.records.take(3).toList();
    final submitted = store.records.where((r) => r.status != ResponseStatus.draft).length;

    return ListView(
      padding: const EdgeInsets.fromLTRB(TroveySpace.md, TroveySpace.lg, TroveySpace.md, TroveySpace.xxl),
      children: [
        Text(store.t('homeEyebrow'), style: theme.textTheme.labelMedium),
        const SizedBox(height: TroveySpace.sm),
        Text(store.t('tagline'), style: theme.textTheme.headlineMedium),
        const SizedBox(height: TroveySpace.md),
        Text(store.t('homeLead'), style: theme.textTheme.bodyLarge?.copyWith(color: TroveyColors.muted, height: 1.5)),
        const SizedBox(height: TroveySpace.lg),
        PrimaryButton(
          label: store.t('homeCta'),
          onPressed: () => onOpen('form'),
        ),
        const SizedBox(height: TroveySpace.lg),
        Row(
          children: [
            Expanded(child: _stat(context, '$submitted', store.t('submittedCount'))),
            const SizedBox(width: TroveySpace.sm),
            Expanded(child: _stat(context, '${store.queueCount}', store.t('queueHint'))),
          ],
        ),
        const SizedBox(height: TroveySpace.lg),
        InstallCard(store: store),
        if (draft != null) ...[
          const SizedBox(height: TroveySpace.xl),
          SectionLabel(store.t('lastDraft')),
          const SizedBox(height: TroveySpace.sm),
          TicketCard(
            stub: draft.clientId.substring(0, 8).toUpperCase(),
            onTap: () => onOpen('form', id: draft.clientId),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    '${draft.answers['siteCountry'] ?? store.t('resume')} · ${draft.answers['siteCity'] ?? ''}'.trim(),
                    style: theme.textTheme.titleMedium,
                  ),
                ),
                StatusStamp(status: draft.status, locale: store.locale),
              ],
            ),
          ),
        ],
        const SizedBox(height: TroveySpace.xl),
        SectionLabel(store.t('recent')),
        const SizedBox(height: TroveySpace.sm),
        if (recent.isEmpty)
          TicketCard(
            stub: store.t('emptyStub'),
            child: Text(store.t('emptyHistory'), style: theme.textTheme.bodyLarge),
          )
        else
          ...recent.map(
            (row) => Padding(
              padding: const EdgeInsets.only(bottom: TroveySpace.sm),
              child: TicketCard(
                stub: row.clientId.substring(0, 8).toUpperCase(),
                onTap: () => onOpen('detail', id: row.clientId),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        '${row.answers['siteCountry'] ?? '—'}  ·  ${row.answers['platform'] ?? ''}',
                        style: theme.textTheme.titleMedium,
                      ),
                    ),
                    StatusStamp(status: row.status, locale: store.locale),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _stat(BuildContext context, String value, String label) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(TroveySpace.md),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.colorScheme.outline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(value, style: theme.textTheme.headlineSmall),
          const SizedBox(height: TroveySpace.xs),
          Text(label, style: theme.textTheme.bodyMedium?.copyWith(color: TroveyColors.muted)),
        ],
      ),
    );
  }
}
