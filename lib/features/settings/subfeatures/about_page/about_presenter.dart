import 'package:datadashwallet/core/core.dart';
import 'about_state.dart';

final aboutContainer =
    PresenterContainer<AboutPresenter, AboutState>(() => AboutPresenter());

class AboutPresenter extends CompletePresenter<AboutState> {
  AboutPresenter() : super(AboutState());

  @override
  void initState() {
    super.initState();
  }

  @override
  Future<void> dispose() async {
    super.dispose();
  }

}
