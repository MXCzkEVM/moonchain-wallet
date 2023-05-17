abstract class Wrapped<T> {
  const Wrapped._();

  const factory Wrapped(T value) = ResultWrapped;

  const factory Wrapped.pending() = LoadingWrapped;

  T? get valueOrNull => map(
        error: (_, __, v) => v,
        loading: (v) => v,
        value: (v) => v,
      );

  TRes map<TRes>({
    required TRes Function(T value) value,
    required TRes Function(T? previousValue) loading,
    required TRes Function(Object, StackTrace, T? previousValue) error,
  });

  Wrapped<TRes> wrapMap<TRes>(TRes Function(T) mapper);

  Wrapped<T> withValue(T value) => ResultWrapped(
        value,
      );

  Wrapped<T> withLoading() => map(
        value: (v) => LoadingWrapped(previousValue: v),
        loading: (v) => LoadingWrapped(previousValue: v),
        error: (_, __, v) => LoadingWrapped(previousValue: v),
      );

  Wrapped<T> withError(Object error, [StackTrace? stackTrace]) => map(
        value: (v) => ErrorWrapped(
          error,
          stackTrace ?? StackTrace.current,
          previousValue: v,
        ),
        loading: (v) => ErrorWrapped(
          error,
          stackTrace ?? StackTrace.current,
          previousValue: v,
        ),
        error: (_, __, v) => ErrorWrapped(
          error,
          stackTrace ?? StackTrace.current,
          previousValue: v,
        ),
      );
}

class ResultWrapped<T> extends Wrapped<T> {
  const ResultWrapped(this.value) : super._();
  final T value;

  @override
  TRes map<TRes>({
    required TRes Function(T value) value,
    required TRes Function(T? previousValue) loading,
    required TRes Function(Object, StackTrace, T? previousValue) error,
  }) =>
      value(this.value);

  @override
  Wrapped<TRes> wrapMap<TRes>(TRes Function(T) mapper) {
    return ResultWrapped<TRes>(mapper(value));
  }
}

class LoadingWrapped<T> extends Wrapped<T> {
  const LoadingWrapped({this.previousValue}) : super._();
  final T? previousValue;

  @override
  TRes map<TRes>({
    required TRes Function(T value) value,
    required TRes Function(T? previousValue) loading,
    required TRes Function(Object, StackTrace, T? previousValue) error,
  }) =>
      loading(previousValue);

  @override
  Wrapped<TRes> wrapMap<TRes>(TRes Function(T) mapper) {
    return LoadingWrapped<TRes>(
      previousValue: previousValue == null ? null : mapper(previousValue as T),
    );
  }
}

class ErrorWrapped<T> extends Wrapped<T> {
  const ErrorWrapped(this.error, this.stackTrace, {this.previousValue})
      : super._();
  final T? previousValue;

  final Object error;
  final StackTrace stackTrace;

  @override
  TRes map<TRes>({
    required TRes Function(T value) value,
    required TRes Function(T? previousValue) loading,
    required TRes Function(Object, StackTrace, T? previousValue) error,
  }) =>
      error(this.error, stackTrace, previousValue);

  @override
  Wrapped<TRes> wrapMap<TRes>(TRes Function(T) mapper) {
    return ErrorWrapped<TRes>(
      error,
      stackTrace,
      previousValue: previousValue == null ? null : mapper(previousValue as T),
    );
  }
}
