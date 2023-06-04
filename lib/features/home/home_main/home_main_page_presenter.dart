import 'package:datadashwallet/core/core.dart';
import 'package:datadashwallet/features/home/home.dart';

import 'home_main_page_state.dart';

final homeMainPageContainer = PresenterContainer<HomeMainPagePresenter, HomeMainPageState>(() => HomeMainPagePresenter());

class HomeMainPagePresenter extends HomeBasePagePresenter<HomeMainPageState> {
  HomeMainPagePresenter() : super(HomeMainPageState());

  @override
  void initState() {
    super.initState();
  }
}
