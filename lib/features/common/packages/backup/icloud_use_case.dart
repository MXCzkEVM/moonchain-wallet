import 'package:mxc_logic/mxc_logic.dart';
import 'package:moonchain_wallet/core/core.dart';

class ICloudUseCase extends ReactiveUseCase {
  ICloudUseCase(
    this._repository,
  );

  final Web3Repository _repository;

  Future<void> uploadBackup(String mnemonic) async =>
      _repository.iCloudRepository.uploadBackup(mnemonic);

  Future<String> readBackupFile() async =>
      _repository.iCloudRepository.readBackupFile();
}
