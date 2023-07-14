import 'package:datadashwallet/core/core.dart';
import 'package:datadashwallet/features/common/account/account_cache_repository.dart';
import 'package:mxc_logic/mxc_logic.dart';

class AccountUseCase extends ReactiveUseCase {
  AccountUseCase(
    this._authenticationStorageRepository,
    this._accountCacheRepository,
  );

  final AuthenticationStorageRepository _authenticationStorageRepository;
  final AccountCacheRepository _accountCacheRepository;

  late final ValueStream<String?> walletAddress =
      reactiveField(_accountCacheRepository.publicAddress);
  late final ValueStream<String?> walletPrivate =
      reactiveField(_accountCacheRepository.privateKey);

  void refreshWallet() {
    final publicAddress = _authenticationStorageRepository.publicAddress;
    final privateKey = _authenticationStorageRepository.privateKey;

    update(walletAddress, publicAddress);
    update(walletPrivate, privateKey);
  }

  String? getWalletAddress() => _authenticationStorageRepository.publicAddress;

  String? getPravateKey() => _authenticationStorageRepository.privateKey;
}
