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
        notify(() => state.selectedNetwork =
            state.networks.firstWhere((element) => element.enabled == true));
        updateGasLimitTextfield();
      } else {
        notify(() => state.networks = value);

        if (state.selectedNetwork == null) {
          notify(() => state.selectedNetwork =
              state.networks.firstWhere((element) => element.enabled == true));
          updateGasLimitTextfield();
        }
      }
    });

    listen(_chainConfigurationUseCase.selectedIpfsGateWay, (value) {
      print('object');
      print(value);
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
    notify(() => state.selectedNetwork = selectedItem);
    updateGasLimitTextfield();
  }

  void setAsDefault(Network newDefault) {
    final itemIndex =
        state.networks.indexWhere((element) => element.enabled == true);
    if (itemIndex != -1) {
      final currentDefault = state.networks[itemIndex].copyWith(enabled: false);
      newDefault = newDefault.copyWith(enabled: true);
      _chainConfigurationUseCase.updateItem(newDefault);
      _chainConfigurationUseCase.updateItem(currentDefault);
    }
  }

  void updateGasLimit(String newGasLimit) {
    try {
      final gasLimit = int.parse(newGasLimit);
      final updatedNetwork =
          state.selectedNetwork!.copyWith(gasLimit: gasLimit);
      _chainConfigurationUseCase.updateItem(updatedNetwork);
    } catch (e) {
      addError(e);
    }
  }

  void updateGasLimitTextfield() {
    gasLimitController.text = state.selectedNetwork!.gasLimit != null
        ? state.selectedNetwork!.gasLimit.toString()
        : '';
  }
}
