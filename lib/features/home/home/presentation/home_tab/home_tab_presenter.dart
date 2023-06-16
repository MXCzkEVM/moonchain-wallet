import 'package:datadashwallet/core/core.dart';

import 'home_tab_state.dart';

final homeTabContainer = PresenterContainer<HomeTabPresenter, HomeTabState>(
    () => HomeTabPresenter());

class HomeTabPresenter extends CompletePresenter<HomeTabState> {
  HomeTabPresenter() : super(HomeTabState());

  @override
  void initState() {
    super.initState();
  }
}
