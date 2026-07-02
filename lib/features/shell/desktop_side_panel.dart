import 'package:flutter/material.dart';

/// Docked sidebar chrome for desktop (title bar + optional close).
class DesktopSidePanel extends StatelessWidget {
  const DesktopSidePanel({
    super.key,
    required this.title,
    required this.child,
    this.onClose,
    this.width = 320,
  });

  final String title;
  final Widget child;
  final VoidCallback? onClose;
  final double width;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return SizedBox(
      width: width,
      child: Material(
        color: colorScheme.surfaceContainerLow,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Material(
              elevation: 0,
              color: colorScheme.surfaceContainerHighest,
              child: SizedBox(
                height: 40,
                child: Row(
                  children: [
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        title,
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    if (onClose != null)
                      IconButton(
                        icon: const Icon(Icons.close, size: 18),
                        tooltip: 'Hide $title',
                        onPressed: onClose,
                        visualDensity: VisualDensity.compact,
                      ),
                  ],
                ),
              ),
            ),
            Divider(height: 1, color: colorScheme.outlineVariant),
            Expanded(child: child),
          ],
        ),
      ),
    );
  }
}
