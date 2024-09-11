import 'package:moonchain_wallet/core/core.dart';
import 'package:moonchain_wallet/features/common/common.dart';
import 'package:moonchain_wallet/features/portfolio/subfeatures/token/add_token/domain/custom_tokens_use_case.dart';
import 'package:flutter/material.dart';
import 'package:mxc_ui/mxc_ui.dart';

import 'add_token_state.dart';

final addTokenPageContainer =
    PresenterContainer<AddTokenPresenter, AddTokenState>(
        () => AddTokenPresenter());

class AddTokenPresenter extends CompletePresenter<AddTokenState> {
  AddTokenPresenter() : super(AddTokenState());

  late final TokenContractUseCase _tokenContractUseCase =
      ref.read(tokenContractUseCaseProvider);
  late final CustomTokensUseCase _customTokensUseCase =
      ref.read(customTokensUseCaseProvider);
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
      final token = await _tokenContractUseCase.getToken(value);
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
