import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../data/collector.dart';
import '../data/install.dart';
import '../data/store.dart';
import '../theme/tokens.dart';
import '../widgets/install_card.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key, required this.store});
  final TroveyStore store;

  Future<void> _export(BuildContext context) async {
    final csv = store.exportCsv();
    InstallBridge.downloadText('trovey-phieu.csv', csv);
    await Clipboard.setData(ClipboardData(text: csv));
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(store.t('csvCopied'))));
  }

  @override
  Widget build(BuildContext context) {
    final s = store.settings;
    final theme = Theme.of(context);
    return ListView(
      padding: const EdgeInsets.fromLTRB(TroveySpace.md, TroveySpace.md, TroveySpace.md, TroveySpace.xxl),
      children: [
        Card(
          child: Column(
            children: [
              ListTile(
                title: Text(Collector.name),
                subtitle: Text(store.t('collectorName')),
              ),
              const Divider(),
              ListTile(
                title: const Text(Collector.site),
                subtitle: Text(store.t('collectorSite')),
                trailing: const Icon(Icons.open_in_new),
                onTap: () => InstallBridge.openUrl(Collector.url),
              ),
              const Divider(),
              ListTile(
                title: Text(store.t('collectorId')),
                subtitle: const Text(Collector.id),
              ),
              const Divider(),
              ListTile(
                title: Text(InstallBridge.isNative ? store.t('shellNative') : store.t('shellWeb')),
                subtitle: const Text('Week 5'),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(TroveySpace.md, 0, TroveySpace.md, TroveySpace.md),
                child: Text(
                  store.t('collectorLocked'),
                  style: theme.textTheme.labelMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: TroveySpace.md),
        Card(
          child: Column(
            children: [
              ListTile(
                title: Text(store.t('language')),
                subtitle: Text(s.locale == 'en' ? 'English' : 'Tiếng Việt'),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(TroveySpace.md, 0, TroveySpace.md, TroveySpace.md),
                child: SegmentedButton<String>(
                  segments: const [
                    ButtonSegment(value: 'vi', label: Text('Tiếng Việt')),
                    ButtonSegment(value: 'en', label: Text('English')),
                  ],
                  selected: {s.locale},
                  onSelectionChanged: (next) => store.saveSettings(s..locale = next.first),
                ),
              ),
              const Divider(),
              ListTile(
                title: Text(store.t('theme')),
                subtitle: Text(store.t(s.theme == 'night' ? 'night' : 'paper')),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(TroveySpace.md, 0, TroveySpace.md, TroveySpace.md),
                child: SegmentedButton<String>(
                  segments: [
                    ButtonSegment(value: 'paper', label: Text(store.t('paper'))),
                    ButtonSegment(value: 'night', label: Text(store.t('night'))),
                  ],
                  selected: {s.theme},
                  onSelectionChanged: (next) => store.saveSettings(s..theme = next.first),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: TroveySpace.md),
        InstallCard(store: store),
        const SizedBox(height: TroveySpace.md),
        OutlinedButton.icon(
          onPressed: () => _export(context),
          icon: const Icon(Icons.download),
          label: Text(store.t('exportCsv')),
        ),
      ],
    );
  }
}
