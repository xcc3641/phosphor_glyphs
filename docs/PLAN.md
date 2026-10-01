# phosphor_glyphs · 计划与追踪

> 追踪在本仓库 GitHub issues(epic #1)。本文是「为什么、做成什么样、怎么维护」的真源,
> 进度不写这里。

## 为什么自己发包

- 上游 `phosphor_flutter` 2.1.0(2024-05)之后停更;`PhosphorIconData extends IconData`
  在 Flutter 3.43+ 直接编译失败(IconData 成了 final class),18 个 open issue 无人合。
- 图标集本身**没有**落后:1512 个/粗细,与 `@phosphor-icons/core` main 一致。
- 我们要的是:随时能跟上游版本、随时能修 Flutter 兼容、包体只带用到的粗细。

## 做成什么样

- 包名 `phosphor_glyphs`,MIT,repo `xcc3641/phosphor_glyphs`。
- 数据源:npm `@phosphor-icons/web` tarball(`src/<weight>/Phosphor.ttf` + `selection.json`,
  2.1 起 codepoint 稳定)。**不**手改任何生成物。
- 版本号 = Phosphor 版本;我们自己的修补用 build 号:`2.1.2`、`2.1.2+1`、`2.1.2+2`…
- 五个单色粗细各一个字体、各一个类:`PhosphorIconsThin / Light / Regular / Bold / Fill`,
  常量名 lowerCamel(`dotsThreeOutline`),数字开头加前缀 `n`,Dart 保留字加后缀 `Icon`。
- 包体(实测 Flutter 3.47 `flutter build apk --release`):五个字体都在 pubspec 里声明,
  **release 构建按用到的 const glyph 裁字体**,用不到的粗细裁到约 1 KB。前提是每个粗细文件
  里那颗 `@pragma('vm:entry-point')` 锚点常量 —— 没有它,一个图标都没用的粗细会整份
  (~500 KB)打进包。引用 `values` 会保留整个粗细;debug 构建不裁。
- 不继承 `IconData`:常量直接是 `IconData(code, fontFamily: 'Phosphor-Bold',
  fontPackage: 'phosphor_glyphs')`。
- `PhosphorIcons.bold.acorn` 这种按粗细动态取的聚合入口可以有,但必须也是 `IconData`。
- duotone 单独 widget(两层 glyph 叠色),**不在首发范围**。
- 生成器:`dart run tool/generate.dart [--version 2.1.2]`,幂等,输出:
  `fonts/Phosphor-<Weight>.ttf`、`lib/src/phosphor_icons_<weight>.dart`、
  `lib/src/phosphor_icons.dart`、`fonts/LICENSE`、改 `pubspec.yaml` 的 `version:`、
  往 `CHANGELOG.md` 顶部插一段(新增/删除的图标名,按 selection.json 差分)。
- 测试只测纯逻辑:名字转换、codepoint 去重、每个粗细常量数一致、字体文件存在且
  `fontFamily` 与 pubspec 一致。不写 widget 测试。

## 怎么维护(和官方保持同步)

- `.github/workflows/upstream-sync.yml`:每天跑一次,查 npm `@phosphor-icons/web`
  latest;比 pubspec 新就跑生成器、`dart analyze`、`dart test`、`dart pub publish --dry-run`,
  有差分就开 PR(标题 `chore: sync Phosphor <ver>`),PR 里贴新增/删除图标清单。
- `.github/workflows/ci.yml`:push/PR 跑 analyze + test + publish dry-run。
- `.github/workflows/publish.yml`:打 `v*` tag 触发 pub.dev 自动发布(GitHub Actions
  publisher,OIDC)。**首发必须人工 `dart pub publish`**,之后在 pub.dev 后台把
  `xcc3641/phosphor_glyphs` 配成 automated publisher,这一步只能广志做。
- 我们自己的修补:改代码 → `+N` → tag → 自动发。上游新版 → 合 sync PR → tag → 自动发。

## 消费方

- flutter_yige 第一处:时刻宫格页 `ExportChromeActionMenu` 触发钮 `ios_share` →
  `dotsThreeOutline`(bold);两格 `save_alt`→`downloadSimple`、`image_outlined`→`imagesSquare`。
- 规则:新图标优先 Phosphor bold,Material 旧图标不主动替换。
