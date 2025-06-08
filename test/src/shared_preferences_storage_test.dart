import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shared_preferences_storage/src/shared_preferences_storage.dart';

import 'shared_preferences_storage_test.mocks.dart';

// Helper class for testing non-JSON serializable objects
class NonSerializableObject {
  @override
  String toString() => 'NonSerializableObject';
}

// Annotation to generate MockSharedPreferences.
// This should be at the top level of your test file.
@GenerateMocks([SharedPreferences])
Future<void> main() async {
  late MockSharedPreferences mockSharedPreferences;
  late SharedPreferencesStorage
      storage; // Instance created with mock for most tests

  // Helper function to reset the static singleton state of
  // SharedPreferencesStorage This is important for isolating tests involving
  // SharedPreferencesStorage.build()
  Future<void> resetSingletonAndMocks() async {
    // Reset SharedPreferences mock values for SharedPreferences.getInstance()
    SharedPreferences.setMockInitialValues({});

    // Attempt to get and close any existing singleton instance to reset
    // SharedPreferencesStorage._instance to null.
    // This relies on SharedPreferencesStorage.build() and instance.close()
    // behavior. A dedicated static reset method in
    // SharedPreferencesStorage would be cleaner.
    try {
      final currentInstance = await SharedPreferencesStorage.build();
      await currentInstance
          .close(); // close() sets SharedPreferencesStorage._instance to null
    } catch (e) {
      // Ignored if build fails (e.g., if SharedPreferences.getInstance() was
      // not ready) _instance should ideally be null or will be handled by
      // the next build.
    }
  }

  setUpAll(() {
    // Initialize mock values for SharedPreferences. This affects
    // SharedPreferences.getInstance().
    SharedPreferences.setMockInitialValues({});
  });

  setUp(() async {
    // Reset singleton state before each test
    await resetSingletonAndMocks();
    mockSharedPreferences = MockSharedPreferences();
    // Create a new SharedPreferencesStorage instance with the mock for most
    // tests
    storage = SharedPreferencesStorage(mockSharedPreferences);
  });

  tearDown(() async {
    // Ensure singleton state is reset after each test
    await resetSingletonAndMocks();
  });

  group('SharedPreferencesStorage', () {
    group('build', () {
      test('returns a SharedPreferencesStorage instance', () async {
        final result = await SharedPreferencesStorage.build();
        expect(result, isA<SharedPreferencesStorage>());
      });

      test(
          'returns the same instance when called multiple times '
          '(singleton behavior)', () async {
        final instance1 = await SharedPreferencesStorage.build();
        final instance2 = await SharedPreferencesStorage.build();
        expect(identical(instance1, instance2), isTrue);
      });

      test(
          'completes successfully, implying SharedPreferences.getInstance '
          'was used', () async {
        // Verifies that build doesn't throw, which implies
        // SharedPreferences.getInstance() (called internally) was successful.
        await expectLater(SharedPreferencesStorage.build(), completes);
      });
    });

    group('read', () {
      test('returns null if key does not exist', () {
        when(mockSharedPreferences.getString(any)).thenReturn(null);
        expect(storage.read('non_existent_key'), isNull);
        verify(mockSharedPreferences.getString('non_existent_key')).called(1);
      });

      test('returns decoded value if key exists and JSON is valid', () {
        final data = {'id': 1, 'name': 'Test'};
        when(mockSharedPreferences.getString('valid_key'))
            .thenReturn(json.encode(data));
        expect(storage.read('valid_key'), equals(data));
        verify(mockSharedPreferences.getString('valid_key')).called(1);
      });

      test('returns null if JSON is invalid', () {
        when(mockSharedPreferences.getString('invalid_json_key'))
            .thenReturn('{invalid_json');
        expect(storage.read('invalid_json_key'), isNull);
        verify(mockSharedPreferences.getString('invalid_json_key')).called(1);
      });

      test('returns null if storage is closed', () async {
        await storage.close();
        expect(storage.read('any_key'), isNull);
        verifyNever(mockSharedPreferences.getString(any));
      });
    });

    group('write', () {
      test('writes JSON encoded value to SharedPreferences', () async {
        final data = {'id': 2, 'value': 'Content'};
        final encodedData = json.encode(data);
        when(mockSharedPreferences.setString('write_key', encodedData))
            .thenAnswer((_) async => true);

        await storage.write('write_key', data);

        verify(mockSharedPreferences.setString('write_key', encodedData))
            .called(1);
      });

      test(
          'silently ignores errors during JSON encoding and does not call '
          'setString', () async {
        final nonSerializable = NonSerializableObject();
        // json.encode will throw for NonSerializableObject. SUT catches this.
        await expectLater(
          storage.write('non_serializable_key', nonSerializable),
          completes,
        );
        verifyNever(mockSharedPreferences.setString(any, any));
      });

      test('does nothing if storage is closed', () async {
        await storage.close();
        await storage.write('any_key', {'data': 'value'});
        verifyNever(mockSharedPreferences.setString(any, any));
      });
    });

    group('delete', () {
      test('removes key from SharedPreferences', () async {
        when(mockSharedPreferences.remove('delete_key'))
            .thenAnswer((_) async => true);
        await storage.delete('delete_key');
        verify(mockSharedPreferences.remove('delete_key')).called(1);
      });

      test('does nothing if storage is closed', () async {
        await storage.close();
        await storage.delete('any_key');
        verifyNever(mockSharedPreferences.remove(any));
      });
    });

    group('clear', () {
      test(
          'clears all data from SharedPreferences and resets static '
          'instance', () async {
        // 1. Ensure static _instance is set by calling build()
        final initialBuiltInstance = await SharedPreferencesStorage.build();

        when(mockSharedPreferences.clear()).thenAnswer((_) async => true);

        // 2. Call clear on the test `storage` instance (uses mock, affects
        //    static _instance)
        await storage.clear();

        verify(mockSharedPreferences.clear()).called(1);

        // 3. Verify static _instance was nulled: build() again should create
        //    a new instance.
        final instanceAfterClearAndBuild =
            await SharedPreferencesStorage.build();
        expect(
          identical(initialBuiltInstance, instanceAfterClearAndBuild),
          isFalse,
          reason: 'After clear(), build() should create a new instance as '
              'static _instance was nulled.',
        );
      });

      test('does nothing if storage is closed', () async {
        await storage.close();
        await storage.clear();
        verifyNever(mockSharedPreferences.clear());
      });
    });

    group('close', () {
      test(
          'marks storage as closed (verified by behavior) and resets '
          'static instance', () async {
        final initialBuiltInstance = await SharedPreferencesStorage.build();
        await storage.close();

        // Verify closed by behavior: read should return null and not interact
        // with mock
        expect(storage.read('any_key'), isNull);
        verifyNever(mockSharedPreferences.getString(any));

        // Verify static _instance was nulled: build() again should create a
        // new instance.
        final instanceAfterCloseAndBuild =
            await SharedPreferencesStorage.build();
        expect(
          identical(initialBuiltInstance, instanceAfterCloseAndBuild),
          isFalse,
          reason: 'After close(), build() should create a new instance as '
              'static _instance was nulled.',
        );
      });

      test(
          'can be called multiple times without error and remains '
          'closed', () async {
        await storage.close();
        // Check behavior after first close
        expect(storage.read('key_after_first_close'), isNull);
        verifyNever(mockSharedPreferences.getString('key_after_first_close'));

        await expectLater(storage.close(), completes); // Second call

        // Check behavior after second close
        expect(storage.read('key_after_second_close'), isNull);
        // getString should still not have been called for this key
        verifyNever(mockSharedPreferences.getString('key_after_second_close'));
      });

      test(
          'subsequent operations (write, delete, clear) have no effect '
          'after close', () async {
        await storage.close();

        await storage.write('key_write_closed', 'value');
        verifyNever(mockSharedPreferences.setString(any, any));

        await storage.delete('key_delete_closed');
        verifyNever(mockSharedPreferences.remove(any));

        await storage.clear();
        verifyNever(mockSharedPreferences.clear());
      });
    });
  });
}
