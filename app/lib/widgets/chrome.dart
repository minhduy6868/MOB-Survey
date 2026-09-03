import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../data/i18n.dart';
import '../data/models.dart';
import '../data/store.dart';
import '../theme/tokens.dart';
import 'brand.dart';

class AppHeader extends StatelessWidget {
  const AppHeader({super.key, required this.store});
  final TroveyStore store;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final online = store.online;
    final queued = store.queueCount;
    return Material(
      color: theme.scaffoldBackgroundColor,
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(TroveySpace.md, TroveySpace.sm, TroveySpace.md, TroveySpace.sm),
          child: Row(
            children: [
              const BrandLockup(compact: true),
              const Spacer(),
              if (queued > 0) ...[
                Text(
                  '${store.t('queue')} $queued',
                  style: theme.textTheme.labelMedium,
                ),
                const SizedBox(width: TroveySpace.sm),
              ],
              _LiveChip(online: online, label: store.t(online ? 'online' : 'offline')),
            ],
          ),
        ),
      ),
    );
  }
}

class _LiveChip extends StatelessWidget {
  const _LiveChip({required this.online, required this.label});
  final bool online;
  final String label;

  @override
  Widget build(BuildContext context) {
    final color = online ? TroveyColors.cleared : TroveyColors.stamp;
    return Container(
      constraints: const BoxConstraints(minHeight: 32),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
          const SizedBox(width: 8),
          Text(label, style: TroveyTheme.mono(size: 11, color: color)),
        ],
      ),
    );
  }
}

/// Kept for existing call sites.
class StatusTape extends StatelessWidget {
  const StatusTape({super.key, required this.store});
  final TroveyStore store;

  @override
  Widget build(BuildContext context) => AppHeader(store: store);
}

class TicketCard extends StatelessWidget {
  const TicketCard({super.key, required this.stub, required this.child, this.onTap});

  final String stub;
  final Widget child;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final card = Material(
      color: theme.colorScheme.surface,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: theme.colorScheme.outline.withValues(alpha: 0.9)),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        overlayColor: WidgetStatePropertyAll(theme.colorScheme.primary.withValues(alpha: 0.06)),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(width: 4, color: theme.colorScheme.primary),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(TroveySpace.md),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(stub, style: theme.textTheme.labelMedium?.copyWith(color: theme.colorScheme.primary)),
                      const SizedBox(height: TroveySpace.sm),
                      child,
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
    return card;
  }
}

class StatusStamp extends StatelessWidget {
  const StatusStamp({super.key, required this.status, required this.locale});
  final ResponseStatus status;
  final String locale;

  @override
  Widget build(BuildContext context) {
    final color = switch (status) {
      ResponseStatus.synced => TroveyColors.cleared,
      ResponseStatus.queued || ResponseStatus.syncing => TroveyColors.dawn,
      ResponseStatus.failed => TroveyColors.stamp,
      ResponseStatus.draft => TroveyColors.muted,
    };
    return Container(
      constraints: const BoxConstraints(minHeight: 28),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color),
      ),
      child: Text(
        statusLabel(locale, status.name).toUpperCase(),
        style: TroveyTheme.mono(size: 11, color: color),
      ),
    );
  }
}

class PrimaryButton extends StatefulWidget {
  const PrimaryButton({super.key, required this.label, required this.onPressed, this.busy = false});

  final String label;
  final VoidCallback? onPressed;
  final bool busy;

  @override
  State<PrimaryButton> createState() => _PrimaryButtonState();
}

class _PrimaryButtonState extends State<PrimaryButton> {
  bool _hover = false;
  bool _down = false;
  bool _focus = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final enabled = widget.onPressed != null && !widget.busy;
    final primary = theme.colorScheme.primary;
    final bg = !enabled
        ? TroveyColors.muted
        : _down
            ? TroveyColors.ink
            : _hover
                ? const Color(0xFF0B5C74)
                : primary;
    return FocusableActionDetector(
      enabled: enabled,
      mouseCursor: enabled ? SystemMouseCursors.click : SystemMouseCursors.basic,
      onShowHoverHighlight: (v) => setState(() => _hover = v),
      onShowFocusHighlight: (v) => setState(() => _focus = v),
      actions: {
        ActivateIntent: CallbackAction<ActivateIntent>(
          onInvoke: (_) {
            widget.onPressed?.call();
            return null;
          },
        ),
      },
      child: GestureDetector(
        onTapDown: enabled ? (_) => setState(() => _down = true) : null,
        onTapUp: enabled ? (_) => setState(() => _down = false) : null,
        onTapCancel: () => setState(() => _down = false),
        onTap: enabled
            ? () {
                HapticFeedback.selectionClick();
                widget.onPressed?.call();
              }
            : null,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOut,
          constraints: const BoxConstraints(minHeight: 48, minWidth: 48),
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          decoration: BoxDecoration(
            color: bg.withValues(alpha: enabled ? 1 : 0.45),
            borderRadius: BorderRadius.circular(14),
            border: _focus ? Border.all(color: theme.colorScheme.secondary, width: 2) : null,
          ),
          child: widget.busy
              ? SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: theme.colorScheme.onPrimary,
                  ),
                )
              : Text(
                  widget.label,
                  style: theme.textTheme.labelLarge?.copyWith(color: theme.colorScheme.onPrimary),
                ),
        ),
      ),
    );
  }
}

class GhostButton extends StatefulWidget {
  const GhostButton({super.key, required this.label, required this.onPressed});
  final String label;
  final VoidCallback? onPressed;

  @override
  State<GhostButton> createState() => _GhostButtonState();
}

class _GhostButtonState extends State<GhostButton> {
  bool _hover = false;
  bool _focus = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final enabled = widget.onPressed != null;
    return FocusableActionDetector(
      enabled: enabled,
      mouseCursor: enabled ? SystemMouseCursors.click : SystemMouseCursors.basic,
      onShowHoverHighlight: (v) => setState(() => _hover = v),
      onShowFocusHighlight: (v) => setState(() => _focus = v),
      actions: {
        ActivateIntent: CallbackAction<ActivateIntent>(
          onInvoke: (_) {
            widget.onPressed?.call();
            return null;
          },
        ),
      },
      child: GestureDetector(
        onTap: enabled ? widget.onPressed : null,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          constraints: const BoxConstraints(minHeight: 48, minWidth: 48),
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: _hover ? theme.colorScheme.primary.withValues(alpha: 0.06) : Colors.transparent,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: _focus ? theme.colorScheme.primary : theme.colorScheme.outline,
              width: _focus ? 2 : 1,
            ),
          ),
          child: Text(widget.label, style: theme.textTheme.labelLarge?.copyWith(color: theme.colorScheme.primary)),
        ),
      ),
    );
  }
}

class HorizonBar extends StatelessWidget {
  const HorizonBar({super.key, required this.step, required this.total});
  final int step;
  final int total;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final t = ((step + 1) / total).clamp(0.0, 1.0);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: SizedBox(
            height: 8,
            child: Stack(
              fit: StackFit.expand,
              children: [
                ColoredBox(color: theme.colorScheme.outline.withValues(alpha: 0.45)),
                FractionallySizedBox(
                  alignment: Alignment.centerLeft,
                  widthFactor: t,
                  child: ColoredBox(color: theme.colorScheme.primary),
                ),
              ],
            ),
          ),
        ),
      ],
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
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(TroveySpace.md),
        decoration: BoxDecoration(
          color: theme.colorScheme.error.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: theme.colorScheme.error),
        ),
        child: Text(message, style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.error)),
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
      style: ButtonStyle(
        minimumSize: const WidgetStatePropertyAll(Size(48, 48)),
        visualDensity: VisualDensity.standard,
      ),
    );
  }
}
