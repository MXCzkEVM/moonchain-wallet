import 'package:datadashwallet/core/core.dart';
import 'package:datadashwallet/features/splash/splash.dart';
import 'package:url_launcher/url_launcher.dart';

import 'splash_import_storage_page_state.dart';

final splashImportStoragePageContainer = PresenterContainer<
    SplashImportStoragePagePresenter,
    SplashImportStoragePageState>(() => SplashImportStoragePagePresenter());

class SplashImportStoragePagePresenter
    extends SplashBasePagePresenter<SplashImportStoragePageState> {
  SplashImportStoragePagePresenter() : super(SplashImportStoragePageState());

  @override
  void initState() {
    super.initState();

    isInstallApps();
  }

  void openTelegram() async => openUrl('tg://');

  void openWechat() async => openUrl('weixin://');

  void openUrl(String url) async {
    final uri = Uri.parse(url);

    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      } else {
        throw UnimplementedError('Could not launch $url');
      }
    } catch (error, tackTrace) {
      onError!(error, tackTrace);
    }
  }
}
