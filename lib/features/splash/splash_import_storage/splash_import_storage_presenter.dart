import 'package:datadashwallet/core/core.dart';
import 'package:datadashwallet/features/splash/splash.dart';
import 'package:url_launcher/url_launcher.dart';

final splashImportStorageContainer =
    PresenterContainer<SplashImportStoragePresenter, SplashBaseState>(
        () => SplashImportStoragePresenter());

class SplashImportStoragePresenter
    extends SplashBasePresenter<SplashBaseState> {
  SplashImportStoragePresenter() : super(SplashBaseState());

  @override
  void initState() {
    super.initState();

    isInstallApps();
  }

  void openTelegram() async => openUrl('tg://');

  void openWechat() async => openUrl('weixin://');

  void openEmail() async => openUrl('mail:');

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