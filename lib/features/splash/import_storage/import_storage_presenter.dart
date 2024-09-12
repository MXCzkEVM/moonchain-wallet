import 'package:moonchain_wallet/core/core.dart';
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

  late final _launcherUseCase = ref.read(launcherUseCaseProvider);
  late final _directoryUseCase = ref.read(directoryUseCaseProvider);

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
}
