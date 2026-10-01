# 维护手册

> 设计与取舍见 `docs/PLAN.md`。本文只写「出了新版 / 要修补时具体怎么操作」。

涉及的 workflow(都在 `.github/workflows/`):

| 文件 | 触发 | 做什么 |
| --- | --- | --- |
| `ci.yml` | push 到 main、所有 PR | format 检查 → `dart analyze --fatal-infos` → `flutter test` → `dart pub publish --dry-run`(example 也 pub get + analyze) |
| `upstream-sync.yml` | 每天 UTC 02:00、手动 dispatch | 查 npm `@phosphor-icons/web` 最新版,比 pubspec 新就重新生成、跑检查、开 PR |
| `publish.yml` | push `v*` tag | 校验 tag 与 pubspec 一致 → OIDC 发到 pub.dev |

## ③ 首发前置(只做一次,必须先做)

`publish.yml` 走 pub.dev 的 automated publishing(GitHub OIDC),但 pub.dev 只允许对
**已存在**的包开启它,所以:

1. 首发在本机手动发:
   ```sh
   dart pub publish --dry-run   # 确认 0 warning
   dart pub publish
   ```
2. 打开 <https://pub.dev/packages/phosphor_icons_flutter/admin> → **Automated publishing**
   → 勾选 **Enable publishing from GitHub Actions**:
   - Repository:`xcc3641/phosphor_icons_flutter`
   - Tag pattern:`v{{version}}`
   - 其余(environment 等)留空。
3. 首发版本的 tag 可以补打留档,但推上去会触发 `publish.yml` 并因「版本已存在」失败,
   这次红忽略即可;从下一个版本开始一律走 tag 自动发。

不做第 2 步,`publish.yml` 在 `dart pub publish` 那步会 403。

另外,仓库 Settings → Actions → General → Workflow permissions 需勾选
**Allow GitHub Actions to create and approve pull requests**,否则 sync workflow 开 PR 会失败。

## ① 上游出新版

1. 等 sync PR:`upstream-sync.yml` 每天自动跑,发现 npm 新版就开 PR
   `chore: sync Phosphor <ver>`(分支 `sync/phosphor-<ver>`,label `upstream-sync`),
   正文是 CHANGELOG 顶段(新增/删除图标名)。等不及就手动触发,见 ④。
2. 看 PR 里的新增/删除清单。**删除图标 = 对使用者是 breaking**,合并前确认要不要在
   CHANGELOG 里加醒目说明。
3. 合并 PR。
4. 在 main 上打 tag 并推送,自动发布:
   ```sh
   git switch main && git pull
   git tag v<ver>          # 必须等于 pubspec 的 version:,例如 v2.1.3
   git push origin v<ver>
   ```
5. 在 Actions 里看 `Publish to pub.dev` 变绿,pub.dev 上出现新版本即完成。

注意:
- sync PR 是用默认 `GITHUB_TOKEN` 开的,GitHub 规定这种 PR **不会触发 `ci.yml`**。
  sync workflow 自己已经跑过 format / analyze / test / dry-run,一般可直接合。想让 CI
  也在 PR 上跑:在仓库 secrets 里配一个 `SYNC_PAT`(fine-grained PAT,本仓库
  Contents + Pull requests 读写),workflow 会自动改用它;或者手动关闭再重开 PR。
- 同一版本重复跑不会开第二个 PR:create-pull-request 按分支名 `sync/phosphor-<ver>`
  找到已开的 PR 就原地更新。若那个 PR 被关掉没合,下次定时任务会再开一个新的——
  不想要这个版本就别关,或者先合别的修补把 pubspec 版本推过去。
- sync 跑挂了(生成器报错、测试红)不会开 PR,去 Actions 日志里看。

## ② 我们自己修补(Flutter 兼容、生成器 bug 等)

1. 改代码。生成物(`fonts/`、`lib/src/phosphor_icons*.dart`)**不手改**,改 `tool/`
   后重跑生成器:`dart run tool/generate.dart --version <当前 Phosphor 版本>`。
2. `pubspec.yaml` 的 `version:` 加 / 递增 build 号:`2.1.2` → `2.1.2+1` → `2.1.2+2`。
3. `CHANGELOG.md` 顶部加一段 `## 2.1.2+1`,写清修了什么。
4. 本地自检:
   ```sh
   dart format --output=none --set-exit-if-changed .
   dart analyze --fatal-infos
   flutter test
   dart pub publish --dry-run
   ```
5. 提 PR(模板里三条 checklist 过一遍)→ CI 绿 → 合并。
6. 打 tag 推送:`git tag v2.1.2+1 && git push origin v2.1.2+1`。

## ④ 手动跑 sync

```sh
gh workflow run upstream-sync.yml                    # 用 npm latest
gh workflow run upstream-sync.yml -f version=2.1.3   # 指定版本
gh run watch                                         # 看进度
```

指定的版本必须是 `X.Y.Z` 且比 pubspec 当前版本(去掉 `+N`)新,否则直接结束不做事。

## ⑤ 版本号规则

- `version:` = Phosphor 上游版本,`X.Y.Z` 原样照搬(`2.1.2`)。
- 我们自己的修补只动 build 号:`2.1.2+1`、`2.1.2+2`…;上游出新版后 build 号归零
  (`2.1.3`,不带 `+N`)。
- 比较「上游是否更新」时只看 `X.Y.Z`,忽略 `+N`。
- tag 永远是 `v` + pubspec 的 `version:` 原文(`v2.1.2`、`v2.1.2+1`),`publish.yml`
  校验不一致就直接失败;pub.dev 那边的 tag pattern 也是 `v{{version}}`。
- 不手改 `version:` 去追上游——上游版本只通过生成器(`--version`)写入,保证字体、
  常量、版本号、CHANGELOG 同步。
