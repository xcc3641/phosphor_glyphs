/// [Phosphor Icons](https://phosphoricons.com) as plain `const` [IconData].
///
/// One class per weight: [PhosphorIconsThin], [PhosphorIconsLight],
/// [PhosphorIconsRegular], [PhosphorIconsBold] and [PhosphorIconsFill].
///
/// ```dart
/// Icon(PhosphorIconsBold.dotsThreeOutline)
/// ```
///
/// Duotone icons stack two glyphs, so they are [PhosphorDuotoneIconData] in
/// [PhosphorIconsDuotone], drawn with [PhosphorDuotoneIcon]:
///
/// ```dart
/// PhosphorDuotoneIcon(PhosphorIconsDuotone.acorn)
/// ```
library;

import 'package:flutter/widgets.dart' show IconData;

export 'src/phosphor_duotone_icon.dart';
export 'src/phosphor_icons.dart';
export 'src/phosphor_icons_bold.dart';
export 'src/phosphor_icons_duotone.dart';
export 'src/phosphor_icons_fill.dart';
export 'src/phosphor_icons_light.dart';
export 'src/phosphor_icons_regular.dart';
export 'src/phosphor_icons_thin.dart';
