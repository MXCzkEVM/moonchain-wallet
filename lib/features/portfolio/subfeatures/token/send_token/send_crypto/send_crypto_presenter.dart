import 'package:datadashwallet/common/config.dart';
import 'package:datadashwallet/common/utils/utils.dart';
import 'package:datadashwallet/core/core.dart';
import 'package:datadashwallet/features/common/common.dart';
import 'package:datadashwallet/features/common/app_nav_bar/app_nav_bar_presenter.dart';
import 'package:web3dart/web3dart.dart';
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

  late final _transactionHistoryUseCase =
      ref.read(transactionHistoryUseCaseProvider);
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
      _accountUseCase.account,
      (value) {
        notify(() => state.account = value);
        loadPage();
      },
    );

    listen(
      _tokenContractUseCase.online,
      (value) => notify(() => state.online = value),
    );

    listen(_chainConfigurationUserCase.selectedNetwork, (value) {
      if (value != null) {
        notify(() => state.network = value);
        loadPage();
      }
    });

    amountController.addListener(onValidChange);
    recipientController.addListener(onValidChange);

    recipientController.text = state.qrCode ?? '';
  }

  void loadPage() async {
    await _tokenContractUseCase.checkConnectionToNetwork();
  }

  void changeDiscount(int value) {
    amountController.text = ((token.balance ?? 0) * value / 100).toString();
    notify(() => state.discount = value);
  }

  void onValidChange() {
    final result = state.formKey.currentState!.validate();
    notify(() => state.valid = result);
  }

  Future<String> getAddress(String recipient) async {
    if (!recipient.toLowerCase().startsWith('0x')) {
      return await _tokenContractUseCase.getAddress(recipient);
    }

    return recipient;
  }

  void transactionProcess() async {
    final amount = amountController.text;
    final recipient = recipientController.text;
    String recipientAddress = await getAddress(recipient);

    if (recipientAddress == Config.zeroAddress) {
      notify(() => state.recipientError = translate('invalid_format'));
      return;
    }

    EstimatedGasFee? estimatedGasFee;

    double sumBalance = token.balance! - double.parse(amount);
    estimatedGasFee = await _estimatedFee(recipientAddress);
    sumBalance -= estimatedGasFee?.gasFee ?? 0.0;
    final estimatedFee = estimatedGasFee == null
        ? '--'
        : Validation.isExpoNumber(estimatedGasFee.gasFee.toString())
            ? '0.000'
            : estimatedGasFee.gasFee.toString();

    final result = await showTransactionDialog(context!,
        amount: amount,
        balance: sumBalance.toString(),
        token: token,
        newtork: state.network?.label ?? '--',
        from: state.account!.address,
        to: recipient,
        estimatedFee: estimatedFee,
        onTap: (transactionType) => _nextTransactionStep(transactionType),
        networkSymbol: state.network?.symbol ?? '--');
  }

  Future<String?> _nextTransactionStep(TransactionProcessType type) async {
    if (TransactionProcessType.sending == type) {
      final res = await _sendTransaction();
      if (res != null) {
        // Unnecessary on MXC chains wince we have websocket
        // ref.read(chooseCryptoPageContainer.actions).loadPage();
        // ref.read(walletContainer.actions).initializeWalletPage();
      }
      return res;
    } else if (TransactionProcessType.done == type) {
      BottomFlowDialog.of(context!).close();
    }
  }

  Future<EstimatedGasFee?> _estimatedFee(String recipient) async {
    loading = true;
    try {
      final gasFee = await _tokenContractUseCase.estimateGesFee(
        from: state.account!.address,
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
    final amountDouble = double.parse(amountController.text);
    final amount = MxcAmount.fromDoubleByEther(amountDouble);
    final recipient = recipientController.text;

    loading = true;
    try {
      String recipientAddress = await getAddress(recipient);

      final res = await _tokenContractUseCase.sendTransaction(
          privateKey: state.account!.privateKey,
          to: recipientAddress,
          amount: amount,
          tokenAddress: token.address);

      if (!Config.isMxcChains(state.network!.chainId)) {
        final tx = TransactionModel(
            hash: res,
            status: TransactionStatus.pending,
            type: TransactionType.sent,
            value: amount.getValueInUnit(EtherUnit.wei).toString(),
            token: token,
            timeStamp: DateTime.now());

        _transactionHistoryUseCase.updateItemTx(tx, state.network!.chainId);

        _transactionHistoryUseCase.spyOnTransaction(tx, state.network!.chainId);
      }

      return res;
    } catch (e, s) {
      addError(e, s);
    } finally {
      loading = false;
    }
  }

  void resetRecipientError() {
    notify(() => state.recipientError = null);
  }

  @override
  Future<void> dispose() async {
    super.dispose();

    amountController.removeListener(onValidChange);
    recipientController.removeListener(onValidChange);
  }
}
