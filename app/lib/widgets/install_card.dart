import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../data/install.dart';
import '../data/store.dart';
import '../theme/tokens.dart';
import 'chrome.dart';

class InstallCard extends StatefulWidget {
  const InstallCard({super.key, required this.store});
  final TroveyStore store;

  @override
  State<InstallCard> createState() => _InstallCardState();
}

class _InstallCardState extends State<InstallCard> {
  bool _showIosSteps = false;

  TroveyStore get store => widget.store;

  @override
  Widget build(BuildContext context) {
    if (!kIsWeb) return const SizedBox.shrink();
    if (InstallBridge.isStandalone) {
      return TicketCard(
        stub: 'APP',
        child: Text(store.t('installed'), style: Theme.of(context).textTheme.titleMedium),
      );
    }

    final ios = InstallBridge.isIos;
    return TicketCard(
      stub: 'APP',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(store.t('installTitle'), style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: TroveySpace.sm),
          Text(
            ios ? store.t('installIosHint') : store.t('installAndroidHint'),
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: TroveyColors.muted, height: 1.5),
          ),
          const SizedBox(height: 16),
          PrimaryButton(
            label: ios ? store.t('installIosCta') : store.t('installAndroidCta'),
            onPressed: () async {
              if (ios) {
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
            },
          ),
          if (ios && _showIosSteps) ...[
            const SizedBox(height: 16),
            Text(store.t('installIosSteps'), style: TroveyTheme.mono(size: 12, color: TroveyColors.ink)),
          ],
        ],
      ),
    );
  }
}
