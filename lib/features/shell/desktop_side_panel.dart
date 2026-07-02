import 'package:flutter/material.dart';

/// Docked sidebar chrome for desktop (title bar + optional close).
class DesktopSidePanel extends StatelessWidget {
  const DesktopSidePanel({
    super.key,
    required this.title,
    required this.child,
    this.subtitle,
    this.onClose,
    this.width = 320,
  });

  final String title;
  final Widget? subtitle;
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
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 6, 4, 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: Theme.of(context).textTheme.titleSmall
                                ?.copyWith(fontWeight: FontWeight.w600),
                          ),
                          if (subtitle != null) ...[
                            const SizedBox(height: 2),
                            DefaultTextStyle(
                              style:
                                  Theme.of(context).textTheme.bodySmall ??
                                  const TextStyle(),
                              child: subtitle!,
                            ),
                          ],
                        ],
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
