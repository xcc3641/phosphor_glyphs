import 'package:flutter_test/flutter_test.dart';

import '../tool/src/changelog.dart';

void main() {
  group('diffIcons', () {
    test('reports sorted additions and removals', () {
      final diff = diffIcons(['b', 'a', 'gone'], ['c', 'a', 'b', 'new']);
      expect(diff.added, ['c', 'new']);
      expect(diff.removed, ['gone']);
      expect(diff.isEmpty, isFalse);
    });

    test('identical sets are empty', () {
      expect(diffIcons(['a'], ['a']).isEmpty, isTrue);
    });
  });

  test('constantsInGeneratedSource picks up IconData constants and aliases',
      () {
    const source = '''
abstract final class PhosphorIconsRegular {
  static const IconData acorn =
      IconData(0xEB9A, fontFamily: _family, fontPackage: _package);
  static const IconData caduceus = asclepius;
  static const Map<String, IconData> values = {'acorn': acorn};
}
''';
    expect(constantsInGeneratedSource(source), {'acorn', 'caduceus'});
    expect(constantsInGeneratedSource(null), isEmpty);
  });

  group('changelogBody', () {
    test('first generation is an initial release line', () {
      final body = changelogBody(
        version: '2.1.2',
        diff: diffIcons([], ['a']),
        hadPrevious: false,
        iconsPerWeight: 1512,
      );
      expect(body, startsWith('- Initial release, 1512 icons per weight'));
    });

    test('lists added and removed names', () {
      final body = changelogBody(
        version: '2.2.0',
        diff: diffIcons(['a', 'old'], ['a', 'new']),
        hadPrevious: true,
        iconsPerWeight: 2,
      );
      expect(body, contains('- Added 1: `new`.'));
      expect(body, contains('removed 1: `old`.'));
    });

    test('no changes still yields a line', () {
      final body = changelogBody(
        version: '2.2.0',
        diff: diffIcons(['a'], ['a']),
        hadPrevious: true,
        iconsPerWeight: 1,
      );
      expect(body, contains('no icons added or removed'));
    });
  });

  group('insertChangelogSection', () {
    test('creates the file content when missing', () {
      expect(insertChangelogSection(null, '1.0.0', '- x'), '## 1.0.0\n\n- x\n');
    });

    test('inserts above the newest section, below the preamble', () {
      const existing = '# Changelog\n\n## 1.0.0\n\n- x\n';
      expect(
        insertChangelogSection(existing, '1.1.0', '- y'),
        '# Changelog\n\n## 1.1.0\n\n- y\n\n## 1.0.0\n\n- x\n',
      );
    });

    test('appends below a preamble-only changelog', () {
      expect(
        insertChangelogSection('# Changelog\n', '1.0.0', '- x'),
        '# Changelog\n\n## 1.0.0\n\n- x\n',
      );
    });

    test('is a no-op when the version already has a section', () {
      const existing = '## 1.1.0\n\n- y\n\n## 1.0.0\n\n- x\n';
      expect(insertChangelogSection(existing, '1.0.0', '- z'), existing);
      expect(insertChangelogSection(existing, '1.1.0', '- z'), existing);
    });

    test('a version that only prefixes another heading is not a match', () {
      const existing = '## 1.0.10\n\n- x\n';
      expect(
        insertChangelogSection(existing, '1.0.1', '- y'),
        '## 1.0.1\n\n- y\n\n## 1.0.10\n\n- x\n',
      );
    });
  });
}
