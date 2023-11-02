import 'package:datadashwallet/common/common.dart';
import 'package:datadashwallet/common/config.dart';
import 'package:datadashwallet/common/utils/utils.dart';
import 'package:datadashwallet/core/core.dart';
import 'package:datadashwallet/features/common/common.dart';
import 'package:datadashwallet/features/common/app_nav_bar/app_nav_bar_presenter.dart';
import 'package:datadashwallet/features/dapps/dapps.dart';
import 'package:web3dart/web3dart.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:mxc_logic/mxc_logic.dart';
import 'package:mxc_ui/mxc_ui.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:web3dart/json_rpc.dart';

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
  List<dynamic> get props => [
        token,
        qrCode,
      ];
}

final sendTokenPageContainer = PresenterContainerWithParameter<
        SendCryptoPresenter, SendCryptoState, SendCryptoArguments>(
    (params) => SendCryptoPresenter(
          params.token,
          params.qrCode,
        ));

class SendCryptoPresenter extends CompletePresenter<SendCryptoState> {
  SendCryptoPresenter(
    this.token,
    String? qrCode,
  ) : super(SendCryptoState()..qrCode = qrCode);

  final Token token;

  late final _transactionHistoryUseCase =
      ref.read(transactionHistoryUseCaseProvider);
  late final TokenContractUseCase _tokenContractUseCase =
      ref.read(tokenContractUseCaseProvider);
  late final _accountUseCase = ref.read(accountUseCaseProvider);
  late final _chainConfigurationUserCase =
      ref.read(chainConfigurationUseCaseProvider);
  late final accountInfo = ref.read(appNavBarContainer.state);
  late final _chainConfigurationUseCase =
      ref.read(chainConfigurationUseCaseProvider);
  late final _errorUseCase = ref.read(errorUseCaseProvider);

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

    amountController.addListener(onAmountChange);
    recipientController.addListener(onRecipientChange);

    recipientController.text = state.qrCode ?? '';
  }

  void loadPage() async {
    await _tokenContractUseCase.checkConnectionToNetwork();
  }

  void changeDiscount(int value) {
    final doubleValue = (token.balance ?? 0) * value / 100;
    final stringAmount = doubleValue.toString();
    final isInvalid = Validation.isDecimalsStandard(stringAmount);

    if (!isInvalid) {
      amountController.text = Formatter.formatToStandardDecimals(stringAmount);
    } else {
      amountController.text = stringAmount;
    }

    notify(() => state.discount = value);
  }

  void checkDiscount() {
    try {
      final discountValue =
          double.parse(amountController.text) * 100 / (token.balance ?? 0);
      notify(() => state.discount = discountValue.round());
    } catch (e) {
      notify(() => state.discount = 0);
    }
  }

  void onAmountChange() {
    if (amountController.text != '') {
      checkDiscount();
      validateAndUpdate();
    } else {
      notify(() => state.discount = 0);
    }
  }

  void onRecipientChange() {
    validateAndUpdate();
  }

  void validateAndUpdate() {
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
      addError(translate('unregistered_mns_notice'));
      return;
    }

    double sumBalance = token.balance! - double.parse(amount);
    EstimatedGasFee? estimatedGasFee = await _estimatedFee(recipientAddress);
    if (estimatedGasFee != null) {
      sumBalance -= estimatedGasFee.gasFee;
      final estimatedFee =
          Validation.isExpoNumber(estimatedGasFee.gasFee.toString())
              ? '0.000'
              : estimatedGasFee.gasFee.toString();

      final maxFeeDouble = estimatedGasFee.gasFee * Config.priority;
      final maxFeeString = maxFeeDouble.toString();
      final maxFee =
          Validation.isExpoNumber(maxFeeString) ? '0.000' : maxFeeString;

      final result = await showTransactionDialog(context!,
          amount: amount,
          balance: sumBalance.toString(),
          token: token,
          network: state.network?.label ?? '--',
          from: state.account!.address,
          to: recipient,
          estimatedFee: estimatedFee,
          maxFee: maxFee,
          onTap: (transactionType) =>
              _nextTransactionStep(transactionType, estimatedGasFee),
          networkSymbol: state.network?.symbol ?? '--');
    }
  }

  String? checkAmountCeiling() {
    final amount = amountController.text;

    if (double.parse(amount) > token.balance!) {
      return translate('insufficient_balance');
    }
    return null;
  }

  Future<String?> _nextTransactionStep(
      TransactionProcessType type, EstimatedGasFee estimatedGasFee) async {
    if (TransactionProcessType.sending == type) {
      final res = await _sendTransaction(estimatedGasFee);
      if (res != null) {
        // Unnecessary on MXC chains wince we have websocket
        // ref.read(chooseCryptoPageContainer.actions).loadPage();
        // ref.read(walletContainer.actions).initializeWalletPage();
      }
      return res;
    } else if (TransactionProcessType.done == type) {
      navigator!.pop();
      Future.delayed(const Duration(milliseconds: 200), () {
        navigator?.popUntil((route) {
          return route.settings.name?.contains('WalletPage') ?? false;
        });
      });
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
      callErrorHandler(e, s);
    } finally {
      loading = false;
    }
  }

  Future<String?> _sendTransaction(EstimatedGasFee estimatedGasFee) async {
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
          tokenAddress: token.address,
          estimatedGasFee: estimatedGasFee);

      if (!Config.isMxcChains(state.network!.chainId)) {
        final tx = TransactionModel(
            hash: res,
            status: TransactionStatus.pending,
            type: TransactionType.sent,
            value: amount.getValueInUnitBI(EtherUnit.wei).toString(),
            token: token,
            timeStamp: DateTime.now());

        _transactionHistoryUseCase.updateItem(
          tx,
        );

        _transactionHistoryUseCase.spyOnTransaction(
          tx,
        );
      }

      return res;
    } catch (e, s) {
      if (BottomFlowDialog.maybeOf(context!) != null) {
        BottomFlowDialog.of(context!).close();
      }
      callErrorHandler(e, s);
    } finally {
      loading = false;
    }
  }

  void callErrorHandler(dynamic e, StackTrace s) {
    final isHandled = _errorUseCase.handleError(context!, e, onL3Tap: () {
      final chainId = state.network!.chainId;
      final l3BridgeUri = Urls.networkL3Bridge(chainId);
      Navigator.of(context!).push(route.featureDialog(
        maintainState: false,
        OpenAppPage(
          url: l3BridgeUri,
        ),
      ));
    });
    if (!isHandled) {
      addError(e, s);
    }
  }

  @override
  Future<void> dispose() async {
    super.dispose();

    amountController.removeListener(onAmountChange);
    recipientController.removeListener(onRecipientChange);
  }
}
