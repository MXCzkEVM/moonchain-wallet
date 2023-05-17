import 'package:mxc_logic/mxc_logic.dart';
import 'package:rxdart/rxdart.dart';

class ReactiveController<T> {
  ReactiveController([this._initialValue]);
  final T? _initialValue;

  late final BehaviorSubject<T> _subject = _initialValue == null
      ? BehaviorSubject()
      : BehaviorSubject.seeded(_initialValue as T);

  ValueStream<T> get stream => _subject.stream;

  void save(T o) {
    _subject.add(o);
  }

  Future<void> dispose() async {
    await _subject.close();
  }
}

class ReactiveFieldController<T> implements ReactiveController<T> {
  ReactiveFieldController(this._cacheField);
  final Field<T?> _cacheField;

  @override
  late final BehaviorSubject<T> _subject =
      _cacheField.value == null && null is! T
          ? BehaviorSubject()
          : BehaviorSubject.seeded(_cacheField.value as T);

  @override
  ValueStream<T> get stream => _subject.stream;

  @override
  void save(T o) {
    _subject.add(o);
    _cacheField.value = o;
  }

  @override
  Future<void> dispose() async {
    await _subject.close();
  }

  @override
  get _initialValue => throw UnimplementedError();
}
