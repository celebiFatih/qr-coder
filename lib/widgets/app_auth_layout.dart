import 'package:flutter/material.dart';
import 'package:qr_coder/widgets/app_design_tokens.dart';

/// Shared scroll-safe shell for authentication and account-entry flows.
///
/// Content remains top-biased on phones instead of being vertically centered
/// inside a tall viewport, while wider windows receive more breathing room.
/// The single scroll view keeps the form usable with large text, landscape
/// layouts and an on-screen keyboard.
class AppAuthPageFrame extends StatelessWidget {
  const AppAuthPageFrame({super.key, required this.child, this.maxWidth = 480});

  final Widget child;
  final double maxWidth;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.hasBoundedWidth
              ? constraints.maxWidth
              : MediaQuery.sizeOf(context).width;
          final sizeClass = AppBreakpoints.classify(width);
          final horizontal = AppLayoutMetrics.horizontalPaddingForWidth(width);
          final isShortViewport =
              constraints.hasBoundedHeight &&
              AppBreakpoints.isShortViewport(constraints.maxHeight);
          final top = isShortViewport
              ? AppSpacing.md
              : sizeClass == AppWindowSizeClass.compact
              ? AppSpacing.lg
              : AppSpacing.xl;

          return SingleChildScrollView(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            padding: EdgeInsets.fromLTRB(
              horizontal,
              top,
              horizontal,
              AppSpacing.lg,
            ),
            child: Align(
              alignment: Alignment.topCenter,
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: maxWidth),
                child: child,
              ),
            ),
          );
        },
      ),
    );
  }
}
