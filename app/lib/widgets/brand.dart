import 'package:flutter/material.dart';

import '../theme/tokens.dart';

class BrandMark extends StatelessWidget {
  const BrandMark({super.key, this.size = 32, this.rounded = true});

  final double size;
  final bool rounded;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Trovey',
      image: true,
      child: CustomPaint(
        size: Size.square(size),
        painter: _MarkPainter(rounded: rounded),
      ),
    );
  }
}

class BrandLockup extends StatelessWidget {
  const BrandLockup({super.key, this.compact = false});

  final bool compact;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        BrandMark(size: compact ? 28 : 36),
        const SizedBox(width: TroveySpace.sm),
        Text(
          'Trovey',
          style: theme.textTheme.titleLarge?.copyWith(
            letterSpacing: -0.4,
            height: 1,
          ),
        ),
      ],
    );
  }
}

class _MarkPainter extends CustomPainter {
  const _MarkPainter({required this.rounded});
  final bool rounded;

  @override
  void paint(Canvas canvas, Size size) {
    final r = RRect.fromRectAndRadius(
      Offset.zero & size,
      Radius.circular(rounded ? size.width * 0.22 : 0),
    );
    canvas.drawRRect(r, Paint()..color = TroveyColors.brass);

    double map(double v) => v / 512 * size.width;
    final sun = Rect.fromLTWH(map(184), map(104), map(144), map(144));
    final bar = RRect.fromRectAndRadius(
      Rect.fromLTWH(map(80), map(264), map(352), map(64)),
      Radius.circular(map(32)),
    );
    final stem = RRect.fromRectAndRadius(
      Rect.fromLTWH(map(224), map(264), map(64), map(164)),
      Radius.circular(map(32)),
    );
    canvas.drawOval(sun, Paint()..color = TroveyColors.dawn);
    canvas.drawRRect(bar, Paint()..color = TroveyColors.paper);
    canvas.drawRRect(stem, Paint()..color = TroveyColors.paper);
  }

  @override
  bool shouldRepaint(covariant _MarkPainter oldDelegate) => oldDelegate.rounded != rounded;
}
