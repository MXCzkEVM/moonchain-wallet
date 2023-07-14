import 'package:datadashwallet/app/configuration.dart';
import 'package:datadashwallet/core/core.dart';
import 'package:datadashwallet/features/home/apps/apps.dart';
import 'package:flutter/material.dart';
import 'package:wallet_connect/wallet_connect.dart';
import 'package:web3_provider/web3_provider.dart';
import 'package:web3dart/json_rpc.dart';
import 'package:web3dart/web3dart.dart';
import 'package:eth_sig_util/util/utils.dart';
import 'package:http/http.dart';

import 'open_dapp_state.dart';
import 'widgets/js_bridge_bean.dart';
import 'widgets/payment_sheet_page.dart';

final openDAppPageContainer =
    PresenterContainerWithParameter<OpenDAppPresenter, OpenDAppState, DApp>(
        (dapp) => OpenDAppPresenter(dapp));

class OpenDAppPresenter extends CompletePresenter<OpenDAppState> {
  OpenDAppPresenter(this.dapp) : super(OpenDAppState());

  final DApp dapp;

  late final _accountUseCase = ref.read(accountUseCaseProvider);
  late Web3Client _ethClient;

  @override
  void initState() {
    super.initState();

    loadPage();
  }

  @override
  Future<void> dispose() {
    return super.dispose();
  }

  Future<void> loadPage() async {
    _ethClient = Web3Client(Sys.rpcUrl, Client());

    final address = _accountUseCase.getWalletAddress();
    notify(() => state.address = address);
  }

  void onWebViewCreated(InAppWebViewController controller) =>
      notify(() => state.webviewController = controller);

  void showModalConfirm({
    required String from,
    required String to,
    required BigInt value,
    required String fee,
    required VoidCallback confirm,
    required VoidCallback cancel,
  }) {
    showModalBottomSheet(
        context: context!,
        elevation: 0,
        isDismissible: true,
        isScrollControlled: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        builder: (_) {
          return PaymentSheet(
            datas: PaymentSheet.getTransStyleList(
              from: from,
              to: to,
              remark: '',
              fee: "$fee MXC",
            ),
            amount: "${value.tokenString(18)} MXC",
            nextAction: () async {
              confirm.call();
            },
            cancelAction: () {
              cancel.call();
            },
          );
        });
  }

  void signTransaction({
    required BridgeParams bridge,
    required int chainId,
    required VoidCallback cancel,
    required Function(String idHaethClientsh) success,
  }) async {
    final credentials = EthPrivateKey.fromHex(state.address!);
    final sender = EthereumAddress.fromHex(bridge.from ?? '');
    final signto = EthereumAddress.fromHex(bridge.to ?? '');
    final input = hexToBytes(bridge.data ?? '');

    String? price = (bridge.gasPrice == null)
        ? (await _ethClient.getGasPrice()).toString()
        : bridge.gasPrice;

    if (price != null && price.startsWith('EtherAmount:')) {
      price = price.split(' ')[1];
    }

    int? maxGas;
    try {
      maxGas = (bridge.gas ??
          await _ethClient.estimateGas(
            sender: sender,
            to: signto,
            data: input,
          )) as int?;
    } catch (e) {
      RPCError err = e as RPCError;
      cancel.call();
      return;
    }
    String fee = FormatterBalance.configFeeValue(
        beanValue: maxGas.toString(), offsetValue: price.toString());

    showModalConfirm(
        from: state.address!,
        to: bridge.to ?? '',
        value: bridge.value ?? BigInt.zero,
        fee: fee,
        confirm: () async {
          try {
            String result = await _ethClient.sendTransaction(
              credentials,
              Transaction(
                  to: signto,
                  value: EtherAmount.inWei(bridge.value ?? BigInt.zero),
                  gasPrice: null,
                  maxGas: maxGas,
                  data: input),
              chainId: chainId,
              fetchChainIdFromNetworkId: false,
            );
            success.call(result);
          } catch (e) {
            if (e.toString().contains('-32000')) {
              ScaffoldMessenger.of(context!).showSnackBar(const SnackBar(
                content: Text("gasLow"),
              ));
            } else {
              ScaffoldMessenger.of(context!).showSnackBar(SnackBar(
                content: Text(e.toString()),
              ));
            }
          }
        },
        cancel: () {
          cancel.call();
        });
  }

  void changeProgress(int progress) => notify(() => state.progress = progress);
}
