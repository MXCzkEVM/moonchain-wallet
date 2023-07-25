import 'package:datadashwallet/core/core.dart';
import 'package:datadashwallet/features/common/common.dart';
import 'package:datadashwallet/features/common/app_nav_bar/app_nav_bar_presenter.dart';
import 'package:datadashwallet/features/token/send_token/choose_crypto/choose_crypto_presenter.dart';
import 'package:datadashwallet/features/wallet/wallet.dart';
import 'package:flutter/material.dart';
import 'package:mxc_logic/mxc_logic.dart';
import 'package:mxc_ui/mxc_ui.dart';

import 'send_crypto_state.dart';
import 'widgets/transaction_dialog.dart';

final sendTokenPageContainer = PresenterContainerWithParameter<
    SendCryptoPresenter,
    SendCryptoState,
    Token>((token) => SendCryptoPresenter(token));

class SendCryptoPresenter extends CompletePresenter<SendCryptoState> {
  SendCryptoPresenter(this.token) : super(SendCryptoState());

  final Token token;

  late final ContractUseCase _contractUseCase =
      ref.read(contractUseCaseProvider);
  late final _accountUseCase = ref.read(accountUseCaseProvider);
  late final accountInfo = ref.read(appNavBarContainer.state);
  late final TextEditingController amountController = TextEditingController();
  late final TextEditingController recipientController =
      TextEditingController();

  @override
  void initState() {
    super.initState();

    listen(
      _accountUseCase.walletAddress,
      (value) => notify(() => state.walletAddress = value),
    );

    listen(
      _contractUseCase.online,
      (value) => notify(() => state.online = value),
    );

    amountController.addListener(_onValidChange);
    recipientController.addListener(_onValidChange);

    loadPage();
  }

  void loadPage() async {
    await _contractUseCase.checkConnectionToNetwork();
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

  void transactionProcess() async {
    final amount = amountController.text;
    final recipient = recipientController.text;
    EstimatedGasFee? estimatedGasFee;

    double sumBalance = token.balance! - double.parse(amount);

    if (TransactionProcessType.confirm != state.processType) {
      if (TransactionProcessType.send == state.processType) {
        estimatedGasFee = await _estimatedFee();
        notify(() => state.estimatedGasFee = estimatedGasFee);
      }
      sumBalance -= state.estimatedGasFee?.gasFee ?? 0.0;
    }

    final result = await showTransactionDialog(
      context!,
      title: _getDialogTitle(token.name ?? ''),
      amount: amount,
      balance: sumBalance.toString(),
      token: token,
      newtork: 'MXC zkEVM',
      from: state.walletAddress!,
      to: recipient,
      processType: state.processType,
      estimatedFee: state.estimatedGasFee?.gasFee.toString(),
      onTap: _nextTransactionStep,
    );

    if (result != null && !result) {
      notify(() => state.processType = TransactionProcessType.confirm);
    }
  }

  String _getDialogTitle(String tokenName) {
    if (TransactionProcessType.confirm == state.processType) {
      return translate('confirm_transaction')!;
    } else {
      return translate('send_x')!.replaceFirst('{0}', tokenName);
    }
  }

  void _nextTransactionStep() async {
    if (TransactionProcessType.confirm == state.processType) {
      notify(() => state.processType = TransactionProcessType.send);
      Future.delayed(const Duration(milliseconds: 300), transactionProcess);
    } else if (TransactionProcessType.send == state.processType) {
      _sendTransaction();
    } else {
      notify(() => state.processType = TransactionProcessType.confirm);
      BottomFlowDialog.of(context!).close();

      ref.read(chooseCryptoPageContainer.actions).loadPage();
      ref.read(walletContainer.actions).initializeWalletPage();
    }
  }

  Future<EstimatedGasFee?> _estimatedFee() async {
    final recipient = recipientController.text;

    loading = true;
    try {
      final gasFee = await _contractUseCase.estimateGesFee(
        from: state.walletAddress!,
        to: recipient,
      );
      loading = false;

      return gasFee;
    } catch (e, s) {
      notify(() => state.processType = TransactionProcessType.confirm);
      addError(e, s);
    } finally {
      loading = false;
    }
  }

  void _sendTransaction() async {
    final amount = amountController.text;
    final recipient = recipientController.text;

    loading = true;
    try {
      final res = await _contractUseCase.sendTransaction(
        privateKey: _accountUseCase.getPravateKey()!,
        to: recipient,
        amount: amount,
      );

      print(res);
      notify(() => state.processType = TransactionProcessType.done);
      transactionProcess();
    } catch (e, s) {
      notify(() => state.processType = TransactionProcessType.confirm);
      addError(e, s);
    } finally {
      loading = false;
    }
  }

  @override
  Future<void> dispose() async {
    super.dispose();

    amountController.removeListener(_onValidChange);
  }
}
