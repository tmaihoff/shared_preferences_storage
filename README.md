# Shared Preferences Storage

[![style: very good analysis][very_good_analysis_badge]][very_good_analysis_link]
[![Powered by Mason](https://img.shields.io/endpoint?url=https%3A%2F%2Ftinyurl.com%2Fmason-badge)](https://github.com/felangel/mason)
[![License: MIT][license_badge]][license_link]

A Flutter storage implementation for **[HydratedBloc][hydrated_bloc_link]** and **[HydratedCubit][hydrated_bloc_link]** using [shared_preferences][shared_preferences_link]. This package provides a simple way to persist and restore bloc/cubit state across app restarts.

## Features ✨

- 🔄 **State Persistence**: Automatically persist and restore your bloc/cubit state
- 📱 **Cross-Platform**: Works on iOS, Android, Web, macOS, Windows, and Linux
- 🔒 **Thread-Safe**: Synchronized read/write operations for data integrity
- 🚀 **Easy Setup**: Simple one-line initialization
- 🧪 **Testable**: Built with testing in mind using dependency injection

## Why Use This Package? 🤔

When building Flutter applications with the [bloc][bloc_link] library, you often need to persist state across app restarts. [HydratedBloc][hydrated_bloc_link] and [HydratedCubit][hydrated_bloc_link] provide this functionality but require a `Storage` implementation.

This package provides a **SharedPreferencesStorage** class that implements the `Storage` interface from [hydrated_bloc][hydrated_bloc_link], allowing you to easily persist your bloc/cubit state using [shared_preferences][shared_preferences_link].

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

## Usage 🚀

### Basic Setup with HydratedBloc

Initialize the storage in your `main()` function before running the app:

```dart
import 'package:flutter/material.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:shared_preferences_storage/shared_preferences_storage.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize the storage for HydratedBloc/HydratedCubit
  HydratedBloc.storage = await SharedPreferencesStorage.build();
  
  runApp(const MyApp());
}
```

### Using HydratedCubit

Create a cubit that automatically persists its state:

```dart
import 'package:hydrated_bloc/hydrated_bloc.dart';

class CounterCubit extends HydratedCubit<int> {
  CounterCubit() : super(0);

  void increment() => emit(state + 1);
  void decrement() => emit(state - 1);

  @override
  int fromJson(Map<String, dynamic> json) => json['value'] as int;

  @override
  Map<String, dynamic> toJson(int state) => {'value': state};
}
```

### Using HydratedBloc

Create a bloc that automatically persists its state:

```dart
import 'package:hydrated_bloc/hydrated_bloc.dart';

class CounterBloc extends HydratedBloc<CounterEvent, int> {
  CounterBloc() : super(0) {
    on<Increment>((event, emit) => emit(state + 1));
    on<Decrement>((event, emit) => emit(state - 1));
  }

  @override
  int fromJson(Map<String, dynamic> json) => json['value'] as int;

  @override
  Map<String, dynamic> toJson(int state) => {'value': state};
}
```

---

## API Reference 📚

### SharedPreferencesStorage

| Method | Description |
|--------|-------------|
| `build()` | Returns a singleton instance of `SharedPreferencesStorage`. Subsequent calls return the same instance. |
| `read(String key)` | Reads a value from storage |
| `write(String key, dynamic value)` | Writes a value to storage |
| `delete(String key)` | Deletes a value from storage |
| `clear()` | Clears all values from storage |
| `close()` | Closes the storage instance |

---

## Continuous Integration 🤖

Shared Preferences Storage comes with a built-in [GitHub Actions workflow][github_actions_link] powered by [Very Good Workflows][very_good_workflows_link] but you can also add your preferred CI/CD solution.

Out of the box, on each pull request and push, the CI `formats`, `lints`, and `tests` the code. This ensures the code remains consistent and behaves correctly as you add functionality or make changes. The project uses [Very Good Analysis][very_good_analysis_link] for a strict set of analysis options used by our team. Code coverage is enforced using the [Very Good Workflows][very_good_coverage_link].

---

## Running Tests 🧪

For first time users, install the [very_good_cli][very_good_cli_link]:

```sh
dart pub global activate very_good_cli
```

To run all unit tests:

```sh
very_good test --coverage
```

To view the generated coverage report you can use [lcov](https://github.com/linux-test-project/lcov).

```sh
# Generate Coverage Report
genhtml coverage/lcov.info -o coverage/

# Open Coverage Report
open coverage/index.html
```

---

## Related Packages 📦

- [hydrated_bloc][hydrated_bloc_link] - An extension to the bloc state management library which automatically persists and restores bloc states
- [bloc][bloc_link] - A predictable state management library for Dart
- [shared_preferences][shared_preferences_link] - Flutter plugin for reading and writing simple key-value pairs

## License 📄

This project is licensed under the BSD-3-Clause License - see the [LICENSE](LICENSE) file for details.

[bloc_link]: https://pub.dev/packages/bloc
[flutter_install_link]: https://docs.flutter.dev/get-started/install
[github_actions_link]: https://docs.github.com/en/actions/learn-github-actions
[hydrated_bloc_link]: https://pub.dev/packages/hydrated_bloc
[license_badge]: https://img.shields.io/badge/license-BSD--3--Clause-blue
[license_link]: https://opensource.org/licenses/BSD-3-Clause
[shared_preferences_link]: https://pub.dev/packages/shared_preferences
[very_good_analysis_badge]: https://img.shields.io/badge/style-very_good_analysis-B22C89.svg
[very_good_analysis_link]: https://pub.dev/packages/very_good_analysis
[very_good_cli_link]: https://pub.dev/packages/very_good_cli
[very_good_coverage_link]: https://github.com/marketplace/actions/very-good-coverage
[very_good_workflows_link]: https://github.com/VeryGoodOpenSource/very_good_workflows
