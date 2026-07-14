import 'package:flutter/material.dart';
import 'package:netpad/theme/app_spacing.dart';

/// Branded app mark used on About, paywall, and similar premium surfaces.
class AppLogo extends StatelessWidget {
  const AppLogo({super.key, this.size = 72});

  final double size;

  static const assetPath = 'assets/icon/app_icon.png';

  @override
  Widget build(BuildContext context) {
    final radius = size >= 64 ? AppRadii.xl : AppRadii.lg;
    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: Image.asset(
        assetPath,
        width: size,
        height: size,
        filterQuality: FilterQuality.high,
        semanticLabel: 'SB Simple Netpad',
      ),
    );
  }
}
