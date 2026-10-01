# phosphor_icons_flutter

[Phosphor Icons](https://phosphoricons.com) for Flutter, generated straight from the
official `@phosphor-icons/web` fonts and versioned with upstream.

- Every icon is a plain `const IconData` — no `IconData` subclass, so it keeps compiling
  on Flutter 3.43+ where `IconData` is a `final` class.
- Five weights, one class each: `PhosphorIconsThin`, `PhosphorIconsLight`,
  `PhosphorIconsRegular`, `PhosphorIconsBold`, `PhosphorIconsFill`.
- 1512 icons per weight (Phosphor 2.1.2). Duotone is not included yet.

## Usage

```dart
import 'package:phosphor_icons_flutter/phosphor_icons_flutter.dart';

Icon(PhosphorIconsBold.dotsThreeOutline)
Icon(PhosphorIconsRegular.downloadSimple, size: 20, color: Colors.grey)
IconButton(icon: const Icon(PhosphorIconsFill.heart), onPressed: like)
```

Find names on [phosphoricons.com](https://phosphoricons.com) and convert them to
lowerCamelCase without the weight suffix:

| Upstream name            | Constant                                |
| ------------------------ | --------------------------------------- |
| `dots-three-outline`     | `PhosphorIconsRegular.dotsThreeOutline` |
| `download-simple-bold`   | `PhosphorIconsBold.downloadSimple`      |
| `asclepius` / `caduceus` | `asclepius`, plus alias `caduceus`      |

Rules applied by the generator:

- A name that would start with a digit gets an `n` prefix. (None in 2.1.2.)
- A Dart reserved word (`switch`, `class`, `null`, ...) gets an `Icon` suffix:
  `switchIcon`. (None in 2.1.2; `export` and `factory` are legal Dart identifiers and
  keep their names.)
- Where upstream lists two names for one glyph, the first is the constant and the
  others are aliases pointing at it.

Each class also has `values`, a `Map<String, IconData>` of every icon in that weight,
and `PhosphorIconsStyle` (`thin` ... `fill`) has an `icons` getter returning the same
map. Use them for pickers and galleries only; see the next section for why.

## App size

All five fonts are declared in this package's `pubspec.yaml`, so every app gets all
five font assets no matter which classes it imports; importing only one weight does
not drop the others from the asset bundle. As shipped (before tree shaking):

| Font                   | Size   |
| ---------------------- | ------ |
| `Phosphor-Thin.ttf`    | 523 KB |
| `Phosphor-Light.ttf`   | 524 KB |
| `Phosphor-Regular.ttf` | 477 KB |
| `Phosphor-Bold.ttf`    | 484 KB |
| `Phosphor-Fill.ttf`    | 439 KB |

What keeps apps small is Flutter's icon font tree shaking, on by default for
`--release` and `--profile` builds. Every constant is a `const IconData` with a
matching `fontPackage`, so the build cuts each font down to the glyphs your code
references. Each weight file also carries one retained glyph so that a weight you
never use is cut to about 1 KB too; without it, Flutter skips fonts it finds no icon
for and ships them whole.

Measured with `flutter build apk --release` (Flutter 3.47.5, android-arm64):

| App                                             | Bold      | Each other weight | APK     |
| ----------------------------------------------- | --------- | ----------------- | ------- |
| 3 bold + 1 regular icon                         | 1.6 KB    | ~1 KB             | 14.6 MB |
| The example gallery (all bold via `values`)     | 422 KB    | ~1 KB             | 16.8 MB |
| Same 4 icons, before the retained-glyph anchor  | 1.3 KB    | unused: full size | 15.2 MB |

Things that defeat it:

- Referencing `values` or `PhosphorIconsStyle.icons` keeps every glyph of that weight
  (the gallery row above).
- Building an `IconData` at runtime (non-const) makes the release build fail with
  "non-constant instances of IconData"; keep icons `const`.
- `--no-tree-shake-icons` and debug builds (`flutter run`) ship all five fonts whole,
  about 2.4 MB.

## Versioning

The package version is the Phosphor version it was generated from: `2.1.2` ships
`@phosphor-icons/web` 2.1.2. Fixes on our side bump the build number (`2.1.2+1`,
`2.1.2+2`, ...). Each release's CHANGELOG entry lists icons added and removed
relative to the previous one; a removed icon is a breaking change.

## Regenerating

Everything under `fonts/` and `lib/src/` is generated; do not edit it by hand.

```sh
dart run tool/generate.dart                  # npm "latest"
dart run tool/generate.dart --version 2.1.2  # a specific release
```

The generator downloads the npm tarball, copies the five fonts, writes the five
classes, sets `version:` in `pubspec.yaml` and prepends a CHANGELOG section with the
icon diff. Running it twice for the same version changes nothing.

## License

Package code: MIT, see [LICENSE](LICENSE).

The icons and fonts are [Phosphor Icons](https://github.com/phosphor-icons/homepage),
Copyright (c) 2020-2021 Phosphor Icons, MIT License; the upstream license ships as
[fonts/LICENSE](fonts/LICENSE). This package is not affiliated with the Phosphor
project.
