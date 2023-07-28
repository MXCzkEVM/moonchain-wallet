import 'package:clipboard/clipboard.dart';
import 'package:datadashwallet/core/core.dart';
import 'package:datadashwallet/features/settings/subfeatures/chain_configuration/entities/network.dart';
import 'package:flutter/material.dart';
import 'chain_configuration_state.dart';

final chainConfigurationContainer =
    PresenterContainer<ChainConfigurationPresenter, ChainConfigurationState>(
        () => ChainConfigurationPresenter());

class ChainConfigurationPresenter
    extends CompletePresenter<ChainConfigurationState> {
  ChainConfigurationPresenter() : super(ChainConfigurationState());

  late final _accountUserCase = ref.read(accountUseCaseProvider);
  late final _contractUseCase = ref.read(contractUseCaseProvider);
  late final _chainConfigurationUseCase = ref.read(chainConfigurationUseCase);

  final TextEditingController gasLimitController = TextEditingController();

  @override
  void initState() {
    super.initState();

    listen(_chainConfigurationUseCase.networks, (value) {
      if (value.isEmpty) {
        // populates the
        final defaultList = Network.fixedNetworks();
        _chainConfigurationUseCase.addItems(defaultList);

        notify(() => state.networks = defaultList);
        notify(() => state.selectedNetwork = state.networks.firstWhere((element) => element.enabled == true));
      } else {
        notify(() => state.networks = value);
        notify(() => state.selectedNetwork = state.networks.firstWhere((element) => element.enabled == true));
      }
    });

    listen(_chainConfigurationUseCase.selectedIpfsGateWay, (value) {
      if (value.isNotEmpty) {
        notify(() => state.selectedIpfsGateWay = value);
      } 
    });
  }

  void selectIpfsGateWay(String text) async {
    final selectedItemIndex = state.ipfsGateWays.indexOf(text);
    final selectedIpfsGateWay = state.ipfsGateWays[selectedItemIndex];
    _chainConfigurationUseCase.changeIpfsGateWay(selectedIpfsGateWay);
  }

  void selectNetwork(int chainId) {
    final selectedItem =
        state.networks.firstWhere((element) => element.chainId == chainId);
    state.selectedNetwork = selectedItem;
  }

  void setAsDefault(Network newDefault) {
    final itemIndex =
        state.networks.indexWhere((element) => element.enabled == true);
    if (itemIndex != -1) {
      final currentDefault = state.networks[itemIndex];
      currentDefault.copyWith(enabled: false);
      newDefault.copyWith(enabled: true);
      _chainConfigurationUseCase.updateItem(currentDefault);
      _chainConfigurationUseCase.updateItem(newDefault);
    }
  }

  void updateGasLimit() {
    try {
      final gasLimit = int.parse(gasLimitController.text);
      state.selectedNetwork!.copyWith(gasLimit: gasLimit);
      _chainConfigurationUseCase.updateItem(state.selectedNetwork!);
    } catch (e) {
      addError(e);
    }
  }
}
