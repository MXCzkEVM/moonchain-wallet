import 'package:appinio_social_share/appinio_social_share.dart';
import 'package:datadashwallet/core/core.dart';

import 'splash_base_page_state.dart';

abstract class SplashBasePagePresenter<T extends SplashBasePageState>
    extends CompletePresenter<T> {
  SplashBasePagePresenter(T state) : super(state);

  final AppinioSocialShare _socialShare = AppinioSocialShare();

  Future<void> isInstallApps() async {
    final applist = await _socialShare.getInstalledApps();

    notify(() => state.applist = applist);
  }
}
