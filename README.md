# Shared Preferences Storage

[![style: very good analysis][very_good_analysis_badge]][very_good_analysis_link]
[![Powered by Mason](https://img.shields.io/endpoint?url=https%3A%2F%2Ftinyurl.com%2Fmason-badge)](https://github.com/felangel/mason)
[![License: BSD-3-Clause][license_badge]][license_link]

A `Storage` implementation for [HydratedBloc][hydrated_bloc_link] and [HydratedCubit][hydrated_bloc_link] that uses [shared_preferences][shared_preferences_link] to persist state.

## When to Use

Use this package when you need bloc/cubit state to persist across app reinstalls. This is useful for:

- Theme mode preferences
- Onboarding completion flags
- "Rate this app" dialog states
- User preferences and settings

Since `shared_preferences` uses platform-specific persistent storage (NSUserDefaults on iOS/macOS, SharedPreferences on Android, etc.), state may be preserved across app reinstalls depending on the platform's backup behavior.

## Installation 💻

**❗ In order to start using Shared Preferences Storage you must have the [Flutter SDK][flutter_install_link] installed on your machine.**

> **Note**: This package is not published to pub.dev. Install directly from GitHub.

Add `shared_preferences_storage` to your `pubspec.yaml`:

```yaml
dependencies:
  shared_preferences_storage:
    git:
      url: https://github.com/tmaihoff/shared_preferences_storage.git
```

Or install via command line:

```sh
flutter pub add shared_preferences_storage --git-url=https://github.com/tmaihoff/shared_preferences_storage.git
```

---

## API

### SharedPreferencesStorage

| Method | Description |
|--------|-------------|
| `build()` | Returns a singleton instance of `SharedPreferencesStorage`. |
| `read(String key)` | Reads a value from storage. |
| `write(String key, dynamic value)` | Writes a value to storage. |
| `delete(String key)` | Deletes a value from storage. |
| `clear()` | Clears all values from storage. |
| `close()` | Closes the storage instance. |

---

## Running Tests 🧪

Install the [very_good_cli][very_good_cli_link]:

```sh
dart pub global activate very_good_cli
```

Run all unit tests:

```sh
very_good test --coverage
```

---

## Related Packages

- [hydrated_bloc][hydrated_bloc_link] - Bloc state management with automatic persistence
- [bloc][bloc_link] - State management library for Dart
- [shared_preferences][shared_preferences_link] - Platform-specific persistent storage for simple data

## License

BSD-3-Clause. See [LICENSE](LICENSE) for details.

[bloc_link]: https://pub.dev/packages/bloc
[flutter_install_link]: https://docs.flutter.dev/get-started/install
[hydrated_bloc_link]: https://pub.dev/packages/hydrated_bloc
[license_badge]: https://img.shields.io/badge/license-BSD--3--Clause-blue
[license_link]: https://opensource.org/licenses/BSD-3-Clause
[shared_preferences_link]: https://pub.dev/packages/shared_preferences
[very_good_analysis_badge]: https://img.shields.io/badge/style-very_good_analysis-B22C89.svg
[very_good_analysis_link]: https://pub.dev/packages/very_good_analysis
[very_good_cli_link]: https://pub.dev/packages/very_good_cli
