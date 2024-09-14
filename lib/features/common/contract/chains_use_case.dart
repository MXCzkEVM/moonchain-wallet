import 'dart:async';

import 'package:moonchain_wallet/core/core.dart';
import 'package:moonchain_wallet/features/settings/subfeatures/chain_configuration/domain/chain_configuration_use_case.dart';
import 'package:mxc_logic/mxc_logic.dart';

class ChainsUseCase extends ReactiveUseCase {
  ChainsUseCase(
      this._repository, this._chainConfigurationUseCase, this._authUseCase);

  final Web3Repository _repository;
  final ChainConfigurationUseCase _chainConfigurationUseCase;
  final AuthUseCase _authUseCase;

  Future<ChainsList> getChainsRpcUrls() async {
    return await _repository.chainsRepository.getChainsRpcUrls();
  }

  void updateChains() async {
    try {
      final chainsRpcUrls = await getChainsRpcUrls();

      if (chainsRpcUrls.networks?.isNotEmpty ?? false) {
        final selectedNetwork =
            _chainConfigurationUseCase.updateNetworks(chainsRpcUrls.networks!);

        if (selectedNetwork != null) {
          _authUseCase.resetNetwork(selectedNetwork);
        }
      }
    } catch (e) {
      // This update necessary since, RPC change might be essential.
      updateChains();
    }
  }

  // void checkChainsRpcUrls(void Function(Network) resetNetwork, Network selectedNetwork) async {
  // try {
  //   final chainsRpcUrls = await getChainsRpcUrls();

  //   for (ChainRpcUrl chain in chainsRpcUrls.chainList ?? []) {
  //     await checkChainRpcUrls(chain);
  //   }
  // } catch (e) {
  //   checkChainsRpcUrls();
  // }
  // }

  // Future<void> checkChainRpcUrls(ChainRpcUrl chain) async {
  //   for (String url in chain.rpcUrls ?? []) {
  //     try {
  //       if (url.contains('wss')) {
  //         await checkWebSocketRpcUrl(url);
  //       } else {
  //         await checkRpcUrl(url);
  //       }
  //       // select the rpc url
  //     } catch (e) {
  //       continue;
  //     }
  //   }
  // }

  // // TODO: check websocket link
  // Future<int> checkWebSocketRpcUrl(String url) async {
  //   return _repository.chainsRepository.getBlockNumber(url);
  // }

  // Future<int> checkRpcUrl(String url) async {
  //   return _repository.chainsRepository.getBlockNumber(url);
  // }
}
