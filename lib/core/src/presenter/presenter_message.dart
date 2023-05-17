import 'dart:async';
import 'presenter.dart';

mixin MessagePresenter<TStore> on Presenter<TStore> {
  late final StreamController<String> _messageController =
      StreamController.broadcast();

  Stream<String> get messages => _messageController.stream;

  void addMessage(dynamic message) {
    assert(message != null);
    _messageController.add(message.toString());
    print(message);
  }

  @override
  Future<void> dispose() async {
    super.dispose();
    await _messageController.close();
  }
}
