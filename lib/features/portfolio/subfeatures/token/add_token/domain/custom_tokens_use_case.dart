import 'package:moonchain_wallet/core/core.dart';
import 'package:moonchain_wallet/features/common/common.dart';
import 'package:mxc_logic/mxc_logic.dart';

import 'custom_tokens_repository_temp.dart';
import 'custom_tokens_repository.dart';

class CustomTokensUseCase extends ReactiveUseCase {
  CustomTokensUseCase(this._repository, this._customTokensRepositoryTemp, this._accountUseCase)
      : super() {
    initCustomTokensRepoListener();
  }

  final GlobalCustomTokensRepository _repository;
  final CustomTokensRepository _customTokensRepositoryTemp;
  final AccountUseCase _accountUseCase;

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
    print('Custom tokens repo: ${_customTokensRepositoryTemp.items}');
    print('global custom tokens repo: ${_repository.items}');
    for (var element in _customTokensRepositoryTemp.tokens.value) {
      if (!_repository.items.contains(element)) {
        _repository.addItem(element);
        _customTokensRepositoryTemp.removeItem(element);
      } else {
        _customTokensRepositoryTemp.removeItem(element);
      }
    }
    print('Merged custom tokens repo with global custom tokens repo');
    print('Custom tokens repo: ${_customTokensRepositoryTemp.items}');
    print('global custom tokens repo: ${_repository.items}');
  }

  void initCustomTokensRepoListener() {
    _accountUseCase.account.listen((event) {
      mergeCustomTokensRepo();
    });
  }
}
