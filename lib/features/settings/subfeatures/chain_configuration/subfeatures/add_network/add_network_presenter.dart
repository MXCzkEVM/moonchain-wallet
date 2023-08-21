import 'package:clipboard/clipboard.dart';
import 'package:datadashwallet/common/common.dart';
import 'package:datadashwallet/core/core.dart';
import 'package:datadashwallet/features/settings/settings.dart';
import 'package:mxc_logic/src/domain/entities/network.dart';
import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';

import 'add_network_state.dart';

final addNetworkContainer =
    PresenterContainer<AddNetworkPresenter, AddNetworkState>(
        () => AddNetworkPresenter());

class AddNetworkPresenter extends CompletePresenter<AddNetworkState> {
  AddNetworkPresenter() : super(AddNetworkState());

  late final _webviewUseCase = WebviewUseCase();
  late final _authUseCase = ref.read(authUseCaseProvider);
  late final _chainConfigurationUseCase =
      ref.read(chainConfigurationUseCaseProvider);

  final TextEditingController gasLimitController = TextEditingController();

  @override
  void initState() {
    super.initState();

    listen(_chainConfigurationUseCase.networks, (value) {
      notify(() => state.networks = value);
    });
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

    addMessage(
      translate('x_is_now_active')!.replaceFirst(
          '{0}',
          newDefault.label ??
              '${newDefault.web3RpcHttpUrl.substring(0, 16)}...'),
    );
  }
}
