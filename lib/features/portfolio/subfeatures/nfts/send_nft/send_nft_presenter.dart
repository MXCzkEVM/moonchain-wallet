import 'package:datadashwallet/core/core.dart';
import 'package:datadashwallet/features/common/common.dart';
import 'package:datadashwallet/features/wallet/presentation/wallet_page_presenter.dart';
import 'package:datadashwallet/features/token/send_token/choose_crypto/choose_crypto_presenter.dart';
import 'package:flutter/material.dart';
import 'package:mxc_logic/mxc_logic.dart';
import 'package:mxc_ui/mxc_ui.dart';

import 'send_nft_state.dart';
import 'widgets/transaction_dialog.dart';

final sendNftPageContainer =
    PresenterContainerWithParameter<SendNftPresenter, SendNftState, Nft>(
        (nft) => SendNftPresenter(nft));

class SendNftPresenter extends CompletePresenter<SendNftState> {
  SendNftPresenter(this.nft) : super(SendNftState());

  final Nft nft;

  late final ContractUseCase _contractUseCase =
      ref.read(contractUseCaseProvider);
  late final _accountUseCase = ref.read(accountUseCaseProvider);
  late final _nftsUseCase = ref.read(nftsUseCaseProvider);
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

    loadPage();
  }

  void loadPage() async {
    await _contractUseCase.checkConnectionToNetwork();
  }

  void transactionProcess() async {
    final recipient = recipientController.text;
    EstimatedGasFee? estimatedGasFee;

    if (TransactionProcessType.confirm != state.processType) {
      if (TransactionProcessType.send == state.processType) {
        estimatedGasFee = await _estimatedFee();
        notify(() => state.estimatedGasFee = estimatedGasFee);
      }
    }

    final result = await showTransactionDialog(
      context!,
      title: _getDialogTitle(nft.name),
      nft: nft,
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
    final recipient = recipientController.text;

    loading = true;
    try {
      final res = await _contractUseCase.sendTransactionOfNft(
        address: nft.address,
        tokenId: nft.tokenId,
        privateKey: _accountUseCase.getPravateKey()!,
        to: recipient,
      );

      _nftsUseCase.removeItem(nft);
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
  }
}
