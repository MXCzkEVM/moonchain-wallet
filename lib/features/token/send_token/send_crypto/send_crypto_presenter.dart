import 'package:datadashwallet/core/core.dart';
import 'package:datadashwallet/features/common/common.dart';
import 'package:flutter/material.dart';
import 'package:mxc_ui/mxc_ui.dart';

import 'send_crypto_state.dart';

final addTokenPageContainer =
    PresenterContainer<SendCryptoPresenter, SendCryptoState>(
        () => SendCryptoPresenter());

class SendCryptoPresenter extends CompletePresenter<SendCryptoState> {
  SendCryptoPresenter() : super(SendCryptoState());

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

  @override
  Future<void> dispose() async {
    super.dispose();
  }
}
