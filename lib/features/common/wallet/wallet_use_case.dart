import 'package:datadashwallet/core/core.dart';
import 'package:mxc_logic/mxc_logic.dart';
import 'package:web3dart/web3dart.dart';

class WalletUseCase extends ReactiveUseCase {
  WalletUseCase(this._repository);

  final ApiRepository _repository;

  late final ValueStream<String> publicAddress = reactive('');

  String generateMnemonic() {
    return _repository.address.generateMnemonic();
  }

  Future<bool> setupFromMnemonic(String mnemonic) async {
    return await _repository.address.setupFromMnemonic(mnemonic);
  }

  Future<EthereumAddress?> getPublicAddress() async {
    final res = _repository.address.getLocalstoragePublicAddress();
    update(publicAddress, res!.hex);

    return res;
  }

  String? getPrivateKey() => _repository.address.getLocalstoragePrivateKey();

  void reset() => _repository.address.reset();

  bool validateMnemonic(String mnemonic) =>
      _repository.address.validateMnemonic(mnemonic);
}
