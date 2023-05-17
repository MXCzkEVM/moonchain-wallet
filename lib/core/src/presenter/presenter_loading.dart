import 'package:rxdart/rxdart.dart';

import 'presenter.dart';

mixin LoadingPresenter<TStore> on Presenter<TStore> {
  final _loadingsController = BehaviorSubject.seeded(false);

  Stream<bool> get loadings => _loadingsController.stream;

  bool get loading => _loadingsController.value;
  set loading(bool v) =>
      _loadingsController.isClosed ? null : _loadingsController.value = v;

  @override
  void dispose() {
    super.dispose();
    _loadingsController.close();
  }
}
