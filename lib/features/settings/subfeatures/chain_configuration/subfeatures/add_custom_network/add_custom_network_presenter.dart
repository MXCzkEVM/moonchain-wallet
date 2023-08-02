import 'package:datadashwallet/common/common.dart';
import 'package:datadashwallet/core/core.dart';
import 'package:datadashwallet/features/settings/subfeatures/chain_configuration/entities/network.dart';
import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';

import 'add_custom_network_state.dart';

final addCustomNetworkContainer =
    PresenterContainer<AddCustomNetworkPresenter, AddCustomNetworkState>(
        () => AddCustomNetworkPresenter());

class AddCustomNetworkPresenter
    extends CompletePresenter<AddCustomNetworkState> {
  AddCustomNetworkPresenter() : super(AddCustomNetworkState());

  late final _chainConfigurationUseCase =
      ref.read(chainConfigurationUseCaseProvider);
  late final _contractUseCase = ref.read(contractUseCaseProvider);

  final TextEditingController networkNameController = TextEditingController();
  final TextEditingController rpcUrlController = TextEditingController();
  final TextEditingController chainIdController = TextEditingController();
  final TextEditingController symbolController = TextEditingController();
  final TextEditingController explorerController = TextEditingController();

  @override
  void initState() {
    super.initState();

    listen(_chainConfigurationUseCase.networks, (value) {
      if (value.isEmpty) {
        // populates the default list
        final defaultList = Network.fixedNetworks();
        _chainConfigurationUseCase.addItems(defaultList);

        notify(() => state.networks = defaultList);
      } else {
        notify(() => state.networks = value);
      }
    });
  }

  void addNewNetwork() async {
    final web3RpcHttpUrl = rpcUrlController.text;
    final web3RpcWebsocketUrl =
        rpcUrlController.text.replaceAll('https', 'wss');
    final chainId = Formatter.hexToDecimal(chainIdController.text);
    final symbol = symbolController.text;
    final explorerUrl =
        explorerController.text.isNotEmpty ? explorerController.text : null;
    final label = networkNameController.text.isNotEmpty
        ? networkNameController.text
        : null;

    final newNetwork = Network(
        web3RpcHttpUrl: web3RpcHttpUrl,
        web3RpcWebsocketUrl: web3RpcWebsocketUrl,
        symbol: symbol,
        explorerUrl: explorerUrl,
        enabled: true,
        label: label,
        chainId: chainId,
        isAdded: true,
        networkType: NetworkType.custom);

    _chainConfigurationUseCase.addItem(newNetwork);

    _chainConfigurationUseCase.switchDefaultNetwork(newNetwork);
  }

  void onSave(BuildContext context) {
    loading = true;
    try {
      addNewNetwork();
      final networkTitle = networkNameController.text.isNotEmpty
          ? networkNameController.text
          : rpcUrlController.text;
      // BottomFlowDialog.of(context)..close()..close();
      // Navigator.of(context).replaceAll(route)
      // Navigator.pushAndRemoveUntil(
      //   context,
      //   route.featureDialog(
      //     const ChainConfigurationPage(),
      //   ),
      //   (Route<dynamic> route) => route.currentResult,
      // ).then((value) {
      //   if (value != null && value) {
      //     showCustomNetworkSwitchDialog(context, networkTitle);
      //   }
      // });
    } catch (error, stackTrace) {
      addError(error, stackTrace);
    } finally {
      loading = false;
    }
  }

  void onRpcUrlChange(String value) async {
    loading = true;
    try {
      state.chainId = await _contractUseCase.getChainId(value);
    } catch (error, stackTrace) {
      addError(error, stackTrace);
    } finally {
      loading = false;
    }
  }

  String? compareChainId(BuildContext context, String value,
      {bool isNumeric = true}) {
    int enteredChainId;
    if (!isNumeric) enteredChainId = Formatter.hexToDecimal(value);
    enteredChainId = int.parse(value);
    if (state.chainId == null) {
      return FlutterI18n.translate(context, 'could_not_fetch_chain_id_notice');
    }
    int fetchedChainId = state.chainId!;
    if (enteredChainId != fetchedChainId) {
      return FlutterI18n.translate(context, 'different_chain_id_x_notice')
          .replaceFirst('{0}', enteredChainId.toString());
    }
    return null;
  }

  void changeAbleToSave(bool value) {
    notify(() => state.ableToSave = value);
  }
}