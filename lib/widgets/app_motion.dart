import 'package:flutter/material.dart';

/// Shared motion timings for small presentation-state changes.
///
/// Material components keep their built-in motion. This helper is reserved for
/// app-owned transitions such as contextual AppBar state changes, and honors
/// the operating system's reduced-motion preference.
abstract final class AppMotion {
  static const Duration shortDuration = Duration(milliseconds: 180);
  static const Duration mediumDuration = Duration(milliseconds: 240);

  static const Curve standardCurve = Curves.easeOutCubic;

  static Duration short(BuildContext context) {
    return MediaQuery.disableAnimationsOf(context)
        ? Duration.zero
        : shortDuration;
  }

  static Duration medium(BuildContext context) {
    return MediaQuery.disableAnimationsOf(context)
        ? Duration.zero
        : mediumDuration;
  }
}
