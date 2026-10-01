import 'naming.dart';

/// One glyph of one weight, already mapped to Dart names.
class IconEntry {
  const IconEntry({
    required this.kebab,
    required this.constant,
    required this.codepoint,
    this.aliases = const [],
  });

  /// Weightless upstream name, `dots-three-outline`.
  final String kebab;

  /// Dart identifier, `dotsThreeOutline`.
  final String constant;

  final int codepoint;

  /// Extra Dart identifiers upstream lists for the same glyph
  /// (`asclepius, caduceus` -> `[caduceus]`).
  final List<String> aliases;
}

/// Parses an IcoMoon `selection.json` (already JSON-decoded) for [suffix]
/// (`-bold`, or empty for regular) into entries sorted by constant name.
///
/// Throws on duplicate codepoints or names that collide after conversion, so
/// a bad upstream drop fails generation instead of shipping broken constants.
List<IconEntry> parseSelection(Map<String, Object?> json, String suffix) {
  final icons = json['icons'];
  if (icons is! List) throw const FormatException('selection.json: no icons.');

  final entries = <IconEntry>[];
  final seenNames = <String>{};
  final seenCodes = <int, String>{};

  void claim(String name) {
    if (!seenNames.add(name)) {
      throw FormatException('Two icons map to the Dart name "$name".');
    }
  }

  for (final icon in icons) {
    final props = (icon as Map)['properties'] as Map;
    final code = props['code'] as int;
    final names = (props['name'] as String)
        .split(',')
        .map((n) => stripWeightSuffix(n.trim(), suffix))
        .toList();
    final constants = names.map(iconConstantName).toList();
    for (final c in constants) {
      claim(c);
    }
    final previous = seenCodes[code];
    if (previous != null) {
      throw FormatException(
        'Codepoint 0x${code.toRadixString(16)} used by "$previous" and '
        '"${names.first}".',
      );
    }
    seenCodes[code] = names.first;
    entries.add(IconEntry(
      kebab: names.first,
      constant: constants.first,
      codepoint: code,
      aliases: constants.skip(1).toList(),
    ));
  }
  entries.sort((a, b) => a.constant.compareTo(b.constant));
  return entries;
}
