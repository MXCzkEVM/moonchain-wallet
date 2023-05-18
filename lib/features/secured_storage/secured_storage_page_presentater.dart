import 'package:datadashwallet/core/core.dart';

final securedStoragePageContainer =
    PresenterContainer<SecuredStoragePagePresenter, void>(() => SecuredStoragePagePresenter());

class SecuredStoragePagePresenter extends CompletePresenter<void> {
  SecuredStoragePagePresenter() : super(null);
}
