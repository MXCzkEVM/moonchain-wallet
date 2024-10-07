import 'package:moonchain_wallet/core/core.dart';
import 'package:moonchain_wallet/features/security/security.dart';
import 'package:moonchain_wallet/features/splash/splash.dart';
import 'package:mxc_logic/mxc_logic.dart';
import 'package:open_file_manager/open_file_manager.dart';
import 'package:open_mail_app/open_mail_app.dart';

final splashImportStorageContainer =
    PresenterContainer<SplashImportStoragePresenter, SplashBaseState>(
        () => SplashImportStoragePresenter());

class SplashImportStoragePresenter
    extends SplashBasePresenter<SplashBaseState> {
  SplashImportStoragePresenter() : super(SplashBaseState());

  late final _authUseCase = ref.read(authUseCaseProvider);
  late final _accountUseCase = ref.read(accountUseCaseProvider);
  late final _launcherUseCase = ref.read(launcherUseCaseProvider);
  late final _directoryUseCase = ref.read(directoryUseCaseProvider);
  late final _googleDriveUseCase = ref.read(googleDriveUseCaseProvider);
  late final _iCloudUseCase = ref.read(iCloudUseCaseProvider);

  @override
  void initState() {
    super.initState();

    isInstallApps();
  }

  void openTelegram() => openUrl(_launcherUseCase.openTelegram);

  void openWechat() => openUrl(_launcherUseCase.openWeChat);

  void openEmail() async {
    try {
      final result = await OpenMailApp.openMailApp();

      if (!result.didOpen && !result.canOpen) {
        throw Exception('Could not find any mail app.');
      }
    } catch (error, tackTrace) {
      addError(error, tackTrace);
    }
  }

  void openUrl(Function launcherFunction) async {
    loading = true;

    try {
      launcherFunction();
    } catch (error, tackTrace) {
      addError(error, tackTrace);
    } finally {
      loading = false;
    }
  }

  Future<void> openLocalSeedPhrase() async {
    const selectedFolderType = FolderType.download;

    await _directoryUseCase.checkDownloadsDirectoryDirectory();

    await openFileManager(
      androidConfig: AndroidConfig(
        folderType: selectedFolderType,
      ),
      iosConfig: IosConfig(
        subFolderPath: 'Downloads',
      ),
    );
  }

  Future<void> loadBackupFromGoogleDrive() async {
    loading = true;
    // Trying to pass the auth headers to google drive use case for further api calls
    final hasGoogleDriveAccess =
        await _googleDriveUseCase.initGoogleDriveAccess();

    if (!hasGoogleDriveAccess) {
      addError(translate('unable_to_authenticate_with_x')!
          .replaceFirst('{0}', translate('google_drive')!));
    }

    try {
      final mnemonic = await _googleDriveUseCase.readBackupFile();

      if (mnemonic.isNotEmpty) {
        if (_authUseCase.validateMnemonic(mnemonic)) {
          final account = await _authUseCase.addAccount(mnemonic);
          _accountUseCase.addAccount(account);

          pushSetupEnableBiometricPage(context!);
        } else {
          throw UnimplementedError('Mnemonic format is invalid.');
        }
      } else {
        throw UnimplementedError('Mnemonic file is empty or not exists.');
      }
    } catch (error, stackTrace) {
      addError(error, stackTrace);
    } finally {
      loading = false;
    }
  }

  Future<void> loadBackupFromICloud() async {
    loading = true;

    try {
      final mnemonic = await _iCloudUseCase.readBackupFile();

      if (mnemonic.isNotEmpty) {
        if (_authUseCase.validateMnemonic(mnemonic)) {
          final account = await _authUseCase.addAccount(mnemonic);
          _accountUseCase.addAccount(account);

          pushSetupEnableBiometricPage(context!);
        } else {
          throw UnimplementedError('Mnemonic format is invalid.');
        }
      } else {
        throw UnimplementedError('Mnemonic file is empty or not exists.');
      }
    } catch (error, stackTrace) {
      addError(error, stackTrace);
    } finally {
      loading = false;
    }
  }
}
