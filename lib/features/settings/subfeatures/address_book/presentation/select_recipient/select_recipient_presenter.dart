import 'package:moonchain_wallet/core/core.dart';
import 'package:mxc_ui/mxc_ui.dart';

import 'select_recipient_state.dart';

final addTokenPageContainer =
    PresenterContainer<SelectRecipientPresenter, SelectRecipientState>(
        () => SelectRecipientPresenter());

class SelectRecipientPresenter extends CompletePresenter<SelectRecipientState> {
  SelectRecipientPresenter() : super(SelectRecipientState());

  late final _recipientsUseCase = ref.read(recipientsCaseProvider);

  @override
  void initState() {
    super.initState();

    listen(_recipientsUseCase.recipients,
        (value) => notify(() => state.recipients = value));

    loadPage();
  }

  @override
  Future<void> dispose() async {
    super.dispose();
  }

  void loadPage() {
    _recipientsUseCase.getRecipients();
  }

  void onChanged(String value) async {
    loading = true;

    try {} catch (error, stackTrace) {
      addError(error, stackTrace);
    } finally {
      loading = false;
    }
  }

  Future<void> onSave() async {
    loading = true;
    try {
      BottomFlowDialog.of(context!).close();
    } catch (error, stackTrace) {
      addError(error, stackTrace);
    } finally {
      loading = false;
    }
  }
}
