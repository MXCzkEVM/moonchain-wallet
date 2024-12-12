import 'package:moonchain_wallet/common/common.dart';
import 'package:moonchain_wallet/core/core.dart';
import 'package:moonchain_wallet/features/settings/settings.dart';
import 'package:mxc_logic/src/domain/entities/network.dart';
import 'package:flutter/material.dart';


final addNetworkContainer =
    PresenterContainer<AddNetworkPresenter, AddNetworkState>(
        () => AddNetworkPresenter());

class AddNetworkPresenter extends CompletePresenter<AddNetworkState> {
  AddNetworkPresenter() : super(AddNetworkState());

  late final _webviewUseCase = WebviewUseCase();
  late final _authUseCase = ref.read(authUseCaseProvider);
  late final _chainConfigurationUseCase =
      ref.read(chainConfigurationUseCaseProvider);
  late final _transactionHistoryUseCase =
      ref.read(transactionHistoryUseCaseProvider);

  final TextEditingController gasLimitController = TextEditingController();

  @override
  void initState() {
    super.initState();

    listen(_chainConfigurationUseCase.networks, (value) {
      notify(() => state.networks = value);
    });
  }

  showAddDialog(Network network) async {
    final res = await showAddNetworkDialog(
      context!,
      network: network,
      approveFunction: addNetworkToNetworkSelector,
    );

    if (res ?? false) {
      showSwitchNetworkDialog(context!,
          network: network, onSwitch: (network) => switchNetwork(network));
    }
  }

  Network? addNetworkToNetworkSelector(Network network) {
    final itemIndex = state.networks
        .indexWhere((element) => element.chainId == network.chainId);
    if (itemIndex != -1) {
      final selectedNetwork = state.networks[itemIndex].copyWith(isAdded: true);
      _chainConfigurationUseCase.updateItem(selectedNetwork, itemIndex);
      return selectedNetwork;
    }
    return null;
  }

  void switchNetwork(Network newDefault) {
    _chainConfigurationUseCase.switchDefaultNetwork(newDefault);
    _authUseCase.resetNetwork(newDefault);
    _webviewUseCase.clearCache();
    loadDataDashProviders(newDefault);

    addMessage(
      translate('x_is_now_active')!.replaceFirst(
          '{0}',
          newDefault.label ??
              '${newDefault.web3RpcHttpUrl.substring(0, 16)}...'),
    );

    navigator?.popUntil((route) {
      return route.settings.name?.contains('ChainConfigurationPage') ?? false;
    });
  }
}
