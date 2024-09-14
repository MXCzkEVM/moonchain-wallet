import 'package:moonchain_wallet/core/core.dart';
import 'package:mxc_logic/mxc_logic.dart';

import 'custom_tokens_repository.dart';

class CustomTokensUseCase extends ReactiveUseCase {
  CustomTokensUseCase(this._repository);

  final CustomTokensRepository _repository;

  late final ValueStream<List<Token>> tokens =
      reactiveField(_repository.tokens);

  List<Token> getTokens() => _repository.items;

  void addItem(Token item) {
    _repository.addItem(item);
    update(tokens, _repository.items);
  }

  void removeItem(Token item) {
    _repository.removeItem(item);
    update(tokens, _repository.items);
  }

  void removeAll() {
    _repository.removeAll();
    update(tokens, _repository.items);
  }
}
