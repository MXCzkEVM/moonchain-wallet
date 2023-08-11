import 'package:datadashwallet/core/core.dart';
import 'package:datadashwallet/features/common/common.dart';
import 'package:datadashwallet/features/common/app_nav_bar/app_nav_bar_presenter.dart';
import 'package:datadashwallet/features/portfolio/subfeatures/token/send_token/choose_crypto/choose_crypto_presenter.dart';
import 'package:datadashwallet/features/wallet/wallet.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:mxc_logic/mxc_logic.dart';
import 'package:mxc_ui/mxc_ui.dart';

import 'send_crypto_state.dart';
import 'widgets/transaction_dialog.dart';

class SendCryptoArguments with EquatableMixin {
  const SendCryptoArguments({
    required this.token,
    this.qrCode,
  });

  final Token token;
  final String? qrCode;

  @override
  List<dynamic> get props => [token, qrCode];
}

final sendTokenPageContainer = PresenterContainerWithParameter<
        SendCryptoPresenter, SendCryptoState, SendCryptoArguments>(
    (params) => SendCryptoPresenter(
          params.token,
          params.qrCode,
        ));

class SendCryptoPresenter extends CompletePresenter<SendCryptoState> {
  SendCryptoPresenter(this.token, String? qrCode)
      : super(SendCryptoState()..qrCode = qrCode);

  final Token token;

  late final TokenContractUseCase _tokenContractUseCase =
      ref.read(tokenContractUseCaseProvider);
  late final _accountUseCase = ref.read(accountUseCaseProvider);
  late final _chainConfigurationUserCase =
      ref.read(chainConfigurationUseCaseProvider);
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
      _tokenContractUseCase.online,
      (value) => notify(() => state.online = value),
    );

    listen(_chainConfigurationUserCase.selectedNetwork, (value) {
      if (value != null) {
        notify(() => state.network = value);
      }
    });

    amountController.addListener(_onValidChange);
    recipientController.addListener(_onValidChange);

    recipientController.text = state.qrCode ?? '';

    loadPage();
  }

  void loadPage() async {
    _chainConfigurationUserCase.getCurrentNetwork();
    await _tokenContractUseCase.checkConnectionToNetwork();
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
    estimatedGasFee = await _estimatedFee();
    sumBalance -= estimatedGasFee?.gasFee ?? 0.0;

    final result = await showTransactionDialog(
      context!,
      amount: amount,
      balance: sumBalance.toString(),
      token: token,
      newtork: state.network?.label ?? '--',
      from: state.walletAddress!,
      to: recipient,
      estimatedFee: estimatedGasFee?.gasFee.toString(),
      onTap: (transactionType) => _nextTransactionStep(transactionType),
    );
  }

  Future<String?> _nextTransactionStep(TransactionProcessType type) async {
    if (TransactionProcessType.sending == type) {
      final res = await _sendTransaction();
      if (res != null) {
        ref.read(chooseCryptoPageContainer.actions).loadPage();
        ref.read(walletContainer.actions).initializeWalletPage();
      }
      return res;
    } else if (TransactionProcessType.done == type) {
      BottomFlowDialog.of(context!).close();
    }
  }

  Future<EstimatedGasFee?> _estimatedFee() async {
    final recipient = recipientController.text;

    loading = true;
    try {
      final gasFee = await _tokenContractUseCase.estimateGesFee(
        from: state.walletAddress!,
        to: recipient,
      );
      loading = false;

      return gasFee;
    } catch (e, s) {
      addError(e, s);
    } finally {
      loading = false;
    }
  }

  Future<String?> _sendTransaction() async {
    final amount = amountController.text;
    final recipient = recipientController.text;

    loading = true;
    try {
      final res = await _tokenContractUseCase.sendTransaction(
        privateKey: _accountUseCase.getPravateKey()!,
        to: recipient,
        amount: amount,
      );

      return res;
    } catch (e, s) {
      addError(e, s);
    } finally {
      loading = false;
    }
  }

  @override
  Future<void> dispose() async {
    super.dispose();

    amountController.removeListener(_onValidChange);
    recipientController.removeListener(_onValidChange);
  }
}
