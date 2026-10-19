/// The Phosphor weights this package ships, one font each.
///
/// The first five are single-colour: one glyph per icon, one `IconData`.
/// [duotone] stacks two glyphs per icon and is generated as
/// `PhosphorDuotoneIconData` instead.
enum Weight {
  thin,
  light,
  regular,
  bold,
  fill,
  duotone;

  /// The single-colour weights, the ones `PhosphorIconsStyle` covers.
  static const mono = [thin, light, regular, bold, fill];

  bool get isDuotone => this == duotone;

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
