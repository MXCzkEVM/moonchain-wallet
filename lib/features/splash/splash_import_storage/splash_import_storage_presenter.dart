import 'package:datadashwallet/core/core.dart';
import 'package:datadashwallet/features/splash/splash.dart';
import 'package:url_launcher/url_launcher.dart';

import 'splash_import_storage_state.dart';

final splashImportStorageContainer =
    PresenterContainer<SplashImportStoragePresenter, SplashImportStorageState>(
        () => SplashImportStoragePresenter());

class SplashImportStoragePresenter
    extends SplashBasePresenter<SplashImportStorageState> {
  SplashImportStoragePresenter() : super(SplashImportStorageState());

  @override
  void initState() {
    super.initState();

    isInstallApps();
  }

  void openTelegram() async => openUrl('tg://');

  void openWechat() async => openUrl('weixin://');

  void openUrl(String url) async {
    final uri = Uri.parse(url);
    loading = true;

    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      } else {
        throw UnimplementedError('Could not launch $url');
      }
    } catch (error, tackTrace) {
      addError(error, tackTrace);
    } finally {
      loading = false;
    }
  }
}
