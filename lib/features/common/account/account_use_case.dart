import 'package:datadashwallet/core/core.dart';
import 'package:datadashwallet/features/common/account/account_cache_repository.dart';
import 'package:mxc_logic/mxc_logic.dart';

class AccountUseCase extends ReactiveUseCase {
  AccountUseCase(
    this._accountCacheRepository,
    this._authenticationStorageRepository,
  );

  final AccountCacheRepository _accountCacheRepository;
  final AuthenticationStorageRepository _authenticationStorageRepository;

  late final ValueStream<Account?> account =
      reactiveField(_accountCacheRepository.account);
  late final ValueStream<List<Account>> accounts =
      reactiveField(_accountCacheRepository.accounts);

  late final ValueStream<String?> walletAddress =
      reactiveField(_accountCacheRepository.publicAddress);
  late final ValueStream<String?> walletPrivateKey =
      reactiveField(_accountCacheRepository.privateKey);

  late final ValueStream<double> xsdConversionRate = reactive(2.0);

  String? getMnemonic() => _authenticationStorageRepository.mnemonic;
  String? getWalletAddress() => _authenticationStorageRepository.publicAddress;
  String? getPravateKey() => _authenticationStorageRepository.privateKey;

  void updateAccount(Account item) {
    _accountCacheRepository.updateAccount(item);
    update(account, item);
  }

  void addAccount(Account item) async {
    _accountCacheRepository.addAccount(item);
    final items = _accountCacheRepository.accountItems;
    update(account, item);
    update(accounts, items);
  }

  void changeAccount(Account item) {
    update(account, item);
  }

  void resetXsdConversionRate(double value) {
    _accountCacheRepository.setXsdConversionRate(value);
    update(xsdConversionRate, value);
  }

  String getXsdUnit() {
    return xsdConversionRate.value == 1.0 ? 'XSD' : '✗';
  }
}
