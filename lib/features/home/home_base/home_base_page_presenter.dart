import 'package:datadashwallet/core/core.dart';

import 'home_base_page_state.dart';

abstract class HomeBasePagePresenter<T extends HomeBasePageState>
    extends CompletePresenter<T> {
  HomeBasePagePresenter(T state) : super(state);

}
