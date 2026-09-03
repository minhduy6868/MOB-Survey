import 'package:flutter/material.dart';

import '../theme/tokens.dart';

class BrandMark extends StatelessWidget {
  const BrandMark({super.key, this.size = 32, this.rounded = true});

  final double size;
  final bool rounded;

  @override
  Widget build(BuildContext context) {
    final radius = rounded ? size * 0.22 : 0.0;
    return Semantics(
      label: 'Trovey',
      image: true,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(radius),
        child: Image.asset(
          'assets/brand/mark.png',
          width: size,
          height: size,
          filterQuality: FilterQuality.medium,
        ),
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
            height: 1.15,
          ),
        ),
      ],
    );
  }
}
