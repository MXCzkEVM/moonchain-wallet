import 'package:clipboard/clipboard.dart';
import 'package:datadashwallet/core/core.dart';
import 'package:datadashwallet/features/settings/subfeatures/chain_configuration/entities/network.dart';
import 'package:flutter/material.dart';

import 'add_network_state.dart';

final addNetworkContainer =
    PresenterContainer<AddNetworkPresenter, AddNetworkState>(
        () => AddNetworkPresenter());

class AddNetworkPresenter extends CompletePresenter<AddNetworkState> {
  AddNetworkPresenter() : super(AddNetworkState());

  late final _chainConfigurationUseCase = ref.read(chainConfigurationUseCase);

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

  void addNetwork(Network network) async {
    final itemIndex = state.networks
        .indexWhere((element) => element.chainId == network.chainId);
    if (itemIndex != -1) {
      final selectedNetwork = state.networks[itemIndex].copyWith(isAdded: true);
      _chainConfigurationUseCase.updateItem(selectedNetwork);
    }
  }

  void switchNetwork(Network network) {}
}
