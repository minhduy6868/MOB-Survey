import 'package:flutter/material.dart';

import '../data/collector.dart';
import '../data/i18n.dart';
import '../data/install.dart';
import '../data/models.dart';
import '../data/store.dart';
import '../theme/tokens.dart';
import 'brand.dart';

class AppHeader extends StatelessWidget implements PreferredSizeWidget {
  const AppHeader({super.key, required this.store, this.title, this.leading});
  final TroveyStore store;
  final String? title;
  final Widget? leading;

  @override
  Size get preferredSize => const Size.fromHeight(64);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final online = store.online;
    final extras = theme.extension<AppColors>();
    final live = online ? (extras?.success ?? TroveyColors.cleared) : theme.colorScheme.error;
    return AppBar(
      leading: leading ?? const Padding(
        padding: EdgeInsets.only(left: TroveySpace.sm),
        child: Center(child: BrandMark(size: 32)),
      ),
      leadingWidth: leading == null ? 48 : 56,
      title: Text(title ?? 'Trovey'),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: TroveySpace.md),
          child: Chip(
            visualDensity: VisualDensity.compact,
            avatar: Icon(Icons.circle, size: 10, color: live),
            label: Text(store.t(online ? 'online' : 'offline')),
          ),
        ),
      ],
    );
  }
}

class StatusTape extends StatelessWidget {
  const StatusTape({super.key, required this.store});
  final TroveyStore store;

  @override
  Widget build(BuildContext context) => AppHeader(store: store);
}

class PadCard extends StatelessWidget {
  const PadCard({super.key, required this.child, this.onTap});

  final Widget child;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final body = Padding(
      padding: const EdgeInsets.all(TroveySpace.md),
      child: child,
    );
    return Card(
      clipBehavior: Clip.antiAlias,
      child: onTap == null ? body : InkWell(onTap: onTap, child: body),
    );
  }
}

class StatusStamp extends StatelessWidget {
  const StatusStamp({super.key, required this.status, required this.locale});
  final ResponseStatus status;
  final String locale;

  @override
  Widget build(BuildContext context) {
    final extras = Theme.of(context).extension<AppColors>();
    final color = switch (status) {
      ResponseStatus.synced => extras?.success ?? TroveyColors.cleared,
      ResponseStatus.queued || ResponseStatus.syncing => extras?.warning ?? TroveyColors.dawn,
      ResponseStatus.failed => Theme.of(context).colorScheme.error,
      ResponseStatus.draft => Theme.of(context).colorScheme.onSurfaceVariant,
    };
    return Chip(
      visualDensity: VisualDensity.compact,
      label: Text(statusLabel(locale, status.name)),
      labelStyle: Theme.of(context).textTheme.labelMedium?.copyWith(color: color),
      side: BorderSide(color: color),
      backgroundColor: color.withValues(alpha: 0.08),
    );
  }
}

class PrimaryButton extends StatelessWidget {
  const PrimaryButton({super.key, required this.label, required this.onPressed, this.busy = false});

  final String label;
  final VoidCallback? onPressed;
  final bool busy;

  @override
  Widget build(BuildContext context) {
    return FilledButton(
      onPressed: busy ? null : onPressed,
      child: busy
          ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator.adaptive(strokeWidth: 2))
          : Text(label),
    );
  }
}

class GhostButton extends StatelessWidget {
  const GhostButton({super.key, required this.label, required this.onPressed});
  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(onPressed: onPressed, child: Text(label));
  }
}

class HorizonBar extends StatelessWidget {
  const HorizonBar({super.key, required this.step, required this.total});
  final int step;
  final int total;

  @override
  Widget build(BuildContext context) {
    return LinearProgressIndicator(
      value: ((step + 1) / total).clamp(0.0, 1.0),
      minHeight: 6,
      borderRadius: TroveyRadii.card,
    );
  }
}

class SectionLabel extends StatelessWidget {
  const SectionLabel(this.text, {super.key});
  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(text, style: Theme.of(context).textTheme.labelMedium);
  }
}

class FieldErrorSummary extends StatelessWidget {
  const FieldErrorSummary({super.key, required this.message});
  final String message;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Semantics(
      liveRegion: true,
      child: Material(
        color: theme.colorScheme.errorContainer,
        borderRadius: TroveyRadii.card,
        child: Padding(
          padding: const EdgeInsets.all(TroveySpace.md),
          child: Text(message, style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onErrorContainer)),
        ),
      ),
    );
  }
}

class ChoicePair extends StatelessWidget {
  const ChoicePair({
    super.key,
    required this.yesLabel,
    required this.noLabel,
    required this.value,
    required this.onChanged,
  });

  final String yesLabel;
  final String noLabel;
  final String? value;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return SegmentedButton<String>(
      segments: [
        ButtonSegment(value: 'yes', label: Text(yesLabel)),
        ButtonSegment(value: 'no', label: Text(noLabel)),
      ],
      selected: {if (value == 'yes' || value == 'no') value!},
      emptySelectionAllowed: true,
      showSelectedIcon: false,
      onSelectionChanged: (next) {
        if (next.isEmpty) return;
        onChanged(next.first);
      },
      style: const ButtonStyle(minimumSize: WidgetStatePropertyAll(Size(48, 48))),
    );
  }
}

class FieldHero extends StatelessWidget {
  const FieldHero({super.key, required this.store, required this.onStart});

  final TroveyStore store;
  final VoidCallback onStart;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const BrandMark(size: 64),
            const SizedBox(width: TroveySpace.md),
            Text(
              'Trovey',
              style: theme.textTheme.headlineMedium?.copyWith(
                letterSpacing: -0.6,
                height: 1.15,
              ),
            ),
          ],
        ),
        const SizedBox(height: TroveySpace.md),
        Text(
          store.t('heroKicker'),
          style: theme.textTheme.labelMedium?.copyWith(color: theme.colorScheme.primary),
        ),
        const SizedBox(height: TroveySpace.sm),
        Text(store.t('topicTitle'), style: theme.textTheme.headlineMedium),
        const SizedBox(height: TroveySpace.sm),
        Text(
          store.t('topicBody'),
          style: theme.textTheme.bodyLarge?.copyWith(
            color: theme.colorScheme.onSurface,
            height: 1.45,
          ),
        ),
        const SizedBox(height: TroveySpace.md),
        Wrap(
          spacing: TroveySpace.sm,
          runSpacing: TroveySpace.sm,
          children: [
            Chip(label: Text(store.t('topicField'))),
            Chip(label: Text(store.t('topicPerson'))),
            Chip(label: Text(store.t('topicHabits'))),
          ],
        ),
        const SizedBox(height: TroveySpace.md),
        Text(
          store.t('heroTitle'),
          style: theme.textTheme.labelMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
            fontWeight: FontWeight.w400,
            height: 1.35,
          ),
        ),
        const SizedBox(height: TroveySpace.sm),
        Text(
          store.t('homeLead'),
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
            height: 1.45,
          ),
        ),
        const SizedBox(height: TroveySpace.md),
        Wrap(
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: TroveySpace.sm,
          runSpacing: TroveySpace.sm,
          children: [
            Text(Collector.name, style: theme.textTheme.titleMedium),
            TextButton(
              onPressed: () => InstallBridge.openUrl(Collector.url),
              child: const Text(Collector.site),
            ),
            Text(Collector.id, style: theme.textTheme.labelMedium),
          ],
        ),
        const SizedBox(height: TroveySpace.lg),
        SizedBox(
          width: double.infinity,
          child: FilledButton(onPressed: onStart, child: Text(store.t('homeCta'))),
        ),
      ],
    );
  }
}

class PageWidth extends StatelessWidget {
  const PageWidth({super.key, required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 560),
        child: child,
      ),
    );
  }
}
