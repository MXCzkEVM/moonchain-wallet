// import 'splash_base_presenter_abstraction.dart' as abstract_presenter;
import '../../../core/core.dart';
import 'package:appinio_social_share/appinio_social_share.dart';
import 'package:datadashwallet/core/core.dart';
import 'package:flutter_mailer/flutter_mailer.dart';

import 'splash_base_state.dart';

abstract class SplashBasePresenter<T extends SplashBaseState>
    extends CompletePresenter<T> {
  SplashBasePresenter(T state) : super(state);

  final AppinioSocialShare _socialShare = AppinioSocialShare();

  Future<void> isInstallApps() async {
    final applist = await _socialShare.getInstalledApps();

    notify(() => state.applist = applist);
  }

  Future<void> isInstallEmail() async {
    final result = await FlutterMailer.canSendMail() ||
        await FlutterMailer.isAppInstalled('mailto:');

    notify(() => state.isInstallEmail = result);
  }
}

final splashBaseContainer =
    PresenterContainer<SplashBasePresenter, SplashBaseState>(
        () => SplashBasePresenterClass());

class SplashBasePresenterClass extends SplashBasePresenter<SplashBaseState> {
  SplashBasePresenterClass() : super(SplashBaseState());

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 800), () {
      notify(() => state.showLogo = true);
    });
  }
}
