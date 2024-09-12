import 'package:moonchain_wallet/core/core.dart';

import '../entities/recipient.dart';
import 'recipients_repository.dart';

class RecipientsUseCase extends ReactiveUseCase {
  RecipientsUseCase(this._repository);

  final RecipientsRepository _repository;

  late final ValueStream<List<Recipient>> recipients =
      reactiveField(_repository.recipients);

  List<Recipient> getRecipients() => _repository.items;

  void addItem(Recipient item) {
    _repository.addItem(item);
    update(recipients, _repository.items);
  }

  void updateItem(Recipient item) {
    _repository.updateItem(item);
    update(recipients, _repository.items);
  }

  void removeItem(Recipient item) {
    _repository.removeItem(item);
    update(recipients, _repository.items);
  }
}
