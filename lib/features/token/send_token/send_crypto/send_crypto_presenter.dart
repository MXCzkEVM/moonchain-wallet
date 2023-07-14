import 'package:datadashwallet/core/core.dart';
import 'package:datadashwallet/features/common/common.dart';
import 'package:flutter/material.dart';
import 'package:mxc_logic/mxc_logic.dart';
import 'package:mxc_ui/mxc_ui.dart';

import 'send_crypto_state.dart';

final addTokenPageContainer = PresenterContainerWithParameter<
    SendCryptoPresenter,
    SendCryptoState,
    Token>((token) => SendCryptoPresenter(token));

class SendCryptoPresenter extends CompletePresenter<SendCryptoState> {
  SendCryptoPresenter(this.token) : super(SendCryptoState());

  final Token token;

  late final ContractUseCase _contractUseCase =
      ref.read(contractUseCaseProvider);
  late final TextEditingController amountController = TextEditingController();
  late final TextEditingController recipientController =
      TextEditingController();

  @override
  void initState() {
    super.initState();

    listen(
        _contractUseCase.online, (value) => notify(() => state.online = value));

    loadPage();
  }

  void loadPage() {
    Future.wait([
      _contractUseCase.checkConnectionToNetwork(),
    ]);
  }

  void changeDiscount(int value) {
    amountController.text = ((token.balance ?? 0) * value / 100).toString();
    notify(() => state.discount = value);
  }

  @override
  Future<void> dispose() async {
    super.dispose();
  }
}
