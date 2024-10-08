import 'package:google_sign_in/google_sign_in.dart';
import 'package:mxc_logic/mxc_logic.dart';
import 'package:moonchain_wallet/core/core.dart';

class GoogleDriveUseCase extends ReactiveUseCase {
  GoogleDriveUseCase(
    this._repository,
  );

  final Web3Repository _repository;
  Map<String, String>? _googleAuthHeaders;

  Future<bool> initGoogleDriveAccess() async {
    final googleAuthHeaders = await singInToGoogleDrive();

    if (googleAuthHeaders == null) {
      return false;
    }

    _googleAuthHeaders = googleAuthHeaders;

    return true;
  }

  Future<Map<String, String>?> singInToGoogleDrive() async {
    final googleAuthData = await GoogleSignIn(
      scopes: [
        'email',
        'https://www.googleapis.com/auth/drive.file',
      ],
    ).signIn();

    final authHeaders = await googleAuthData?.authHeaders;

    return authHeaders;
  }

  Future<void> uploadBackup(String mnemonic) async =>
      _repository.googleDriveRepository.uploadBackup(mnemonic, _googleAuthHeaders);

  Future<String> readBackupFile() async =>
      _repository.googleDriveRepository.readBackupFile(_googleAuthHeaders);
}
