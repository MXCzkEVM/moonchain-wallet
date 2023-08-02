import 'package:datadashwallet/common/common.dart';
import 'package:datadashwallet/core/core.dart';
import 'package:datadashwallet/features/settings/subfeatures/chain_configuration/entities/network.dart';
import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'chain_configuration_state.dart';

final chainConfigurationContainer =
    PresenterContainer<ChainConfigurationPresenter, ChainConfigurationState>(
        () => ChainConfigurationPresenter());

class ChainConfigurationPresenter
    extends CompletePresenter<ChainConfigurationState> {
  ChainConfigurationPresenter() : super(ChainConfigurationState());

  late final _accountUserCase = ref.read(accountUseCaseProvider);
  late final _contractUseCase = ref.read(contractUseCaseProvider);
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

        notify(() => state.networks =
            defaultList.where((element) => element.isAdded == true).toList());
        updateSelectedNetwork();
        updateGasLimitTextfield();
      } else {
        notify(() => state.networks =
            value.where((element) => element.isAdded == true).toList());
        if (state.selectedNetwork == null) {
          updateSelectedNetwork();
          updateGasLimitTextfield();
        }
      }
    });

    listen(_chainConfigurationUseCase.ipfsGateWayList, (newIpfsGateWayList) {
      if (newIpfsGateWayList.isNotEmpty) {
        if (state.ipfsGateWays == null) {
          notify(() => state.ipfsGateWays = newIpfsGateWayList);
        } else {
          state.ipfsGateWays!.clear();
          notify(() => state.ipfsGateWays!.addAll(newIpfsGateWayList));
        }
      }
    });

    listen(_chainConfigurationUseCase.selectedIpfsGateWay, (value) {
      if (value != null) {
        notify(() => state.selectedIpfsGateWay = value);
      }
    });
  }

  void selectIpfsGateWay(String text) async {
    final selectedItemIndex = state.ipfsGateWays!.indexOf(text);
    final selectedIpfsGateWay = state.ipfsGateWays![selectedItemIndex];
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

    //   _chainConfigurationUseCase.updateItem(
    //       newDefault, newDefaultItemIndex);
    //   _chainConfigurationUseCase.updateItem(
    //       currentDefault, currentDefaultItemIndex);
    // }
  }

  void updateGasLimitTextfield() {
    gasLimitController.text = state.selectedNetwork!.gasLimit != null
        ? state.selectedNetwork!.gasLimit.toString()
        : '';
  }

  void updateSelectedNetwork() {
    notify(() => state.selectedNetwork =
        state.networks.firstWhere((element) => element.enabled == true));
  }
}
