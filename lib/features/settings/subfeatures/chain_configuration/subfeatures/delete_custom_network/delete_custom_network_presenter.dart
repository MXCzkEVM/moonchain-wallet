import 'package:datadashwallet/app/app.dart';
import 'package:datadashwallet/common/common.dart';
import 'package:datadashwallet/core/core.dart';
import 'package:datadashwallet/features/settings/subfeatures/chain_configuration/entities/network.dart';
import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';

import 'delete_custom_network_state.dart';

final deleteCustomNetworkContainer =
    PresenterContainer<DeleteCustomNetworkPresenter, DeleteCustomNetworkState>(
        () => DeleteCustomNetworkPresenter());

class DeleteCustomNetworkPresenter
    extends CompletePresenter<DeleteCustomNetworkState> {
  DeleteCustomNetworkPresenter() : super(DeleteCustomNetworkState());

  late final _chainConfigurationUseCase =
      ref.read(chainConfigurationUseCaseProvider);
  late final _contractUseCase = ref.read(contractUseCaseProvider);

  late final TextEditingController networkNameController =
      TextEditingController();
  late final TextEditingController rpcUrlController = TextEditingController();
  late final TextEditingController chainIdController = TextEditingController();
  late final TextEditingController symbolController = TextEditingController();
  late final TextEditingController explorerController = TextEditingController();

  Network? selectedNetwork;

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

    listen(_chainConfigurationUseCase.selectedNetwork, (value) {
      if (value != null && value.networkType == NetworkType.custom) {
        initializePage(value);
      }
    });
  }

  void initializePage(Network network) {
    networkNameController.text = network.label ?? '';
    rpcUrlController.text = network.web3RpcHttpUrl;
    chainIdController.text = network.chainId.toString();
    symbolController.text = network.symbol;
    explorerController.text = network.explorerUrl ?? '';

    selectedNetwork = network;

    notify(() => state.isEnabled = network.enabled);

    onRpcUrlChange(network.web3RpcHttpUrl);
  }

  void onSave() {
    loading = true;
    try {
      updateNetwork(selectedNetwork!);

      final networkTitle = networkNameController.text.isNotEmpty
          ? networkNameController.text
          : rpcUrlController.text;
      appNavigatorKey.currentState!.pop();
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

  void updateNetwork(Network oldNetwork) async {
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
        enabled: oldNetwork.enabled,
        label: label,
        chainId: chainId,
        isAdded: true,
        networkType: NetworkType.custom);

    final itemIndex = state.networks
        .indexWhere((element) => element.chainId == oldNetwork.chainId);

    if (itemIndex != -1) {
      _chainConfigurationUseCase.updateItem(newNetwork, itemIndex);
    }
  }

  void deleteNetwork() {
    if (selectedNetwork!.enabled) {
      setNewDefault();
    }
    _chainConfigurationUseCase.removeItem(selectedNetwork!);
  }

  void setAsDefault() {
    _chainConfigurationUseCase.switchDefaultNetwork(selectedNetwork!);

    addMessage(translate('x_is_now_active')!.replaceFirst(
        '{0}',
        selectedNetwork!.label ??
            '${selectedNetwork!.web3RpcHttpUrl.substring(0, 16)}...'));
  }

  void setNewDefault() {
    final newDefault = state.networks[0];
    _chainConfigurationUseCase.switchDefaultNetwork(newDefault);

    addMessage(translate('x_is_now_active')!.replaceFirst(
        '{0}',
        newDefault.label ??
            '${newDefault.web3RpcHttpUrl.substring(0, 16)}...'));
  }
}
