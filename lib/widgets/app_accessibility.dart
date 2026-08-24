import 'package:flutter/material.dart';

/// Central accessibility decisions shared by adaptive presentation widgets.
///
/// The app never clamps the operating-system text scale. Instead, layouts can
/// use this helper to prefer a roomier single-column presentation when text is
/// substantially enlarged.
abstract final class AppAccessibility {
  static const double largeTextScaleThreshold = 1.5;

  static double textScaleOf(BuildContext context) {
    return MediaQuery.textScalerOf(context).scale(1.0);
  }

  static bool usesLargeText(BuildContext context) {
    return textScaleOf(context) >= largeTextScaleThreshold;
  }
}
