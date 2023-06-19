import 'package:datadashwallet/core/core.dart';

import 'edit_apps_state.dart';

final editAppsPageContainerv =
    PresenterContainer<EditAppsPresenter, EditAppsPageState>(
        () => EditAppsPresenter());

class EditAppsPresenter extends CompletePresenter<EditAppsPageState> {
  EditAppsPresenter() : super(EditAppsPageState());

  @override
  void initState() {
    super.initState();
  }
}
