import 'package:flutter/material.dart';
import 'package:qr_coder/widgets/app_design_tokens.dart';
import 'package:qr_coder/widgets/banner_ad_widget.dart';

/// Centers page content on wider windows while keeping compact-phone padding
/// predictable. The breakpoint decision is based on the available layout
/// width, not on a device-type or orientation check.
class AppContentFrame extends StatelessWidget {
  const AppContentFrame({
    super.key,
    required this.child,
    this.maxWidth = AppLayoutMetrics.standardContentMaxWidth,
    this.padding,
    this.includeVerticalPadding = true,
  });

  final Widget child;
  final double maxWidth;
  final EdgeInsetsGeometry? padding;
  final bool includeVerticalPadding;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final availableWidth = constraints.hasBoundedWidth
            ? constraints.maxWidth
            : MediaQuery.sizeOf(context).width;
        final horizontal = AppLayoutMetrics.horizontalPaddingForWidth(
          availableWidth,
        );
        final resolvedPadding =
            padding ??
            EdgeInsets.symmetric(
              horizontal: horizontal,
              vertical: includeVerticalPadding ? AppSpacing.md : 0,
            );

        return Padding(
          padding: resolvedPadding,
          child: Align(
            alignment: Alignment.topCenter,
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: maxWidth),
              child: child,
            ),
          ),
        );
      },
    );
  }
}

/// Shared page shell. When [showBannerAd] is true the banner owns a dedicated
/// Scaffold bottom slot, so page content and floating actions cannot occupy the
/// same layout area as the ad.
class AppPageScaffold extends StatelessWidget {
  const AppPageScaffold({
    super.key,
    this.appBar,
    required this.body,
    this.showBannerAd = false,
    this.floatingActionButton,
    this.floatingActionButtonLocation,
    this.resizeToAvoidBottomInset,
    this.backgroundColor,
  });

  final PreferredSizeWidget? appBar;
  final Widget body;
  final bool showBannerAd;
  final Widget? floatingActionButton;
  final FloatingActionButtonLocation? floatingActionButtonLocation;
  final bool? resizeToAvoidBottomInset;
  final Color? backgroundColor;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar,
      body: body,
      backgroundColor: backgroundColor,
      resizeToAvoidBottomInset: resizeToAvoidBottomInset,
      bottomNavigationBar: showBannerAd ? const BannerAdWidget() : null,
      floatingActionButton: floatingActionButton,
      floatingActionButtonLocation: floatingActionButtonLocation,
    );
  }
}
