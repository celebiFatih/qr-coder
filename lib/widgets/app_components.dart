import 'package:flutter/material.dart';
import 'package:qr_coder/widgets/app_accessibility.dart';
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

class AppChoiceOption<T> {
  const AppChoiceOption({required this.value, required this.label, this.icon});

  final T value;
  final String label;
  final IconData? icon;
}

/// Keeps short option sets compact when space allows, but switches to a
/// vertically readable list for narrow layouts or large accessibility text.
class AppAdaptiveChoiceGroup<T> extends StatelessWidget {
  const AppAdaptiveChoiceGroup({
    super.key,
    required this.options,
    required this.selected,
    required this.onSelected,
  });

  final List<AppChoiceOption<T>> options;
  final T selected;
  final ValueChanged<T> onSelected;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final useVertical =
            constraints.maxWidth < AppBreakpoints.mediumWidth ||
            AppAccessibility.usesLargeText(context);

        if (!useVertical) {
          return SegmentedButton<T>(
            segments: [
              for (final option in options)
                ButtonSegment<T>(
                  value: option.value,
                  icon: option.icon == null ? null : Icon(option.icon),
                  label: Text(option.label),
                ),
            ],
            selected: {selected},
            onSelectionChanged: (selection) {
              if (selection.isNotEmpty) {
                onSelected(selection.first);
              }
            },
          );
        }

        return Column(
          children: [
            for (var index = 0; index < options.length; index++) ...[
              if (index > 0) const Divider(height: 1),
              ListTile(
                minTileHeight: 56,
                leading: options[index].icon == null
                    ? null
                    : Icon(options[index].icon),
                title: Text(options[index].label),
                selected: options[index].value == selected,
                trailing: options[index].value == selected
                    ? const Icon(Icons.check_rounded)
                    : null,
                onTap: () => onSelected(options[index].value),
              ),
            ],
          ],
        );
      },
    );
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
