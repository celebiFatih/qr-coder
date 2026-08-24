import 'package:flutter/material.dart';
import 'package:qr_coder/widgets/app_design_tokens.dart';

class AppSectionHeader extends StatelessWidget {
  const AppSectionHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.trailing,
  });

  final String title;
  final String? subtitle;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: theme.textTheme.titleLarge),
              if (subtitle != null && subtitle!.isNotEmpty) ...[
                const SizedBox(height: AppSpacing.xs),
                Text(
                  subtitle!,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ],
          ),
        ),
        if (trailing != null) ...[
          const SizedBox(width: AppSpacing.sm),
          trailing!,
        ],
      ],
    );
  }
}

class AppSurface extends StatelessWidget {
  const AppSurface({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(AppSpacing.md),
  });

  final Widget child;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(padding: padding, child: child),
    );
  }
}

/// Requires a tooltip for every icon-only action. Flutter's IconButton/Tooltip
/// integration exposes the same label to assistive technologies, while the
/// fixed box keeps the interactive target at least 48dp.
class AppIconButton extends StatelessWidget {
  const AppIconButton({
    super.key,
    required this.tooltip,
    required this.icon,
    required this.onPressed,
    this.semanticLabel,
  });

  final String tooltip;
  final Widget icon;
  final VoidCallback? onPressed;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    Widget button = SizedBox.square(
      dimension: AppSpacing.xxl,
      child: IconButton(tooltip: tooltip, onPressed: onPressed, icon: icon),
    );

    if (semanticLabel != null && semanticLabel != tooltip) {
      button = Semantics(label: semanticLabel, button: true, child: button);
    }

    return button;
  }
}

enum _AppStateKind { loading, empty, error }

class AppStateView extends StatelessWidget {
  const AppStateView.loading({super.key, this.message, this.action})
    : _kind = _AppStateKind.loading,
      icon = null;

  const AppStateView.empty({
    super.key,
    required this.message,
    this.action,
    this.icon = Icons.inbox_outlined,
  }) : _kind = _AppStateKind.empty;

  const AppStateView.error({
    super.key,
    required this.message,
    this.action,
    this.icon = Icons.error_outline_rounded,
  }) : _kind = _AppStateKind.error;

  final _AppStateKind _kind;
  final String? message;
  final Widget? action;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    final indicator = switch (_kind) {
      _AppStateKind.loading => const CircularProgressIndicator(),
      _AppStateKind.empty => Icon(
        icon,
        size: AppSpacing.xxl,
        color: scheme.onSurfaceVariant,
      ),
      _AppStateKind.error => Icon(
        icon,
        size: AppSpacing.xxl,
        color: scheme.error,
      ),
    };

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: AppLayoutMetrics.compactStateMaxWidth,
          ),
          child: Semantics(
            liveRegion: true,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                indicator,
                if (message != null && message!.isNotEmpty) ...[
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    message!,
                    style: theme.textTheme.bodyLarge,
                    textAlign: TextAlign.center,
                  ),
                ],
                if (action != null) ...[
                  const SizedBox(height: AppSpacing.lg),
                  action!,
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
