import 'package:flutter_test/flutter_test.dart';

import '../tool/src/naming.dart';

void main() {
  group('iconConstantName', () {
    test('kebab becomes lowerCamel', () {
      expect(iconConstantName('acorn'), 'acorn');
      expect(iconConstantName('dots-three-outline'), 'dotsThreeOutline');
      expect(iconConstantName('number-circle-one'), 'numberCircleOne');
      expect(iconConstantName('arrow-u-down-left'), 'arrowUDownLeft');
    });

    test('digit segments stay as-is inside the name', () {
      expect(iconConstantName('cell-signal-4g'), 'cellSignal4g');
    });

    test('leading digit gets the n prefix', () {
      expect(iconConstantName('3d-box'), 'n3dBox');
      expect(iconConstantName('360'), 'n360');
    });

    test('reserved words get an Icon suffix', () {
      expect(iconConstantName('switch'), 'switchIcon');
      expect(iconConstantName('class'), 'classIcon');
      expect(iconConstantName('null'), 'nullIcon');
      for (final word in dartReservedWords) {
        expect(iconConstantName(word), '${word}Icon');
      }
    });

    test('built-in identifiers are legal field names and are kept', () {
      expect(iconConstantName('export'), 'export');
      expect(iconConstantName('factory'), 'factory');
    });

    test('names clashing with Object members or values get an Icon suffix', () {
      expect(iconConstantName('values'), 'valuesIcon');
      expect(iconConstantName('hash-code'), 'hashCodeIcon');
      expect(iconConstantName('to-string'), 'toStringIcon');
    });

    test('rejects anything that is not lowercase kebab', () {
      for (final bad in ['Acorn', 'a_b', 'a--b', '-a', 'a-', '', 'a b']) {
        expect(() => iconConstantName(bad), throwsFormatException, reason: bad);
      }
    });
  });

  group('stripWeightSuffix', () {
    test('removes the weight suffix', () {
      expect(stripWeightSuffix('acorn-bold', '-bold'), 'acorn');
      expect(stripWeightSuffix('dots-three-thin', '-thin'), 'dots-three');
    });

    test('regular has no suffix', () {
      expect(stripWeightSuffix('acorn', ''), 'acorn');
    });

    test('throws when the suffix is missing', () {
      expect(() => stripWeightSuffix('acorn', '-bold'), throwsFormatException);
    });
  });
}
