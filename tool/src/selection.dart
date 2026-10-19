import 'naming.dart';

/// One glyph of one weight, already mapped to Dart names.
class IconEntry {
  const IconEntry({
    required this.kebab,
    required this.constant,
    required this.codepoint,
    this.aliases = const [],
    this.secondaryCodepoint,
  });

  /// Weightless upstream name, `dots-three-outline`.
  final String kebab;

  /// Dart identifier, `dotsThreeOutline`.
  final String constant;

  /// The glyph drawn at full colour. For duotone this is the outline layer.
  final int codepoint;

  /// Duotone only: the translucent fill layer drawn underneath [codepoint].
  /// Null for single-colour weights and for the few duotone icons upstream
  /// ships as a single layer (`wifi-none`).
  final int? secondaryCodepoint;

  /// Extra Dart identifiers upstream lists for the same glyph
  /// (`asclepius, caduceus` -> `[caduceus]`).
  final List<String> aliases;
}

/// Parses an IcoMoon `selection.json` (already JSON-decoded) for [suffix]
/// (`-bold`, or empty for regular) into entries sorted by constant name.
///
/// Throws on duplicate codepoints or names that collide after conversion, so
/// a bad upstream drop fails generation instead of shipping broken constants.
///
/// Duotone icons list two glyphs in `codes`: `[fill, outline]`, matching the
/// `:before` (opacity 0.2) and `:after` rules of upstream's CSS. Those become
/// [IconEntry.secondaryCodepoint] and [IconEntry.codepoint].
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
    final codes = switch (props['codes']) {
      null => [props['code'] as int],
      final List<Object?> list => list.cast<int>(),
      final other => throw FormatException('Unexpected codes: $other.'),
    };
    if (codes.isEmpty || codes.length > 2 || codes.first != props['code']) {
      throw FormatException(
          'Icon "${props['name']}" has codes $codes, code ${props['code']}.');
    }
    final names = (props['name'] as String)
        .split(',')
        .map((n) => stripWeightSuffix(n.trim(), suffix))
        .toList();
    final constants = names.map(iconConstantName).toList();
    for (final c in constants) {
      claim(c);
    }
    for (final code in codes) {
      final previous = seenCodes[code];
      if (previous != null) {
        throw FormatException(
          'Codepoint 0x${code.toRadixString(16)} used by "$previous" and '
          '"${names.first}".',
        );
      }
      seenCodes[code] = names.first;
    }
    entries.add(IconEntry(
      kebab: names.first,
      constant: constants.first,
      codepoint: codes.last,
      secondaryCodepoint: codes.length == 2 ? codes.first : null,
      aliases: constants.skip(1).toList(),
    ));
  }
  entries.sort((a, b) => a.constant.compareTo(b.constant));
  return entries;
}
