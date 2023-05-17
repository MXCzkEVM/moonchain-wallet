import 'package:meta/meta.dart';
import 'package:mxc_logic/mxc_logic.dart';
import 'package:datadashwallet/core/core.dart';

export 'package:rxdart/rxdart.dart';

class ReactiveUseCase implements Disposable {
  final Map<ValueStream, ReactiveController> _streamToController = {};

  ValueStream<T> reactive<T>([T? value]) {
    final controller = ReactiveController(value);
    final stream = controller.stream;
    _streamToController[stream] = controller;
    return stream;
  }

  ValueStream<T> reactiveField<T>(Field<T?> field) {
    final controller = ReactiveFieldController(field);
    final stream = controller.stream;
    _streamToController[stream] = controller;
    return stream;
  }

  final List<Disposable> _disposables = [];

  T autoDispose<T extends Disposable>(T value) {
    _disposables.add(value);
    return value;
  }

  @protected
  void update<T, T2 extends ValueStream<T?>>(T2 stream, T value) {
    _streamToController[stream]!.save(value);
  }

  @override
  Future<void> dispose() async {
    for (final c in _streamToController.values) {
      await c.dispose();
    }
    for (final d in _disposables) {
      await d.dispose();
    }
  }
}
