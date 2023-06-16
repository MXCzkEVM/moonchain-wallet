import 'package:datadashwallet/core/core.dart';
import 'package:datadashwallet/features/home/home.dart';

import 'home_page_state.dart';

final homeContainer =
    PresenterContainer<HomePresenter, HomeState>(() => HomePresenter());

class HomePresenter extends CompletePresenter<HomeState> {
  HomePresenter() : super(HomeState());

  changeIndex(newIndex) {
    notify(() => state.currentIndex = newIndex);
  }
}



// final homeContainer = PresenterContainer<HomePresenter, HomeState>(() => HomePresenter(HomeState()));

// class HomePresenter extends HomePresenter<HomeState> {
//   late final _homeUseCase = ref.read(homeUseCaseProvider);
//   HomePresenter() : super(HomeState());

//   @override
//   void initState() {
//     _homeUseCase.getRecentTransactions();
//     super.initState();
//   }

// }
