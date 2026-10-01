import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:phosphor_icons_flutter/phosphor_icons_flutter.dart';
import 'package:yaml/yaml.dart';

final _pubspec = loadYaml(File('pubspec.yaml').readAsStringSync()) as YamlMap;

/// family -> asset paths, from pubspec.yaml `flutter.fonts`.
final _fonts = {
  for (final f in (_pubspec['flutter'] as YamlMap)['fonts'] as YamlList)
    (f as YamlMap)['family'] as String: [
      for (final a in f['fonts'] as YamlList) (a as YamlMap)['asset'] as String,
    ],
};

void main() {
  test('every style exposes the same icon names', () {
    final names = PhosphorIconsStyle.regular.icons.keys.toList();
    expect(names, hasLength(greaterThan(1000)));
    for (final style in PhosphorIconsStyle.values) {
      expect(style.icons.keys.toList(), names, reason: style.name);
    }
  });

  for (final style in PhosphorIconsStyle.values) {
    group(style.name, () {
      final icons = style.icons.values;

      test('codepoints are unique', () {
        final codes = icons.map((i) => i.codePoint).toList();
        expect(codes.toSet(), hasLength(codes.length));
      });

      test('uses one pubspec font family from this package', () {
        final families = icons.map((i) => i.fontFamily).toSet();
        expect(families, hasLength(1));
        expect(_fonts.keys, contains(families.single));
        expect(
          icons.map((i) => i.fontPackage).toSet(),
          {_pubspec['name']},
        );
      });
    });
  }

  test('pubspec declares exactly one family per style', () {
    expect(_fonts, hasLength(PhosphorIconsStyle.values.length));
    final used = {
      for (final s in PhosphorIconsStyle.values)
        s.icons.values.first.fontFamily,
    };
    expect(used, _fonts.keys.toSet());
  });

  test('every declared font file exists', () {
    for (final asset in _fonts.values.expand((a) => a)) {
      expect(File(asset).existsSync(), isTrue, reason: asset);
    }
  });

  test('aliases point at the same glyph', () {
    expect(PhosphorIconsBold.caduceus, same(PhosphorIconsBold.asclepius));
    expect(PhosphorIconsBold.values.containsKey('caduceus'), isFalse);
  });

  test('constants are plain IconData', () {
    const IconData icon = PhosphorIconsBold.dotsThreeOutline;
    expect(icon.runtimeType, IconData);
    expect(icon.fontFamily, 'Phosphor-Bold');
  });
}
