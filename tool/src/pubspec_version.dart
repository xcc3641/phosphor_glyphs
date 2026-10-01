final _versionLine = RegExp(r'^version:[ \t]*(\S+)[ \t]*$', multiLine: true);

/// Points pubspec.yaml's `version:` at Phosphor [version].
///
/// Our own patch releases are `<phosphor>+N`. When the Phosphor version is
/// unchanged the existing line (and its `+N`) is kept; when it moves, the
/// build number resets and the line becomes the plain version.
String setPubspecVersion(String pubspec, String version) {
  final match = _versionLine.firstMatch(pubspec);
  if (match == null) {
    throw const FormatException('pubspec.yaml has no top-level version line.');
  }
  final current = match.group(1)!;
  if (current.split('+').first == version) return pubspec;
  return pubspec.replaceRange(match.start, match.end, 'version: $version');
}
