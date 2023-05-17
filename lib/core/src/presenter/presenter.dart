import 'dart:async';

import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../core.dart';
import '../notifier.dart';

void _loadPresenter(Presenter presenter) {
  final initState = presenter.initState;
  if (initState is Future) {
    throw Exception(
      'InitState must be sync function and not Future, otherwise it can lead to unexpected behavior',
    );
  }
  initState();
  presenter._initialized = true;
  presenter.notify();
}

class PresenterContainer<TPresenter extends Presenter<TStore>, TStore> {
  /// If [keepAlive] = false (by default), the presenter and its state will be
  /// destroyed when it's not used.
  PresenterContainer(this._presenterBuilder, {bool keepAlive = false})
      : _keepAlive = keepAlive;

  final TPresenter Function() _presenterBuilder;
  final bool _keepAlive;

  late final DisposablePresenterProvider<TPresenter, TStore> state =
      DisposablePresenterProvider((ref) {
    ref.maintainState = _keepAlive;
    final presenter = _presenterBuilder();
    presenter._ref = ref;
    _loadPresenter(presenter);
    return presenter;
  });

  ProviderBase<TPresenter> get actions => state.notifier;
}

class PresenterContainerWithParameter<TPresenter extends Presenter<TStore>,
    TStore, TArg> {
  /// If [keepAlive] = false (by default), the presenter and its state will be
  /// destroyed when it's not used.
  PresenterContainerWithParameter(this._presenterBuilder,
      {bool keepAlive = false})
      : _keepAlive = keepAlive;

  final TPresenter Function(TArg arg) _presenterBuilder;
  final bool _keepAlive;

  late final DisposablePresenterFamilyProvider<TPresenter, TStore, TArg> state =
      DisposablePresenterFamilyProvider((ref, arg) {
    ref.maintainState = _keepAlive;
    final presenter = _presenterBuilder(arg);
    presenter._ref = ref;
    _loadPresenter(presenter);
    return presenter;
  });

  ProviderBase<TPresenter> actions(TArg arg) => state(arg).notifier;
}

abstract class Presenter<TStore> extends MutableNotifier<TStore> {
  Presenter(TStore state) : super(state);

  late final Ref _ref;
  Ref get ref => _ref;

  final List<TextEditingController> _controllers = [];

  TextEditingController useTextEditingController() {
    final controller = TextEditingController();
    _controllers.add(controller);
    return controller;
  }

  final List<StreamSubscription> _listenables = [];

  StreamSubscription<void> listen<T>(
    Stream<T> stream,
    void Function(T) onData,
  ) {
    late final StreamSubscription<void> res;
    if (stream is ValueStream<T> && stream.hasValue) {
      onData(stream.value);
      res = stream.skip(1).listen(onData);
      _listenables.add(res);
    } else {
      res = stream.listen(onData);
      _listenables.add(res);
    }
    return res;
  }

  bool _initialized = false;

  @mustCallSuper
  void initState() {}

  @override
  void notify([void Function()? fun]) {
    if (!_initialized) {
      fun?.call();
      return;
    }
    super.notify(fun);
  }

  @override
  FutureOr<void> dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    for (final l in _listenables) {
      l.cancel();
    }
    super.dispose();
  }
}

abstract class CompletePresenter<TStore> extends Presenter<TStore>
    with LoadingPresenter, ErrorPresenter, MessagePresenter, ContextPresenter {
  CompletePresenter(TStore state) : super(state);
}
