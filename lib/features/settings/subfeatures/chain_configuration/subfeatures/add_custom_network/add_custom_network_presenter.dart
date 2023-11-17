import 'dart:developer';

import 'package:datadashwallet/app/app.dart';
import 'package:datadashwallet/common/common.dart';
import 'package:datadashwallet/core/core.dart';
import 'package:datadashwallet/features/settings/settings.dart';
import 'package:mxc_logic/src/domain/entities/network.dart';
import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:mxc_ui/mxc_ui.dart';

import 'add_custom_network_state.dart';

final addCustomNetworkContainer =
    PresenterContainer<AddCustomNetworkPresenter, AddCustomNetworkState>(
        () => AddCustomNetworkPresenter());

class AddCustomNetworkPresenter
    extends CompletePresenter<AddCustomNetworkState> {
  AddCustomNetworkPresenter() : super(AddCustomNetworkState());

  late final _chainConfigurationUseCase =
      ref.read(chainConfigurationUseCaseProvider);
  late final _tokenContractUseCase = ref.read(tokenContractUseCaseProvider);
  late final _webviewUseCase = WebviewUseCase();
  late final _authUseCase = ref.read(authUseCaseProvider);

  final TextEditingController networkNameController = TextEditingController();
  final TextEditingController rpcUrlController = TextEditingController();
  final TextEditingController chainIdController = TextEditingController();
  final TextEditingController symbolController = TextEditingController();
  final TextEditingController explorerController = TextEditingController();

  @override
  void initState() {
    super.initState();

    listen(_chainConfigurationUseCase.networks, (value) {
      notify(() => state.networks = value);
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
        logo: 'assets/svg/networks/unknown.svg',
        web3RpcHttpUrl: web3RpcHttpUrl,
        web3RpcWebsocketUrl: web3RpcWebsocketUrl,
        symbol: symbol,
        explorerUrl: explorerUrl,
        enabled: true,
        label: label,
        chainId: chainId,
        isAdded: true,
        networkType: NetworkType.custom);

    if (!state.networks
        .any((element) => element.chainId == newNetwork.chainId)) {
      _chainConfigurationUseCase.addItem(newNetwork);

      _chainConfigurationUseCase.switchDefaultNetwork(newNetwork);
      _authUseCase.resetNetwork(newNetwork);
      _webviewUseCase.clearCache();
      loadDataDashProviders(newNetwork);
    }
  }

  void onSave() {
    loading = true;

    try {
      addNewNetwork();
      final networkTitle = networkNameController.text.isNotEmpty
          ? networkNameController.text
          : rpcUrlController.text;
      appNavigatorKey.currentState!.popUntil((route) {
        return route.settings.name?.contains('ChainConfigurationPage') ?? false;
      });
      showCustomNetworkSwitchDialog(
          appNavigatorKey.currentContext!, networkTitle);
    } catch (error, stackTrace) {
      addError(error, stackTrace);
    } finally {
      loading = false;
    }
  }

  void onRpcUrlChange(String value) async {
    loading = true;
    try {
      state.chainId = await _tokenContractUseCase.getChainId(value);
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
