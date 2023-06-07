import 'package:datadashwallet/core/core.dart';
import 'package:datadashwallet/features/home/home.dart';

import 'home_page_state.dart';

final HomePageContainer = PresenterContainer<HomePagePresenter, HomePageState>(() => HomePagePresenter());

class HomePagePresenter extends HomeBasePagePresenter<HomePageState> {

  HomePagePresenter() : super(HomePageState());

  @override
  void initState() {

    super.initState();
  }

}
