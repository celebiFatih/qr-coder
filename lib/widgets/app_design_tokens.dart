enum AppWindowSizeClass { compact, medium, expanded }

class AppBreakpoints {
  AppBreakpoints._();

  static const double mediumWidth = 600;
  static const double expandedWidth = 840;
  static const double shortViewportHeight = 760;

  static bool isShortViewport(double height) => height < shortViewportHeight;

  static AppWindowSizeClass classify(double width) {
    if (width < mediumWidth) {
      return AppWindowSizeClass.compact;
    }
    if (width < expandedWidth) {
      return AppWindowSizeClass.medium;
    }
    return AppWindowSizeClass.expanded;
  }
}

class AppSpacing {
  AppSpacing._();

  static const double xxs = 4;
  static const double xs = 8;
  static const double sm = 12;
  static const double md = 16;
  static const double lg = 24;
  static const double xl = 32;
  static const double xxl = 48;
}

class AppRadii {
  AppRadii._();

  static const double control = 16;
  static const double surface = 24;
  static const double sheet = 28;
}

class AppLayoutMetrics {
  AppLayoutMetrics._();

  static const double standardContentMaxWidth = 720;
  static const double wideContentMaxWidth = 1040;
  static const double compactStateMaxWidth = 420;

  static double horizontalPaddingForWidth(double width) {
    return switch (AppBreakpoints.classify(width)) {
      AppWindowSizeClass.compact => AppSpacing.md,
      AppWindowSizeClass.medium => AppSpacing.lg,
      AppWindowSizeClass.expanded => AppSpacing.xl,
    };
  }
}
