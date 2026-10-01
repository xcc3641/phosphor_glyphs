// Regenerates fonts, constants, pubspec version and CHANGELOG from the npm
// package @phosphor-icons/web.
//
//   dart run tool/generate.dart [--version 2.1.2] [--out .]
//
// Without --version the npm `latest` tag is used. Running it twice with the
// same version leaves the working tree unchanged.

import 'dart:convert';
import 'dart:io';

import 'package:args/args.dart';
import 'package:path/path.dart' as p;

import 'src/changelog.dart';
import 'src/codegen.dart';
import 'src/pubspec_version.dart';
import 'src/selection.dart';
import 'src/weights.dart';

const _npmPackage = '@phosphor-icons/web';

Future<void> main(List<String> args) async {
  final parser = ArgParser()
    ..addOption('version', help: 'Phosphor version (default: npm latest).')
    ..addOption('out', defaultsTo: '.', help: 'Package root to write into.')
    ..addFlag('help', abbr: 'h', negatable: false);
  final opts = parser.parse(args);
  if (opts.flag('help')) {
    stdout.writeln(parser.usage);
    return;
  }

  final out = p.normalize(p.absolute(opts.option('out')!));
  final version = opts.option('version') ?? await _latestVersion();
  stdout.writeln('Generating from $_npmPackage $version into $out');

  final tmp = await Directory.systemTemp.createTemp('phosphor_icons_');
  try {
    final src = await _fetchAndExtract(version, tmp);
    await _generate(src, out, version);
  } finally {
    await tmp.delete(recursive: true);
  }
}

Future<void> _generate(Directory src, String out, String version) async {
  // Diff against what is on disk before overwriting anything.
  final regularFile = File(p.join(out, Weight.regular.dartFile));
  final previousSource =
      regularFile.existsSync() ? regularFile.readAsStringSync() : null;
  final before = constantsInGeneratedSource(previousSource);

  final byWeight = <Weight, List<IconEntry>>{};
  for (final w in Weight.values) {
    final dir = Directory(p.join(src.path, w.name));
    final json =
        jsonDecode(File(p.join(dir.path, 'selection.json')).readAsStringSync())
            as Map<String, Object?>;
    byWeight[w] = parseSelection(json, w.upstreamSuffix);
  }
  // Validate everything before touching the output directory.
  _checkWeightsAgree(byWeight);
  // MIT requires shipping upstream's notice alongside the fonts.
  Directory(p.join(out, 'fonts')).createSync(recursive: true);
  File(p.join(src.parent.path, 'LICENSE'))
      .copySync(p.join(out, 'fonts', 'LICENSE'));
  for (final w in Weight.values) {
    _copyFont(
        Directory(p.join(src.path, w.name)), File(p.join(out, w.fontAsset)));
  }

  final dartFiles = <String>[];
  for (final w in Weight.values) {
    dartFiles.add(
        _write(out, w.dartFile, renderWeightFile(w, byWeight[w]!, version)));
  }
  dartFiles.add(
      _write(out, 'lib/src/phosphor_icons.dart', renderStyleFile(version)));
  await _run('dart', ['format', '--output=write', ...dartFiles], out);

  final pubspec = File(p.join(out, 'pubspec.yaml'));
  pubspec.writeAsStringSync(
      setPubspecVersion(pubspec.readAsStringSync(), version));

  final regular = byWeight[Weight.regular]!;
  final after = {
    for (final e in regular) ...[e.constant, ...e.aliases],
  };
  final diff = diffIcons(before, after);
  final changelog = File(p.join(out, 'CHANGELOG.md'));
  final body = changelogBody(
    version: version,
    diff: diff,
    hadPrevious: previousSource != null,
    iconsPerWeight: regular.length,
  );
  changelog.writeAsStringSync(insertChangelogSection(
    changelog.existsSync() ? changelog.readAsStringSync() : null,
    version,
    body,
  ));

  stdout.writeln('${regular.length} icons per weight; '
      '+${diff.added.length} / -${diff.removed.length} vs. previous generation.');
}

/// Every weight must expose the same names (codepoints may differ: each
/// weight has its own font), otherwise `PhosphorIconsBold.x` would exist
/// while `PhosphorIconsThin.x` does not.
void _checkWeightsAgree(Map<Weight, List<IconEntry>> byWeight) {
  String signature(List<IconEntry> list) =>
      list.map((e) => '${e.constant}:${e.aliases.join('|')}').join(',');
  final reference = signature(byWeight[Weight.regular]!);
  for (final entry in byWeight.entries) {
    if (signature(entry.value) != reference) {
      throw StateError(
          'Weight ${entry.key.name} differs from regular in icon names.');
    }
  }
}

void _copyFont(Directory weightDir, File dest) {
  final ttfs = weightDir
      .listSync()
      .whereType<File>()
      .where((f) => f.path.endsWith('.ttf'))
      .toList();
  if (ttfs.length != 1) {
    throw StateError(
        'Expected one .ttf in ${weightDir.path}, found ${ttfs.length}.');
  }
  dest.parent.createSync(recursive: true);
  ttfs.single.copySync(dest.path);
}

String _write(String out, String relative, String content) {
  final file = File(p.join(out, relative));
  file.parent.createSync(recursive: true);
  file.writeAsStringSync(content);
  return file.path;
}

Future<String> _latestVersion() async {
  final body =
      await _get(Uri.parse('https://registry.npmjs.org/$_npmPackage/latest'));
  return (jsonDecode(utf8.decode(body)) as Map)['version'] as String;
}

/// Downloads and unpacks the npm tarball; returns its `package/src` dir.
Future<Directory> _fetchAndExtract(String version, Directory tmp) async {
  final url =
      Uri.parse('https://registry.npmjs.org/$_npmPackage/-/web-$version.tgz');
  final tarball = File(p.join(tmp.path, 'web.tgz'));
  await tarball.writeAsBytes(await _get(url));
  await _run('tar', ['xzf', tarball.path, '-C', tmp.path], tmp.path);
  final src = Directory(p.join(tmp.path, 'package', 'src'));
  if (!src.existsSync()) throw StateError('No package/src in $url.');
  return src;
}

Future<List<int>> _get(Uri url) async {
  final client = HttpClient();
  try {
    final response = await (await client.getUrl(url)).close();
    if (response.statusCode != HttpStatus.ok) {
      throw HttpException('GET $url -> ${response.statusCode}', uri: url);
    }
    return [for (final chunk in await response.toList()) ...chunk];
  } finally {
    client.close();
  }
}

Future<void> _run(String exe, List<String> args, String cwd) async {
  final result = await Process.run(exe, args, workingDirectory: cwd);
  if (result.exitCode != 0) {
    throw ProcessException(
        exe, args, '${result.stdout}\n${result.stderr}', result.exitCode);
  }
}
