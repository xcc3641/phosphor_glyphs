import 'package:flutter_test/flutter_test.dart';

import '../tool/src/pubspec_version.dart';

void main() {
  const pubspec = 'name: x\nversion: 2.1.2+3\nenvironment:\n  sdk: ^3.6.0\n';

  test('same Phosphor version keeps our build number', () {
    expect(setPubspecVersion(pubspec, '2.1.2'), pubspec);
  });

  test('new Phosphor version resets to the plain version', () {
    expect(
      setPubspecVersion(pubspec, '2.2.0'),
      'name: x\nversion: 2.2.0\nenvironment:\n  sdk: ^3.6.0\n',
    );
  });

  test('plain version without build number is updated in place', () {
    expect(
      setPubspecVersion('name: x\nversion: 0.0.0\n', '2.1.2'),
      'name: x\nversion: 2.1.2\n',
    );
  });

  test('only the top-level version line is touched', () {
    const nested =
        'name: x\nversion: 1.0.0\ndependencies:\n  a:\n    version: 1.0.0\n';
    expect(
      setPubspecVersion(nested, '2.0.0'),
      'name: x\nversion: 2.0.0\ndependencies:\n  a:\n    version: 1.0.0\n',
    );
  });

  test('missing version line throws', () {
    expect(
        () => setPubspecVersion('name: x\n', '1.0.0'), throwsFormatException);
  });
}
