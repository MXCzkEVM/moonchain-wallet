import 'package:moonchain_wallet/core/core.dart';
import 'package:mxc_logic/mxc_logic.dart';

import 'custom_tokens_repository.dart';
import 'global_custom_tokens_repository.dart';

class CustomTokensUseCase extends ReactiveUseCase {
  CustomTokensUseCase(this._repository, this._customTokensRepository) {
    mergeCustomTokensRepo();
  }

  final GlobalCustomTokensRepository _repository;
  final CustomTokensRepository _customTokensRepository;

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

  void mergeCustomTokensRepo() {
    print('Trying to merge custom tokens repo with global custom tokens repo');
    print('Custom tokens repo: ${_customTokensRepository.items}');
    print('global custom tokens repo: ${_customTokensRepository.items}');
    for (var element in _customTokensRepository.tokens.value) {
      if (!_repository.items.contains(element)) {
        _repository.addItem(element);
        _customTokensRepository.removeItem(element);
      }
    }
    print('Merged custom tokens repo with global custom tokens repo');
    print('Custom tokens repo: ${_customTokensRepository.items}');
    print('global custom tokens repo: ${_customTokensRepository.items}');
  }
}
