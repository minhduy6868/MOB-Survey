import 'package:flutter/material.dart';

import '../data/store.dart';
import '../theme/tokens.dart';
import '../widgets/chrome.dart';
import '../widgets/install_card.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key, required this.store});
  final TroveyStore store;

  @override
  Widget build(BuildContext context) {
    final s = store.settings;
    final theme = Theme.of(context);
    return ListView(
      padding: const EdgeInsets.fromLTRB(TroveySpace.md, TroveySpace.md, TroveySpace.md, TroveySpace.xxl),
      children: [
        Text(store.t('settings'), style: theme.textTheme.headlineMedium),
        const SizedBox(height: TroveySpace.md),
        TicketCard(
          stub: 'ID',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(store.t('collectorName')),
              const SizedBox(height: 8),
              TextFormField(
                initialValue: s.collectorName,
                onChanged: (v) => store.saveSettings(s..collectorName = v),
              ),
              const SizedBox(height: 16),
              Text(store.t('collectorId')),
              const SizedBox(height: 8),
              TextFormField(
                initialValue: s.collectorId,
                onChanged: (v) => store.saveSettings(s..collectorId = v),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        TicketCard(
          stub: 'UI',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(store.t('language')),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: [
                  ChoiceChip(
                    label: const Text('Tiếng Việt'),
                    selected: s.locale == 'vi',
                    onSelected: (_) => store.saveSettings(s..locale = 'vi'),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  ),
                  ChoiceChip(
                    label: const Text('English'),
                    selected: s.locale == 'en',
                    onSelected: (_) => store.saveSettings(s..locale = 'en'),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(store.t('theme')),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: [
                  ChoiceChip(
                    label: Text(store.t('paper')),
                    selected: s.theme == 'paper',
                    onSelected: (_) => store.saveSettings(s..theme = 'paper'),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  ),
                  ChoiceChip(
                    label: Text(store.t('night')),
                    selected: s.theme == 'night',
                    onSelected: (_) => store.saveSettings(s..theme = 'night'),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        InstallCard(store: store),
        const SizedBox(height: 16),
        TicketCard(
          stub: 'PWA',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(store.t('diagnostics'), style: theme.textTheme.titleMedium),
              const SizedBox(height: 12),
              _kv('Service Worker', 'trovey-shell-v2'),
              _kv(store.t('webhook'), store.t('webhookReady')),
              _kv(store.t('lastSync'), store.lastSyncAt.isEmpty ? store.t('never') : store.lastSyncAt),
              _kv(store.t('queue'), '${store.queueCount}'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _kv(String k, String v) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Expanded(child: Text(k, style: TroveyTheme.mono(size: 11, color: TroveyColors.muted))),
          Flexible(child: Text(v, style: TroveyTheme.mono(size: 11))),
        ],
      ),
    );
  }
}
