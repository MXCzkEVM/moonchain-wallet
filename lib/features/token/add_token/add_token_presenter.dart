import 'package:datadashwallet/core/core.dart';
import 'package:datadashwallet/features/common/common.dart';
import 'package:datadashwallet/features/token/add_token/domain/custom_tokens_use_case.dart';
import 'package:flutter/material.dart';
import 'package:mxc_ui/mxc_ui.dart';

import 'add_token_state.dart';

final addTokenPageContainer =
    PresenterContainer<AddTokenPresenter, AddTokenPageState>(
        () => AddTokenPresenter());

class AddTokenPresenter extends CompletePresenter<AddTokenPageState> {
  AddTokenPresenter() : super(AddTokenPageState());

  late final ContractUseCase _contractUseCase =
      ref.read(contractUseCaseProvider);
  late final CustomTokensUseCase _customTokensUseCase =
      ref.read(customTokensCaseProvider);
  late final TextEditingController addressController = TextEditingController();
  late final TextEditingController symbolController = TextEditingController();
  late final TextEditingController decimalController = TextEditingController();

  @override
  Future<void> dispose() async {
    super.dispose();
  }

  void onChanged(String value) async {
    loading = true;

    try {
      final token = await _contractUseCase.getToken(value);
      state.token = token;
      symbolController.text = token!.symbol ?? '';
      decimalController.text = token.decimals.toString();
    } catch (error, stackTrace) {
      addError(error, stackTrace);
    } finally {
      loading = false;
    }
  }

  Future<void> onSave() async {
    loading = true;
    try {
      _customTokensUseCase.addItem(state.token!);
      BottomFlowDialog.of(context!).close();
    } catch (error, stackTrace) {
      addError(error, stackTrace);
    } finally {
      loading = false;
    }
  }
}
