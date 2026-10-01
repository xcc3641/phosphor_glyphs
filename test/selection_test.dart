import 'package:flutter_test/flutter_test.dart';

import '../tool/src/selection.dart';

Map<String, Object?> _selection(List<(String, int)> icons) => {
      'icons': [
        for (final (name, code) in icons)
          {
            'properties': {'name': name, 'code': code, 'ligatures': name},
          },
      ],
    };

void main() {
  test('parses, strips the weight suffix and sorts by constant name', () {
    final entries = parseSelection(
      _selection([('dots-three-bold', 2), ('acorn-bold', 1)]),
      '-bold',
    );
    expect(entries.map((e) => e.constant), ['acorn', 'dotsThree']);
    expect(entries.map((e) => e.kebab), ['acorn', 'dots-three']);
    expect(entries.map((e) => e.codepoint), [1, 2]);
  });

  test('comma-separated names become aliases of the first', () {
    final [entry] = parseSelection(
      _selection([('asclepius-fill, caduceus-fill', 7)]),
      '-fill',
    );
    expect(entry.constant, 'asclepius');
    expect(entry.aliases, ['caduceus']);
  });

  test('duplicate codepoints throw', () {
    expect(
      () => parseSelection(_selection([('a', 1), ('b', 1)]), ''),
      throwsFormatException,
    );
  });

  test('names colliding after conversion throw', () {
    expect(
      () => parseSelection(_selection([('a', 1), ('b, a', 2)]), ''),
      throwsFormatException,
    );
  });
}
