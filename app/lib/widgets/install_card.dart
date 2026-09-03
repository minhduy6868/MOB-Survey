import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../data/install.dart';
import '../data/store.dart';
import '../theme/tokens.dart';
import 'brand.dart';

class InstallCard extends StatefulWidget {
  const InstallCard({super.key, required this.store});
  final TroveyStore store;

  @override
  State<InstallCard> createState() => _InstallCardState();
}

class _InstallCardState extends State<InstallCard> {
  bool _showIosSteps = false;

  TroveyStore get store => widget.store;

  static const apkUrl = '/downloads/trovey.apk';

  Future<void> _installHome() async {
    if (InstallBridge.isIos) {
      setState(() => _showIosSteps = true);
      return;
    }
    if (InstallBridge.canPrompt) {
      await InstallBridge.prompt();
      if (mounted) setState(() {});
      return;
    }
    if (!mounted) return;
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(store.t('installTitle')),
        content: Text(store.t('installManual')),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text(store.t('back'))),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!kIsWeb) return const SizedBox.shrink();
    final theme = Theme.of(context);
    if (InstallBridge.isStandalone) {
      return Card(
        child: ListTile(
          leading: const Icon(Icons.check_circle_outline),
          title: Text(store.t('installed')),
        ),
      );
    }

    final ios = InstallBridge.isIos;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(TroveySpace.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const BrandMark(size: 48),
            const SizedBox(height: TroveySpace.md),
            Text(store.t('installTitle'), style: theme.textTheme.titleLarge),
            const SizedBox(height: TroveySpace.sm),
            Text(
              ios ? store.t('installIosHint') : store.t('installLead'),
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                height: 1.45,
              ),
            ),
            const SizedBox(height: TroveySpace.md),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: _installHome,
                icon: const Icon(Icons.add_to_home_screen),
                label: Text(ios ? store.t('installIosCta') : store.t('installHome')),
              ),
            ),
            if (!ios) ...[
              const SizedBox(height: TroveySpace.sm),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () => InstallBridge.openUrl(apkUrl),
                  icon: const Icon(Icons.android),
                  label: Text(store.t('installApk')),
                ),
              ),
            ],
            if (ios && _showIosSteps) ...[
              const SizedBox(height: TroveySpace.md),
              Text(store.t('installIosSteps'), style: theme.textTheme.bodyMedium?.copyWith(height: 1.5)),
            ],
          ],
        ),
      ),
    );
  }
}
