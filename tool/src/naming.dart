/// Dart reserved words. These cannot be identifiers at all, so an icon with
/// one of these names gets an `Icon` suffix (`switch` -> `switchIcon`).
///
/// Built-in identifiers and contextual keywords (`export`, `factory`, `get`,
/// `on`, ...) are legal field names and are left alone.
const dartReservedWords = {
  'assert', 'break', 'case', 'catch', 'class', 'const', 'continue', //
  'default', 'do', 'else', 'enum', 'extends', 'false', 'final', 'finally',
  'for', 'if', 'in', 'is', 'new', 'null', 'rethrow', 'return', 'super',
  'switch', 'this', 'throw', 'true', 'try', 'var', 'void', 'while', 'with',
};

/// Names a static member of the generated classes may not take: members every
/// class inherits from `Object`, plus the generated `values` map.
const reservedMemberNames = {
  'hashCode',
  'noSuchMethod',
  'runtimeType',
  'toString',
  'values',
};

/// Prefix for names that would otherwise start with a digit.
const digitPrefix = 'n';

final _kebab = RegExp(r'^[a-z0-9]+(-[a-z0-9]+)*$');

/// `dots-three-outline` -> `dotsThreeOutline`.
String kebabToLowerCamel(String kebab) {
  final parts = kebab.split('-');
  final buffer = StringBuffer(parts.first);
  for (final part in parts.skip(1)) {
    buffer
      ..write(part[0].toUpperCase())
      ..write(part.substring(1));
  }
  return buffer.toString();
}

/// Strips the weight suffix from an upstream icon name, `acorn-bold` with
/// suffix `-bold` -> `acorn`.
///
/// Throws if a non-empty suffix is missing: upstream renaming its scheme must
/// fail the generator loudly, not produce `acornBold` constants.
String stripWeightSuffix(String name, String suffix) {
  if (suffix.isEmpty) return name;
  if (!name.endsWith(suffix)) {
    throw FormatException('Icon "$name" lacks weight suffix "$suffix".');
  }
  return name.substring(0, name.length - suffix.length);
}

/// Maps a weightless upstream icon name (`dots-three-outline`) to a valid,
/// collision-free Dart identifier (`dotsThreeOutline`).
String iconConstantName(String kebab) {
  if (!_kebab.hasMatch(kebab)) {
    throw FormatException('Unexpected icon name "$kebab".');
  }
  var name = kebabToLowerCamel(kebab);
  if (RegExp(r'^[0-9]').hasMatch(name)) name = '$digitPrefix$name';
  if (dartReservedWords.contains(name) || reservedMemberNames.contains(name)) {
    name = '${name}Icon';
  }
  return name;
}
