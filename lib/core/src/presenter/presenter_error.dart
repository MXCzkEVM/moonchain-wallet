import 'dart:async';
import 'dart:developer';

import 'package:mxc_logic/internal.dart';

import 'presenter.dart';

class ErrorViewModel {
  ErrorViewModel({
    required this.message,
    required this.source,
  });

  final String message;
  final dynamic source;
}

mixin ErrorPresenter<TStore> on Presenter<TStore> {
  late final StreamController<ErrorViewModel> _errorController =
      StreamController.broadcast();

  Stream<ErrorViewModel> get errors => _errorController.stream;

  void addError(dynamic error, [StackTrace? stackTrace]) {
    if (_errorController.isClosed) {
      log('Error captured after dispose!!!');
    } else if (error is TokenExpiredException) {
      log('Error TokenExpiredException');
    } else {
      _errorController.add(ErrorViewModel(
        source: error,
        message: error.toString(),
      ));
    }
    log('Captured error via [addError]', error: error, stackTrace: stackTrace);
  }

  @override
  Future<void> dispose() async {
    super.dispose();
    await _errorController.close();
  }
}
