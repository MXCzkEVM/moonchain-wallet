import 'package:datadashwallet/app/app.dart';
import 'package:datadashwallet/common/common.dart';
import 'package:datadashwallet/core/core.dart';
import 'package:datadashwallet/features/settings/settings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:mxc_logic/mxc_logic.dart';

import 'delete_custom_network_state.dart';

final deleteCustomNetworkContainer =
    PresenterContainer<DeleteCustomNetworkPresenter, DeleteCustomNetworkState>(
        () => DeleteCustomNetworkPresenter());

class DeleteCustomNetworkPresenter
    extends CompletePresenter<DeleteCustomNetworkState> {
  DeleteCustomNetworkPresenter() : super(DeleteCustomNetworkState());

  late final _chainConfigurationUseCase =
      ref.read(chainConfigurationUseCaseProvider);
  late final _tokenContractUseCase = ref.read(tokenContractUseCaseProvider);
  late final _transactionHistoryUseCase =
      ref.read(transactionHistoryUseCaseProvider);

  late final TextEditingController networkNameController =
      TextEditingController();
  late final TextEditingController rpcUrlController = TextEditingController();
  late final TextEditingController chainIdController = TextEditingController();
  late final TextEditingController symbolController = TextEditingController();
  late final TextEditingController explorerController = TextEditingController();
  late final _authUseCase = ref.read(authUseCaseProvider);
  late final _webviewUseCase = WebviewUseCase();

  Network? selectedNetwork;

  @override
  void initState() {
    super.initState();

    listen(_chainConfigurationUseCase.networks, (value) {
      notify(() => state.networks = value);
    });

    listen(_chainConfigurationUseCase.selectedNetworkForDetails, (value) {
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

  void updateNetwork(Network oldNetwork) async {
    final itemIndex = state.networks
        .indexWhere((element) => element.chainId == oldNetwork.chainId);

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

    final newNetwork = oldNetwork.copyWith(
        web3RpcHttpUrl: web3RpcHttpUrl,
        web3RpcWebsocketUrl: web3RpcWebsocketUrl,
        symbol: symbol,
        explorerUrl: explorerUrl,
        enabled: oldNetwork.enabled,
        label: label,
        chainId: chainId,
        isAdded: true,
        networkType: NetworkType.custom);

    if (itemIndex != -1) {
      _chainConfigurationUseCase.updateItem(newNetwork, itemIndex);
    }
  }

  void deleteNetwork() {
    if (selectedNetwork!.enabled) {
      setNewDefault();
    }
    final itemIndex = state.networks
        .indexWhere((element) => element.chainId == selectedNetwork!.chainId);
    if (itemIndex != -1) {
      final selectedNetwork =
          state.networks[itemIndex].copyWith(isAdded: false);
      _chainConfigurationUseCase.updateItem(selectedNetwork, itemIndex);
    }
  }

  void setAsDefault() {
    _chainConfigurationUseCase.switchDefaultNetwork(selectedNetwork!);
    _authUseCase.resetNetwork(selectedNetwork!);
    loadDataDashProviders(selectedNetwork!);

    addMessage(translate('x_is_now_active')!.replaceFirst(
        '{0}',
        selectedNetwork!.label ??
            '${selectedNetwork!.web3RpcHttpUrl.substring(0, 16)}...'));
  }

  void setNewDefault() {
    final newDefault = state.networks[0];
    _chainConfigurationUseCase.switchDefaultNetwork(newDefault);
    _authUseCase.resetNetwork(newDefault);
    _webviewUseCase.clearCache();
    loadDataDashProviders(newDefault);

    addMessage(translate('x_is_now_active')!.replaceFirst(
        '{0}',
        newDefault.label ??
            '${newDefault.web3RpcHttpUrl.substring(0, 16)}...'));
  }
}
