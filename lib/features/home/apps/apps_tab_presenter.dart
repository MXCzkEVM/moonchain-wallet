import 'package:datadashwallet/core/core.dart';
import 'package:datadashwallet/features/home/home.dart';

import 'apps_tab_state.dart';

final appsTabPageContainer = PresenterContainer<AppsTabPagePresenter, AppsTabPageState>(() => AppsTabPagePresenter());

class AppsTabPagePresenter extends CompletePresenter<AppsTabPageState> {
  AppsTabPagePresenter() : super(AppsTabPageState());

  @override
  void initState() {
    super.initState();
  }
}
