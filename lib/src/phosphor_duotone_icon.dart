import 'package:flutter/widgets.dart';

/// A Phosphor duotone icon: an outline glyph drawn over a translucent fill
/// glyph from the same font.
///
/// Both layers are plain `const` [IconData], so release builds tree-shake the
/// duotone font exactly like the single-colour weights. Draw it with
/// [PhosphorDuotoneIcon]; `Icon(...)` only takes one glyph.
@immutable
final class PhosphorDuotoneIconData {
  /// Creates a duotone icon from its [primary] (outline) glyph and optional
  /// [secondary] (fill) glyph.
  const PhosphorDuotoneIconData(this.primary, {this.secondary});

  /// The outline layer, drawn on top at full colour.
  ///
  /// Also usable on its own: `Icon(PhosphorIconsDuotone.acorn.primary)`.
  final IconData primary;

  /// The fill layer, drawn underneath at reduced opacity. Null for the few
  /// icons upstream ships as a single layer (`wifiNone`, `cellSignalNone`).
  final IconData? secondary;

  @override
  bool operator ==(Object other) =>
      other is PhosphorDuotoneIconData &&
      other.primary == primary &&
      other.secondary == secondary;

  @override
  int get hashCode => Object.hash(primary, secondary);

  @override
  String toString() =>
      'PhosphorDuotoneIconData($primary, secondary: $secondary)';
}

/// Draws a [PhosphorDuotoneIconData] as two stacked [Icon]s.
///
/// Sizing and colour follow [Icon]: unset values come from the ambient
/// [IconTheme], and its opacity applies to both layers. The fill layer
/// defaults to the icon colour at [defaultSecondaryOpacity], matching
/// Phosphor's own CSS.
///
/// ```dart
/// PhosphorDuotoneIcon(PhosphorIconsDuotone.acorn, size: 32)
/// PhosphorDuotoneIcon(
///   PhosphorIconsDuotone.heart,
///   color: Colors.red,
///   secondaryColor: Colors.pink.shade100,
/// )
/// ```
class PhosphorDuotoneIcon extends StatelessWidget {
  /// Creates a duotone icon widget.
  const PhosphorDuotoneIcon(
    this.icon, {
    super.key,
    this.size,
    this.color,
    this.secondaryColor,
    this.semanticLabel,
    this.textDirection,
  });

  /// Opacity of the fill layer when [secondaryColor] is not set.
  static const double defaultSecondaryOpacity = 0.2;

  /// The icon to draw.
  final PhosphorDuotoneIconData icon;

  /// See [Icon.size].
  final double? size;

  /// Colour of the outline layer. See [Icon.color].
  final Color? color;

  /// Colour of the fill layer. Defaults to the outline colour at
  /// [defaultSecondaryOpacity].
  final Color? secondaryColor;

  /// See [Icon.semanticLabel].
  final String? semanticLabel;

  /// See [Icon.textDirection].
  final TextDirection? textDirection;

  @override
  Widget build(BuildContext context) {
    final primary = Icon(
      icon.primary,
      size: size,
      color: color,
      semanticLabel: semanticLabel,
      textDirection: textDirection,
    );
    final secondary = icon.secondary;
    if (secondary == null) return primary;

    final base = color ?? IconTheme.of(context).color;
    return Stack(
      alignment: Alignment.center,
      children: [
        Icon(
          secondary,
          size: size,
          color: secondaryColor ??
              base?.withValues(alpha: base.a * defaultSecondaryOpacity),
          textDirection: textDirection,
        ),
        primary,
      ],
    );
  }
}
