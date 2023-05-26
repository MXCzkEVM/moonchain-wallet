import 'package:datadashwallet/core/core.dart';

import 'splash_base_page_state.dart';

abstract class SplashBasePagePresenter<T extends SplashBasePageState>
    extends CompletePresenter<T> {
  SplashBasePagePresenter(T state) : super(state);

}
