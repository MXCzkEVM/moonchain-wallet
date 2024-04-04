import 'package:datadashwallet/core/core.dart';
import 'package:datadashwallet/features/settings/subfeatures/address_book/entities/recipient.dart';
import 'package:flutter/material.dart';
import 'package:mxc_ui/mxc_ui.dart';
import 'package:mxc_logic/mxc_logic.dart';

import 'edit_recipient_state.dart';

final editRecipientContainer = PresenterContainerWithParameter<
    EditRecipientPresenter,
    EditRecipientState,
    Recipient?>((recipient) => EditRecipientPresenter(recipient));

class EditRecipientPresenter extends CompletePresenter<EditRecipientState> {
  EditRecipientPresenter(this.recipient) : super(EditRecipientState());

  final Recipient? recipient;

  late final _recipientsUseCase = ref.read(recipientsCaseProvider);
  late final _tokenContractUseCase = ref.read(tokenContractUseCaseProvider);
  late final TextEditingController nameController = TextEditingController();
  late final TextEditingController addressController = TextEditingController();

  @override
  void initState() {
    super.initState();

    nameController.addListener(_onValidChange);
    addressController.addListener(_onValidChange);

    nameController.text = recipient?.name ?? '';
    addressController.text = recipient?.address ?? recipient?.mns ?? '';
  }

  @override
  Future<void> dispose() async {
    super.dispose();

    nameController.removeListener(_onValidChange);
    addressController.removeListener(_onValidChange);
  }

  void _onValidChange() {
    final result =
        nameController.text.isNotEmpty && addressController.text.isNotEmpty;
    notify(() => state.valid = result);
  }

  Future<void> onSave() async {
    loading = true;
    resetValidation();
    try {
      final response = await checkMnsAvailability();
      if (response) {
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

        if (recipient?.id != null) {
          data.id = recipient!.id;
          _recipientsUseCase.updateItem(data);
          navigator?.pop();
        } else {
          _recipientsUseCase.addItem(data);
          BottomFlowDialog.of(context!).close();
        }
      } else {
        notify(() => state.errorText = translate('invalid_format'));
      }
    } catch (error, stackTrace) {
      addError(error, stackTrace);
    } finally {
      loading = false;
    }
  }

  void deleteRecipient(Recipient item) {
    _recipientsUseCase.removeItem(item);
    navigator?.pop();
  }

  Future<bool> checkMnsAvailability() async {
    final mnsToCheck = addressController.text;
    if (!mnsToCheck.startsWith('0x')) {
      final result = await _tokenContractUseCase.getAddress(mnsToCheck);
      if (result == ContractAddresses.zeroAddress) {
        return false;
      } else {
        return true;
      }
    } else {
      return true;
    }
  }

  void resetValidation() {
    notify(() => state.errorText = null);
  }
}
