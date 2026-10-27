import 'package:flutter/material.dart';

/// Keeps filters readable instead of squeezing them into a single row.
class ResponsiveFilterLayout extends StatelessWidget {
  final List<Widget> children;

  const ResponsiveFilterLayout({super.key, required this.children});

  @override
  Widget build(BuildContext context) {
    if (children.isEmpty) return const SizedBox.shrink();
    return LayoutBuilder(
      builder: (context, constraints) {
        const spacing = 12.0;
        final minWidth = 160 * MediaQuery.textScalerOf(context).scale(1);
        final columns = ((constraints.maxWidth + spacing) /
                (minWidth + spacing))
            .floor()
            .clamp(1, children.length);
        final width =
            (constraints.maxWidth - spacing * (columns - 1)) / columns;
        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: [
            for (final child in children) SizedBox(width: width, child: child),
          ],
        );
      },
    );
  }
}
