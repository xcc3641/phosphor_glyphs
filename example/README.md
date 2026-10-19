# phosphor_glyphs example

A searchable grid of every Phosphor icon, with a Bold / Duotone toggle.

The iOS runner is checked in, so one command is enough:

```sh
flutter run
```

Only iOS is included to keep this folder small. For other platforms generate
the runner locally (it is git-ignored):

```sh
flutter create . --platforms=android,macos,web
```
