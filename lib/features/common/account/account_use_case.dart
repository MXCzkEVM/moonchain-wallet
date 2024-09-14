import 'package:moonchain_wallet/core/core.dart';
import 'package:moonchain_wallet/features/common/account/account_cache_repository.dart';
import 'package:mxc_logic/mxc_logic.dart';

class AccountUseCase extends ReactiveUseCase {
  AccountUseCase(
    this._repository,
    this._accountCacheRepository,
    this._authenticationStorageRepository,
  );

  final AccountCacheRepository _accountCacheRepository;
  final AuthenticationStorageRepository _authenticationStorageRepository;
  final Web3Repository _repository;

  late final ValueStream<Account?> account =
      reactiveField(_accountCacheRepository.account);
  late final ValueStream<List<Account>> accounts =
      reactiveField(_accountCacheRepository.accounts);

  late final ValueStream<double> xsdConversionRate = reactive(1.0);

  String? getMnemonic() => _authenticationStorageRepository.mnemonic;

  void refresh() {
    update(account, account.value);
    update(accounts, accounts.value);
  }

  void updateAccount(Account item) {
    _accountCacheRepository.updateAccount(item);
    update(account, item);
  }

  void addAccount(Account item, {int? index}) async {
    _accountCacheRepository.addAccount(item, index: index);
    final items = _accountCacheRepository.accountItems;
    update(account, item);
    update(accounts, items);
    getAccountsNames();
  }

  /// Deletes the given account, If the account is selected will select the index 0 account
  /// This is only used to delete the imported accounts.
  void removeAccount(Account item) async {
    _accountCacheRepository.removeAccount(item);
    final items = _accountCacheRepository.accountItems;
    update(accounts, items);
  }

  bool isAccountSelected(Account item) {
    return (item.address == account.value!.address);
  }

  void changeAccount(Account item) {
    update(account, item);
  }

  int findAccountsLastIndex() {
    int lastIndex = 0;
    for (Account account in accounts.value.reversed) {
      if (!account.isCustom) {
        lastIndex = int.parse(account.name);
        break;
      }
    }
    return lastIndex;
  }

  void resetXsdConversionRate(double value) {
    _accountCacheRepository.setXsdConversionRate(value);
    update(xsdConversionRate, value);
  }

  String getXsdUnit() {
    return xsdConversionRate.value == 1.0 ? 'XSD' : '✗';
  }

  void getAccountsNames() async {
    for (Account account in accounts.value) {
      await getAccountMns(account);
    }
    update(accounts, _accountCacheRepository.accountItems);
    update(account, _accountCacheRepository.accountItem);
  }

  Future<bool> getAccountMns(Account item) async {
    try {
      final result = await _repository.tokenContract.getName(item.address);
      item.mns = result;
      _accountCacheRepository.updateAccount(item);
      return true;
    } catch (e) {
      if (e == 'RangeError: Value not in range: 32') {
        // The username is empty
        item.mns = null;
        _accountCacheRepository.updateAccount(item);
        return true;
      } else {
        return false;
      }
    }
  }
}
