import 'package:clipboard/clipboard.dart';
import 'package:datadashwallet/common/common.dart';
import 'package:datadashwallet/core/core.dart';
import 'package:datadashwallet/features/settings/subfeatures/chain_configuration/entities/network.dart';
import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';

import 'add_network_state.dart';

final addNetworkContainer =
    PresenterContainer<AddNetworkPresenter, AddNetworkState>(
        () => AddNetworkPresenter());

class AddNetworkPresenter extends CompletePresenter<AddNetworkState> {
  AddNetworkPresenter() : super(AddNetworkState());

  late final _chainConfigurationUseCase =
      ref.read(chainConfigurationUseCaseProvider);

  final TextEditingController gasLimitController = TextEditingController();

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
    String translate(String text) => FlutterI18n.translate(context!, text);
    _chainConfigurationUseCase.switchDefaultNetwork(newDefault);
    showSnackBar(
        context: context!,
        content: translate('x_is_now_active').replaceFirst(
            '{0}',
            newDefault.label ??
                '${newDefault.web3RpcHttpUrl.substring(0, 16)}...'),
        isContentTranslated: true);
  }
}
