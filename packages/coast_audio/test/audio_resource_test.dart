import 'package:coast_audio/coast_audio.dart';
import 'package:test/test.dart';

var _disposedIds = <int>[];

class MockAudioResource with AudioResourceMixin {
  MockAudioResource.noFinalizer();
  MockAudioResource.setFinalizer() {
    setResourceFinalizer(() {
      _disposedIds.add(resourceId);
    });
  }
}

void main() {
  group('AudioResourceManager', () {
    test('dispose should return true when the resource has finalizer', () {
      final resource = MockAudioResource.setFinalizer();
      final id = resource.resourceId;
      expect(AudioResourceManager.dispose(id), isTrue);
    });

    test('dispose should return false when the resource has no finalizer', () {
      final resource = MockAudioResource.noFinalizer();
      final id = resource.resourceId;
      expect(AudioResourceManager.dispose(id), isFalse);
    });
  });

  group('AudioResourceMixin', () {
    test('isDisposed returns true when the resource is disposed', () {
      final resource = MockAudioResource.setFinalizer();
      final id = resource.resourceId;
      AudioResourceManager.dispose(id);
      expect(resource.isDisposed, isTrue);
    });

    test('isDisposed returns false when the resource is not disposed', () {
      final resourceWithFinalizer = MockAudioResource.setFinalizer();
      expect(resourceWithFinalizer.isDisposed, isFalse);

      final resourceWithNoFinalizer = MockAudioResource.noFinalizer();
      expect(resourceWithNoFinalizer.isDisposed, isFalse);
    });

    test('dispose should call the finalizer', () {
      final resource = MockAudioResource.setFinalizer();
      final id = resource.resourceId;
      AudioResourceManager.dispose(id);
      expect(_disposedIds, contains(id));
    });

    test('throwIfDisposed should throw an AudioResourceDisposedException when the resource is disposed', () {
      final resource = MockAudioResource.setFinalizer();
      final id = resource.resourceId;
      AudioResourceManager.dispose(id);
      expect(() => resource.throwIfDisposed(), throwsA(isA<AudioResourceDisposedException>()));
    });

    test('throwIfDisposed should not throw an AudioResourceDisposedException when the resource is not disposed', () {
      final resourceWithFinalizer = MockAudioResource.setFinalizer();
      expect(() => resourceWithFinalizer.throwIfDisposed(), returnsNormally);

      final resourceWithNoFinalizer = MockAudioResource.noFinalizer();
      expect(() => resourceWithNoFinalizer.throwIfDisposed(), returnsNormally);
    });
  });
}
