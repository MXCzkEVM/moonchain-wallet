import 'dart:async';

import 'package:flutter/material.dart';
import 'package:mxc_logic/mxc_logic.dart';
import 'package:moonchain_wallet/core/core.dart';

typedef PaginationLoader<T> = Future<ListWithTotal<T>> Function(
    int offset, int limit);

abstract class BasePaginationList<T> {
  int get pageSize;

  bool get isLoading => !_helper.completed;

  @protected
  final BehaviorSubject<ListWithTotal<T>?> _valuesSource =
      BehaviorSubject.seeded(null, sync: true);

  @protected
  final BehaviorSubject<int> _totalSource =
      BehaviorSubject.seeded(0, sync: true);

  ValueStream<ListWithTotal<T>?> get values => _valuesSource.stream;
  ValueStream<int> get total => _totalSource.stream;

  bool _hasDataToLoad = false;
  bool get hasDataToLoad => _hasDataToLoad;

  final _PaginationAsyncHandler<void> _helper = _PaginationAsyncHandler();

  @protected
  Future<ListWithTotal<T>> loadList(int offset, int limit);

  Future<void> _loadPage(IsCancelled isCancelled,
      {bool loadAll = false}) async {
    final currentValues = _valuesSource.valueOrNull ?? <T>[];
    final value = await loadList(currentValues.length, pageSize);
    if (isCancelled()) return;
    currentValues.addAll(value);
    final listWithTotal = currentValues.withTotal(value.total);
    _valuesSource.add(listWithTotal);
    _totalSource.add(value.total);
    _hasDataToLoad = listWithTotal.hasDataToLoad;
  }

  Future<void> loadNextPage() async {
    return _helper.futureOrStartNew(_loadPage);
  }

  /// Loads first page if it's not loaded
  Future<void> loadFirstPage() async {
    if (values.valueOrNull != null) return;
    return _helper.futureOrStartNew(_loadPage);
  }

  Future<void> loadAll() async {
    _helper.cancelCurrent();
    return _helper.futureOrStartNew((c) => _loadPage(c, loadAll: true));
  }

  Future<void> refresh() async {
    _helper.cancelCurrent();
    _valuesSource.add(null);
    _totalSource.add(0);
    return loadFirstPage();
  }

  void updateList(
    ListWithTotal<T> Function(ListWithTotal<T> current) callback,
  ) {
    final currentList = values.value!;
    final newList = callback([...currentList].withTotal(currentList.total));
    _valuesSource.add(newList);
    _totalSource.add(newList.total);
  }

  Future<void> dispose() async {
    _helper.cancelCurrent();
    await _valuesSource.close();
    await _totalSource.close();
  }
}

class PaginationList<T> extends BasePaginationList<T> {
  PaginationList({
    required this.pageSize,
    required PaginationLoader<T> load,
  }) : _load = load;

  final PaginationLoader<T> _load;

  @override
  Future<ListWithTotal<T>> loadList(int offset, int limit) {
    return _load(offset, limit);
  }

  @override
  final int pageSize;
}

extension ListWithTotalExt on ListWithTotal {
  bool get hasDataToLoad => length < total;
}

typedef IsCancelled = bool Function();

/// Helper for pagination list.
/// * Allows to await only 1 future per time
/// * Supports future cancelation via isCanceled param
class _PaginationAsyncHandler<T> {
  Future<T>? _internal;
  CancelationToken? _currentToken;

  bool get completed => _completed;

  bool _completed = true;
  void cancelCurrent() {
    _completed = true;
    _currentToken?.isCancelled = true;
  }

  Future<T>? futureOrStartNew(Future<T> Function(IsCancelled isCancelled) fun) {
    if (_completed) {
      _completed = false;
      _internal = null;
    }
    final token = _currentToken = CancelationToken();
    return _internal ??=
        fun(() => token.isCancelled).whenComplete(() => _completed = true);
  }
}

class CancelationToken {
  bool isCancelled = false;
}
