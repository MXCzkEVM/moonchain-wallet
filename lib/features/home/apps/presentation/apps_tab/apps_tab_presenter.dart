import 'package:datadashwallet/core/core.dart';
import 'package:datadashwallet/features/home/home.dart';

import 'apps_tab_state.dart';

final appsTabPageContainer =
    PresenterContainer<AppsTabPresenter, AppsTabPageState>(
        () => AppsTabPresenter());

class AppsTabPresenter extends HomeBasePagePresenter<AppsTabPageState> {
  AppsTabPresenter() : super(AppsTabPageState());

  @override
  void initState() {
    super.initState();
  }
}
