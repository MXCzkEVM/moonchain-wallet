import 'package:datadashwallet/core/core.dart';
import 'package:datadashwallet/features/settings/subfeatures/recipient/entities/recipient.dart';
import 'package:flutter/material.dart';
import 'package:mxc_ui/mxc_ui.dart';

import 'add_recipient_state.dart';

final addRecipientPageContainer =
    PresenterContainer<AddRecipientPresenter, AddRecipientState>(
        () => AddRecipientPresenter());

class AddRecipientPresenter extends CompletePresenter<AddRecipientState> {
  AddRecipientPresenter() : super(AddRecipientState());

  late final _recipientsUseCase = ref.read(recipientsCaseProvider);
  late final TextEditingController nameController = TextEditingController();
  late final TextEditingController addressController = TextEditingController();

  @override
  Future<void> dispose() async {
    super.dispose();
  }

  void onValidChange(bool value) {
    notify(() => state.valid = value);
  }

  Future<void> onSave() async {
    loading = true;
    try {
      final data = Recipient(
        id: DateTime.now().microsecondsSinceEpoch,
        name: nameController.text,
      );

      final addressOrMns = addressController.text;

      if (addressOrMns.startsWith('0x')) {
        data.address = addressOrMns;
      } else {
        data.mns = addressOrMns;
      }

      _recipientsUseCase.addItem(data);

      BottomFlowDialog.of(context!).close();
    } catch (error, stackTrace) {
      addError(error, stackTrace);
    } finally {
      loading = false;
    }
  }
}
