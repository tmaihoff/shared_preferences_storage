import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:meta/meta.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:synchronized/synchronized.dart';

/// {@template shared_preferences_storage}
/// Implementation of [Storage] which uses [package:shared_preferences](https://pub.dev/packages/shared_preferences)
/// to persist and retrieve state changes from the shared_preferences storage.
/// {@endtemplate}
class SharedPreferencesStorage implements Storage {
  /// {@macro shared_preferences_storage}
  @visibleForTesting
  SharedPreferencesStorage(
    this._sharedPreferences, {
    bool loggingEnabled = false,
  }) : _loggingEnabled = loggingEnabled;

  /// Returns an instance of [SharedPreferencesStorage].
  ///
  /// Set [loggingEnabled] to `true` to enable debug logging (defaults to
  /// `false`). **Note:** When using this method, the `loggingEnabled` setting
  /// only applies when the instance is first created. Subsequent calls to
  /// `build()` with different `loggingEnabled` values will have no effect due
  /// to the singleton caching behavior.
  ///
  /// ```dart
  /// import 'package:flutter/material.dart';
  ///
  /// import 'package:hydrated_bloc/hydrated_bloc.dart';
  ///
  /// Future<void> main() async {
  ///   WidgetsFlutterBinding.ensureInitialized();
  ///   HydratedBloc.storage = await SharedPreferencesStorage.build();
  ///   runApp(App());
  /// }
  /// ```
  static Future<SharedPreferencesStorage> build({
    bool loggingEnabled = false,
  }) {
    return _lock.synchronized(() async {
      if (_instance != null) return _instance!;

      final sharedPreferences = await SharedPreferences.getInstance();
      return _instance = SharedPreferencesStorage(
        sharedPreferences,
        loggingEnabled: loggingEnabled,
      );
    });
  }

  static final _lock = Lock();
  static SharedPreferencesStorage? _instance;

  final SharedPreferences _sharedPreferences;
  final bool _loggingEnabled;
  bool _closed = false;

  @override
  dynamic read(String key) {
    if (_closed) return null;

    try {
      final value = _sharedPreferences.getString(key);
      if (value == null) return null;
      if (_loggingEnabled) {
        log(
          'Reading key "$key" from SharedPreferences\nValue: $value',
          name: 'SharedPreferencesStorage',
        );
      }
      return json.decode(value);
    } catch (e) {
      if (_loggingEnabled) {
        log(
          'Error reading key "$key" from SharedPreferences',
          name: 'SharedPreferencesStorage',
          error: e,
          stackTrace: StackTrace.current,
        );
      }
      return null;
    }
  }

  @override
  Future<void> write(String key, dynamic value) async {
    if (_closed) return;

    return _lock.synchronized(() async {
      try {
        if (_loggingEnabled) {
          log(
            'Writing key "$key" to SharedPreferences\nValue: $value',
            name: 'SharedPreferencesStorage',
          );
        }
        final encodedValue = json.encode(value);
        await _sharedPreferences.setString(key, encodedValue);
      } catch (e) {
        if (_loggingEnabled) {
          log(
            'Error writing key "$key" to SharedPreferences',
            name: 'SharedPreferencesStorage',
            error: e,
            stackTrace: StackTrace.current,
          );
        }
      }
    });
  }

  @override
  Future<void> delete(String key) async {
    if (_closed) return;

    return _lock.synchronized(() => _sharedPreferences.remove(key));
  }

  @override
  Future<void> clear() async {
    if (_closed) return;

    _instance = null;
    return _lock.synchronized(_sharedPreferences.clear);
  }

  @override
  Future<void> close() async {
    if (_closed) return;

    _closed = true;
    _instance = null;
    // SharedPreferences doesn't need explicit closing
    return Future.value();
  }
}
