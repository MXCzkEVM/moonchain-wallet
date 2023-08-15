import 'package:datadashwallet/core/core.dart';
import 'package:flutter/services.dart';
import 'package:mxc_logic/mxc_logic.dart';
import 'package:web3_provider/web3_provider.dart';
import 'package:web3dart/web3dart.dart';
import 'package:eth_sig_util/util/utils.dart';

import '../../entities/bookmark.dart';
import 'open_dapp_state.dart';
import 'widgets/bridge_params.dart';
import 'widgets/transaction_dialog.dart';

final openDAppPageContainer =
    PresenterContainerWithParameter<OpenDAppPresenter, OpenDAppState, Bookmark>(
        (bookmark) => OpenDAppPresenter(bookmark));

class OpenDAppPresenter extends CompletePresenter<OpenDAppState> {
  OpenDAppPresenter(this.bookmark) : super(OpenDAppState());

  final Bookmark bookmark;

  late final _chainConfigurationUserCase =
      ref.read(chainConfigurationUseCaseProvider);
  late final _tokenContractUseCase = ref.read(tokenContractUseCaseProvider);
  late final _accountUseCase = ref.read(accountUseCaseProvider);

  @override
  void initState() {
    super.initState();

    listen(_chainConfigurationUserCase.selectedNetwork, (value) {
      if (value != null) {
        notify(() => state.network = value);
      }
    });

    loadPage();
  }

  @override
  Future<void> dispose() {
    return super.dispose();
  }

  Future<void> loadPage() async {
    _chainConfigurationUserCase.getCurrentNetwork();

    final address = _accountUseCase.getWalletAddress();
    notify(() => state.wallletAddress = address);
  }

  void onWebViewCreated(InAppWebViewController controller) =>
      notify(() => state.webviewController = controller);

  Future<EstimatedGasFee?> _estimatedFee(
    String from,
    String to,
    EtherAmount? gasPrice,
    Uint8List? data,
  ) async {
    loading = true;
    try {
      final gasFee = await _tokenContractUseCase.estimateGesFee(
        from: from,
        to: to,
        gasPrice: gasPrice,
        data: data,
      );
      loading = false;

      return gasFee;
    } catch (e, s) {
      addError(e, s);
    } finally {
      loading = false;
    }
  }

  Future<String?> _sendTransaction(
    String to,
    String amount,
    Uint8List? data,
  ) async {
    loading = true;
    try {
      final res = await _tokenContractUseCase.sendTransaction(
        privateKey: _accountUseCase.getPravateKey()!,
        to: to,
        amount: amount,
        data: data,
      );

      return res;
    } catch (e, s) {
      addError(e, s);
    } finally {
      loading = false;
    }
  }

  void signTransaction({
    required BridgeParams bridge,
    required VoidCallback cancel,
    required Function(String idHaethClientsh) success,
  }) async {
    final amountEther = EtherAmount.inWei(bridge.value ?? BigInt.zero);
    final amount =
        '${MxcAmount.toDoubleByEther(amountEther.getInWei.toString())}';
    final bridgeData = hexToBytes(bridge.data ?? '');
    EtherAmount? gasPrice;
    EtherAmount? gasFee;
    EstimatedGasFee? estimatedGasFee;

    if (bridge.gasPrice != null) {
      gasPrice = EtherAmount.fromBase10String(EtherUnit.wei, bridge.gasPrice!);
    }

    if (bridge.gas != null) {
      gasPrice = gasPrice ?? await _tokenContractUseCase.getGasPrice();
      gasFee = EtherAmount.fromBigInt(EtherUnit.wei,
          gasPrice.getInWei * BigInt.parse(bridge.gas.toString()));
    } else {
      estimatedGasFee = await _estimatedFee(
        bridge.from!,
        bridge.to!,
        gasPrice,
        bridgeData,
      );

      if (estimatedGasFee == null) {
        cancel.call();
        return;
      }
    }

    try {
      final result = await showTransactionDialog(
        context!,
        title: translate('confirm_transaction')!,
        amount: amount,
        from: bridge.from!,
        to: bridge.to!,
        estimatedFee:
            '${gasFee?.getInWei != null ? MxcAmount.toDoubleByEther(gasFee!.getInWei.toString()) : (estimatedGasFee?.gasFee ?? 0)}',
      );

      if (result != null && result) {
        final hash = await _sendTransaction(
          bridge.to!,
          amount,
          bridgeData,
        );
        success.call(hash!);
      } else {
        cancel.call();
      }
    } catch (e, s) {
      cancel.call();
      addError(e, s);
    }
  }

  void changeProgress(int progress) => notify(() => state.progress = progress);
}
