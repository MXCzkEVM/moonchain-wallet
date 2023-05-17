import 'package:datadashwallet/core/core.dart';

final loginPageContainer =
    PresenterContainer<LoginPagePresenter, void>(() => LoginPagePresenter());

class LoginPagePresenter extends CompletePresenter<void> {
  LoginPagePresenter() : super(null);
}
