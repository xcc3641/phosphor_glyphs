/// The single-colour Phosphor weights this package ships.
///
/// Duotone is deliberately absent: it needs two stacked glyphs, not one
/// `IconData`.
enum Weight {
  thin,
  light,
  regular,
  bold,
  fill;

  /// `Thin`, `Regular`, ...
  String get title => name[0].toUpperCase() + name.substring(1);

  /// Font family declared in pubspec.yaml, e.g. `Phosphor-Bold`.
  String get fontFamily => 'Phosphor-$title';

  /// Font asset path relative to the package root.
  String get fontAsset => 'fonts/Phosphor-$title.ttf';

  /// Generated class name, e.g. `PhosphorIconsBold`.
  String get className => 'PhosphorIcons$title';

  /// Generated Dart file relative to the package root.
  String get dartFile => 'lib/src/phosphor_icons_$name.dart';

  /// Suffix upstream appends to every icon name in this weight
  /// (`acorn-bold`); regular has none.
  String get upstreamSuffix => this == regular ? '' : '-$name';
}
