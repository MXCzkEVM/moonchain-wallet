import 'dart:async';
import 'dart:collection';

import 'package:meta/meta.dart';
import 'package:state_notifier/state_notifier.dart';

class _ListenerEntry<T> extends LinkedListEntry<_ListenerEntry<T>> {
  _ListenerEntry(this.listener);

  final Listener<T> listener;
}

class MutableNotifierListenerError extends Error {
  MutableNotifierListenerError._(
    this.errors,
    this.stackTraces,
    this.stateNotifier,
  ) : assert(
          errors.length == stackTraces.length,
          'errors and stackTraces must match',
        );

  /// A map of all the errors and their stacktraces thrown by listeners.
  final List<Object> errors;

  /// The stacktraces associated with [errors].
  final List<StackTrace?> stackTraces;

  /// The [StateNotifier] that failed to update its state.
  final StateNotifier<Object?> stateNotifier;

  @override
  String toString() {
    final buffer = StringBuffer();

    for (var i = 0; i < errors.length; i++) {
      final error = errors[i];
      final stackTrace = stackTraces[i];

      buffer
        ..writeln(error)
        ..writeln(stackTrace);
    }

    return '''
At least listener of the StateNotifier $stateNotifier threw an exception
when the notifier tried to update its state.

The exceptions thrown are:

$buffer
''';
  }
}

class MutableNotifier<T> implements StateNotifier<T> {
  MutableNotifier(this._state);

  final _listeners = LinkedList<_ListenerEntry<T>>();

  @override
  ErrorListener? onError;

  bool _mounted = true;

  @override
  bool get mounted => _mounted;

  StreamController<T>? _controller;

  @override
  Stream<T> get stream {
    _controller ??= StreamController<T>.broadcast();
    return _controller!.stream;
  }

  bool _debugCanAddListeners = true;

  bool _debugSetCanAddListeners(bool value) {
    assert(() {
      _debugCanAddListeners = value;
      return true;
    }(), '');
    return true;
  }

  bool _debugIsMounted() {
    assert(() {
      if (!_mounted) {
        throw StateError('''
Tried to use $runtimeType after `dispose` was called.

Consider checking `mounted`.
''');
      }
      return true;
    }(), '');
    return true;
  }

  T _state;

  /// The current "state" of this [StateNotifier].
  ///
  /// Updating this variable will synchronously call all the listeners.
  /// Notifying the listeners is O(N) with N the number of listeners.
  ///
  /// Updating the state will throw if at least one listener throws.
  @override
  @protected
  T get state {
    assert(_debugIsMounted(), '');
    return _state;
  }

  int? _previousHash;

  @override
  @protected
  set state(T value) {
    assert(_debugIsMounted(), '');
    if (_state.hashCode == value.hashCode) {
      return;
    }

    _state = value;
    notify();
  }

  void notify([void Function()? fun]) {
    fun?.call();
    if (!mounted) return;
    if (_previousHash == state.hashCode) return;
    _previousHash = state.hashCode;
    _controller?.add(_state);
    final errors = <Object>[];
    final stackTraces = <StackTrace?>[];
    for (final listenerEntry in _listeners) {
      try {
        listenerEntry.listener(_state);
      } catch (error, stackTrace) {
        errors.add(error);
        stackTraces.add(stackTrace);

        if (onError != null) {
          onError!(error, stackTrace);
        } else {
          Zone.current.handleUncaughtError(error, stackTrace);
        }
      }
    }
    if (errors.isNotEmpty) {
      throw MutableNotifierListenerError._(errors, stackTraces, this);
    }
  }

  @override
  T get debugState {
    late T result;
    assert(() {
      result = _state;
      return true;
    }(), '');
    return result;
  }

  @override
  bool get hasListeners {
    assert(_debugIsMounted(), '');
    return _listeners.isNotEmpty;
  }

  @override
  RemoveListener addListener(
    Listener<T> listener, {
    bool fireImmediately = true,
  }) {
    assert(() {
      if (!_debugCanAddListeners) {
        throw ConcurrentModificationError();
      }
      return true;
    }(), '');
    assert(_debugIsMounted(), '');
    final listenerEntry = _ListenerEntry(listener);
    _listeners.add(listenerEntry);
    try {
      assert(_debugSetCanAddListeners(false), '');
      if (fireImmediately) {
        listener(state);
      }
    } catch (err, stack) {
      listenerEntry.unlink();
      onError?.call(err, stack);
      rethrow;
    } finally {
      assert(_debugSetCanAddListeners(true), '');
    }

    return () {
      if (listenerEntry.list != null) {
        listenerEntry.unlink();
      }
    };
  }

  @override
  @mustCallSuper
  void dispose() {
    assert(_debugIsMounted(), '');
    _listeners.clear();
    _controller?.close();
    _mounted = false;
  }

  @override
  bool updateShouldNotify(T old, T current) => true;
}
