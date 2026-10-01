/// Icon names added and removed between two generations.
class IconDiff {
  const IconDiff({required this.added, required this.removed});

  final List<String> added;
  final List<String> removed;

  bool get isEmpty => added.isEmpty && removed.isEmpty;
}

/// Sorted set difference of constant names, old -> new.
IconDiff diffIcons(Iterable<String> before, Iterable<String> after) {
  final b = before.toSet();
  final a = after.toSet();
  return IconDiff(
    added: (a.difference(b).toList())..sort(),
    removed: (b.difference(a).toList())..sort(),
  );
}

final _constantDecl =
    RegExp(r'^\s*static const IconData (\w+) =', multiLine: true);

/// Constant names (aliases included) declared in a previously generated
/// weight file; empty when [source] is null (first generation).
Set<String> constantsInGeneratedSource(String? source) {
  if (source == null) return {};
  return _constantDecl.allMatches(source).map((m) => m.group(1)!).toSet();
}

/// Body bullets for one CHANGELOG section.
///
/// [hadPrevious] is false on the very first generation, which gets a single
/// "Initial release" line instead of a 1500-name "added" list.
String changelogBody({
  required String version,
  required IconDiff diff,
  required bool hadPrevious,
  required int iconsPerWeight,
}) {
  if (!hadPrevious) {
    return '- Initial release, $iconsPerWeight icons per weight '
        '(Phosphor $version: thin, light, regular, bold, fill).';
  }
  if (diff.isEmpty) {
    return '- Synced with Phosphor $version; no icons added or removed.';
  }
  String names(List<String> list) => list.map((n) => '`$n`').join(', ');
  return [
    '- Synced with Phosphor $version, $iconsPerWeight icons per weight.',
    if (diff.added.isNotEmpty)
      '- Added ${diff.added.length}: ${names(diff.added)}.',
    if (diff.removed.isNotEmpty)
      '- **Breaking**: removed ${diff.removed.length}: ${names(diff.removed)}.',
  ].join('\n');
}

/// Inserts `## <version>` + [body] above the newest existing section.
///
/// Returns [changelog] unchanged when that version already has a section,
/// which is what keeps the generator idempotent.
String insertChangelogSection(String? changelog, String version, String body) {
  final section = '## $version\n\n$body\n';
  if (changelog == null || changelog.trim().isEmpty) return section;

  final heading =
      RegExp('^## ${RegExp.escape(version)}\\s*\$', multiLine: true);
  if (heading.hasMatch(changelog)) return changelog;

  final firstSection = RegExp(r'^## ', multiLine: true).firstMatch(changelog);
  if (firstSection == null) {
    // Only a preamble (e.g. "# Changelog"): append below it.
    return '${changelog.trimRight()}\n\n$section';
  }
  final head = changelog.substring(0, firstSection.start);
  final tail = changelog.substring(firstSection.start);
  return '$head$section\n$tail';
}
