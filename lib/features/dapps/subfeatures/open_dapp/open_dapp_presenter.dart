import 'package:datadashwallet/common/common.dart';
import 'package:datadashwallet/core/core.dart';
import 'package:datadashwallet/features/dapps/subfeatures/open_dapp/widgets/swtich_network_dialog.dart';
import 'package:flutter/services.dart';
import 'package:mxc_logic/mxc_logic.dart';
import 'package:web3_provider/web3_provider.dart';
import 'package:web3dart/web3dart.dart';
import 'package:eth_sig_util/util/utils.dart';

import 'open_dapp_state.dart';
import 'widgets/bridge_params.dart';
import 'widgets/transaction_dialog.dart';

final openDAppPageContainer =
    PresenterContainer<OpenDAppPresenter, OpenDAppState>(
        () => OpenDAppPresenter());

class OpenDAppPresenter extends CompletePresenter<OpenDAppState> {
  OpenDAppPresenter() : super(OpenDAppState());

  late final _chainConfigurationUseCase =
      ref.read(chainConfigurationUseCaseProvider);
  late final _tokenContractUseCase = ref.read(tokenContractUseCaseProvider);
  late final _accountUseCase = ref.read(accountUseCaseProvider);

  @override
  void initState() {
    super.initState();

    listen(
      _accountUseCase.account,
      (value) {
        notify(() => state.account = value);
      },
    );

    listen(_chainConfigurationUseCase.selectedNetwork, (value) {
      if (value != null) {
        notify(() => state.network = value);
      }
    });
  }

  @override
  Future<void> dispose() {
    return super.dispose();
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
      String to, EtherAmount amount, Uint8List? data,
      {String? from}) async {
    loading = true;
    try {
      final res = await _tokenContractUseCase.sendTransaction(
        privateKey: state.account!.privateKey,
        to: to,
        from: from,
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
    final amount = amountEther.getValueInUnit(EtherUnit.ether).toString();
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
            '${gasFee?.getInWei != null ? gasFee!.getValueInUnit(EtherUnit.ether) : (estimatedGasFee?.gasFee ?? 0)}',
      );

      if (result != null && result) {
        final hash = await _sendTransaction(bridge.to!, amountEther, bridgeData,
            from: bridge.from);
        if (hash != null) success.call(hash);
      } else {
        cancel.call();
      }
    } catch (e, s) {
      cancel.call();
      addError(e, s);
    }
  }

  void addEthereumChain(dynamic id, Map<dynamic, dynamic> params) {
    final rawChainId = params["object"]["chainId"] as String;
    final chainId = Formatter.hexToDecimal(rawChainId);
    final networks = _chainConfigurationUseCase.networks.value;
    final foundChainIdIndex =
        networks.indexWhere((element) => element.chainId == chainId);

    if (foundChainIdIndex != -1) {
      final foundNetwork = networks[foundChainIdIndex];
      showSwitchNetworkDialog(context!,
          fromNetwork: state.network!.label ?? state.network!.web3RpcHttpUrl,
          toNetwork: foundNetwork.label ?? foundNetwork.web3RpcHttpUrl,
          onTap: () {
        switchNetwork(id, foundNetwork, rawChainId);
      });
    } else {
      addError(translate('network_not_found'));
    }
  }

  void changeProgress(int progress) => notify(() => state.progress = progress);

  void setAddress(dynamic id) {
    if (state.account != null) {
      final walletAddress = state.account!.address;
      state.webviewController?.setAddress(walletAddress, id);
    }
  }

  void switchNetwork(dynamic id, Network toNetwork, String rawChainId) {
    // "{"id":1692336424091,"name":"switchEthereumChain","object":{"chainId":"0x66eed"},"network":"ethereum"}"
    _chainConfigurationUseCase.switchDefaultNetwork(toNetwork);
    notify(() => state.network = toNetwork);
    state.webviewController?.sendResult(rawChainId, id);
  }
}
