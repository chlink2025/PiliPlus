# AGENTS.md

PiliPlus is a third-party Bilibili client built with Flutter (Android/iOS/Windows/macOS/Linux). UI strings, many comments, and many commit messages are Chinese; the app locale is fixed to zh_CN with en_US fallback.

## Toolchain

- Flutter is pinned to 3.47.6 (`.fvmrc`, `pubspec.yaml` `environment.flutter`); Dart SDK `>=3.13.0`. Prefer `fvm flutter ...`; CI reads the version from `pubspec.yaml`.
- The code already uses new Dart syntax (dot shorthands like `.handled`, null-aware elements like `?foo` / `[?a]`). Do not "simplify" these.
- Many dependencies are GitHub forks (`get`, `media_kit`, `material_ui`-adjacent packages, `cached_network_image_ce`, ...), so `flutter pub get` needs network access.

## Commands

- Install deps: `fvm flutter pub get`
- Analyze: `fvm flutter analyze` (generated code under `lib/grpc/bilibili/**` and `lib/**/*.g.dart` is excluded via `analysis_options.yaml`)
- All tests: `fvm flutter test`
- Single test: `fvm flutter test test/utils/accounts/deleted_account_test.dart` (currently the only test in the repo)
- Regenerate JNI bindings after touching `android/app/src/main/java`: `dart run tool/jnigen.dart` (writes committed `lib/utils/android/bindings.g.dart`)

## Builds apply Flutter/package patches first

- CI order is: `lib/scripts/build.ps1` -> `lib/scripts/patch.ps1 <android|ios|macos|linux|windows>` -> `flutter build ...`.
- `patch.ps1` needs PowerShell (`pwsh`) and `$FLUTTER_ROOT`; it resets the Flutter checkout, applies `lib/scripts/*.patch` to the SDK, patches pub-cache `material_ui`/`cupertino_ui` with `lib/scripts/{material,cupertino}/*.patch`, then runs `flutter pub get`. The app depends on behavior/APIs from these patches, so reproduce this order for release builds.
- `build.ps1` rewrites `pubspec.yaml` `version` (versionCode = `git rev-list --count HEAD`) and writes gitignored `pili_release.json`, consumed via `--dart-define-from-file`; values are read by `lib/build_config.dart`.
- Android dev/PR builds add `--android-project-arg dev=1`.

## Architecture

- GetX throughout: routes in `lib/router/app_pages.dart`; feature modules are `lib/pages/<feature>/{view,controller}.dart`. Controllers usually extend `CommonController` + `ScrollOrRefreshMixin` (`lib/pages/common/common_controller.dart`), which standardizes loading/refresh/load-more through `lib/http/loading_state.dart`.
- App shell: `lib/main.dart` -> `MainApp` (`lib/pages/main/view.dart`).
- Networking: Dio singleton `Request` in `lib/http/init.dart` (cookie/account interceptor, HTTP/2, retry); endpoint constants in `lib/http/api.dart`; API modules in `lib/http/*.dart`; WBI signing in `lib/utils/wbi_sign.dart`.
- Models are split between `lib/models/` and `lib/models_new/`; both are widely imported, so check both before adding a model.
- Protobuf/gRPC: `lib/grpc/` (generated `.pb.dart`, analyzer-excluded) with transport in `lib/grpc/grpc_req.dart`. Do not edit generated files.
- Player/danmaku: `lib/plugin/pl_player/`; live danmaku over TCP in `lib/tcp/`.
- Persistence: Hive boxes via `GStorage` in `lib/utils/storage.dart`, keys in `lib/utils/storage_key.dart`.
- Use `package:material_ui/material_ui.dart` for widgets (hundreds of files), not `flutter/material.dart`; use `package:cupertino_ui/...` for Cupertino.
- `lib/common/widgets/flutter/` is a vendored copy of framework widgets (text field/selection, sliders, refresh indicator, ...); edit those copies rather than swapping in SDK widgets.

## Conventions

- `always_use_package_imports`: use `package:PiliPlus/...`, never relative imports inside `lib/`.
- `avoid_print`: use `debugPrint` guarded by `kDebugMode`, or `lib/services/logger.dart`.
- Lints are stricter than stock `flutter_lints` (see `analysis_options.yaml`); the formatter preserves trailing commas (`formatter: trailing_commas: preserve`), so keep them.
- CI (`.github/workflows/build.yml`) only builds on manual dispatch; there is no lint/test gate, so run analyze/tests locally.
- `origin` is a fork (`chlink2025/PiliPlus`); `upstream` is the canonical repo (`bggRGjQaUbCoE/PiliPlus`), and upstream merges land on `main`.
