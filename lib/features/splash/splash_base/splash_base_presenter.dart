import '../../../common/common.dart';
import '../../../core/core.dart';
import 'package:appinio_social_share/appinio_social_share.dart';
import 'package:flutter_mailer/flutter_mailer.dart';

import 'splash_base_state.dart';

abstract class SplashBasePresenter<T extends SplashBaseState>
    extends CompletePresenter<T> {
  SplashBasePresenter(T state) : super(state);

  final AppinioSocialShare _socialShare = AppinioSocialShare();
  late final _launcherUseCase = ref.read(launcherUseCaseProvider);

  Future<void> isInstallApps() async {
    final applist = await _socialShare.getInstalledApps();

    notify(() => state.applist = applist);
  }

  void checkEmailAppAvailability() async {
    final isEmailAppAvailable = await _launcherUseCase.isEmailAppAvailable();
    notify(() => state.isEmailAppAvailable = isEmailAppAvailable);
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
      notify(() => state.animate = true);
    });
  }
}
