import 'package:datadashwallet/core/core.dart';
import 'package:datadashwallet/features/common/common.dart';
import 'package:datadashwallet/features/home/app_nav_bar/app_nav_bar_presenter.dart';
import 'package:flutter/material.dart';
import 'package:mxc_logic/mxc_logic.dart';

import 'send_crypto_state.dart';
import 'widgets/transaction_dialog.dart';

final addTokenPageContainer = PresenterContainerWithParameter<
    SendCryptoPresenter,
    SendCryptoState,
    Token>((token) => SendCryptoPresenter(token));

class SendCryptoPresenter extends CompletePresenter<SendCryptoState> {
  SendCryptoPresenter(this.token) : super(SendCryptoState());

  final Token token;

  late final ContractUseCase _contractUseCase =
      ref.read(contractUseCaseProvider);
  late final accountInfo = ref.read(appNavBarContainer.state);
  late final TextEditingController amountController = TextEditingController();
  late final TextEditingController recipientController =
      TextEditingController();

  @override
  void initState() {
    super.initState();

    listen(
      _contractUseCase.online,
      (value) => notify(() => state.online = value),
    );

    amountController.addListener(_onValidChange);
    recipientController.addListener(_onValidChange);

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

  void _onValidChange() {
    final result =
        amountController.text.isNotEmpty && recipientController.text.isNotEmpty;
    notify(() => state.valid = result);
  }

  void transactionProcess() {
    final amount = amountController.text;
    final recipient = recipientController.text;

    showTransactionDialog(
      context!,
      title: 'confirm_transaction',
      amount: amount,
      balance: '${token.balance! - double.parse(amount)}',
      token: token,
      newtork: 'MXC zkEVM',
      from: accountInfo.currentAccount,
      to: recipient,
      processType: state.processType,
      onTap: _nextTransactionStep,
    );
  }

  void _nextTransactionStep() async {
    if (TransactionProcessType.confirm == state.processType) {
      notify(() => state.processType = TransactionProcessType.send);
      Future.delayed(const Duration(seconds: 1),transactionProcess);
    } else if (TransactionProcessType.send == state.processType) {
      notify(() => state.processType = TransactionProcessType.done);
    } else {
      notify(() => state.processType = TransactionProcessType.confirm);
    }
  }

  @override
  Future<void> dispose() async {
    super.dispose();

    amountController.removeListener(_onValidChange);
  }
}
