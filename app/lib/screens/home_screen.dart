import 'package:flutter/material.dart';

import '../data/i18n.dart';
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
    final recent = store.records.take(5).toList();
    final submitted = store.records.where((r) => r.status != ResponseStatus.draft).length;

    return ListView(
      padding: const EdgeInsets.fromLTRB(TroveySpace.md, TroveySpace.md, TroveySpace.md, TroveySpace.xxl),
      children: [
        FieldHero(store: store, onStart: () => onOpen('form')),
        const SizedBox(height: TroveySpace.md),
        Card(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: TroveySpace.md, vertical: TroveySpace.lg),
            child: Row(
              children: [
                Expanded(child: _stat(context, '$submitted', store.t('submittedCount'))),
                Container(
                  width: 1,
                  height: 40,
                  color: theme.colorScheme.outlineVariant,
                ),
                Expanded(child: _stat(context, '${store.queueCount}', store.t('queueHint'))),
              ],
            ),
          ),
        ),
        const SizedBox(height: TroveySpace.lg),
        InstallCard(store: store),
        if (draft != null) ...[
          const SizedBox(height: TroveySpace.lg),
          SectionLabel(store.t('lastDraft')),
          const SizedBox(height: TroveySpace.sm),
          Card(
            child: _recordTile(context, draft, () => onOpen('form', id: draft.clientId), inset: true),
          ),
        ],
        const SizedBox(height: TroveySpace.lg),
        SectionLabel(store.t('recent')),
        const SizedBox(height: TroveySpace.sm),
        if (recent.isEmpty)
          Card(
            child: ListTile(
              title: Text(store.t('emptyHistory')),
              subtitle: Text(store.t('homeCta'), style: theme.textTheme.bodyMedium),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => onOpen('form'),
            ),
          )
        else
          Card(
            child: Column(
              children: [
                for (var i = 0; i < recent.length; i++) ...[
                  if (i > 0) const Divider(),
                  _recordTile(context, recent[i], () => onOpen('detail', id: recent[i].clientId), inset: true),
                ],
              ],
            ),
          ),
      ],
    );
  }

  Widget _stat(BuildContext context, String value, String label) {
    final theme = Theme.of(context);
    return Column(
      children: [
        Text(value, style: theme.textTheme.headlineSmall),
        const SizedBox(height: TroveySpace.xs),
        Text(
          label,
          textAlign: TextAlign.center,
          style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant),
        ),
      ],
    );
  }

  Widget _recordTile(BuildContext context, SurveyResponse row, VoidCallback onTap, {bool inset = false}) {
    final person = '${row.answers['respondentName'] ?? ''}'.trim();
    final place = '${row.answers['interviewPlace'] ?? ''}'.trim();
    final title = person.isNotEmpty
        ? person
        : '${row.answers['siteCountry'] ?? store.t('resume')} · ${row.answers['siteCity'] ?? place}';
    final phone = '${row.answers['respondentPhone'] ?? ''}'.trim();
    final sub = [
      if (phone.isNotEmpty) phone,
      statusLabel(store.locale, row.status.name),
    ].join(' · ');
    return ListTile(
      onTap: onTap,
      contentPadding: inset ? const EdgeInsets.symmetric(horizontal: TroveySpace.md) : EdgeInsets.zero,
      leading: Icon(Icons.place_outlined, color: Theme.of(context).colorScheme.primary),
      title: Text(title.trim(), maxLines: 1, overflow: TextOverflow.ellipsis),
      subtitle: Text(sub),
      trailing: const Icon(Icons.chevron_right),
    );
  }
}
