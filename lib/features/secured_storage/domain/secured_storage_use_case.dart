import 'package:datadashwallet/core/core.dart';
import 'package:mxc_logic/mxc_logic.dart';

class WalletUseCase extends ReactiveUseCase {
  WalletUseCase(this._repository);

  final ApiRepository _repository;

  String generateMnemonic() {
    return _repository.address.generateMnemonic();
  }

  
}
