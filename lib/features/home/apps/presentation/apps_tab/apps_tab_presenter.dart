import 'package:datadashwallet/core/core.dart';

import 'apps_tab_state.dart';

final appsTabPageContainer =
    PresenterContainer<AppsTabPresenter, AppsTabPageState>(
        () => AppsTabPresenter());

class AppsTabPresenter extends CompletePresenter<AppsTabPageState> {
  AppsTabPresenter() : super(AppsTabPageState());

  @override
  void initState() {
    super.initState();
  }
}
