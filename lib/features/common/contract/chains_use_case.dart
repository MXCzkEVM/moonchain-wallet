import 'dart:async';

import 'package:datadashwallet/core/core.dart';
import 'package:datadashwallet/features/settings/subfeatures/chain_configuration/domain/chain_configuration_use_case.dart';
import 'package:mxc_logic/mxc_logic.dart';

class ChainsUseCase extends ReactiveUseCase {
  ChainsUseCase(
      this._repository, this._chainConfigurationUseCase, this._authUseCase);

  final Web3Repository _repository;
  final ChainConfigurationUseCase _chainConfigurationUseCase;
  final AuthUseCase _authUseCase;

  Future<ChainsRpcList> getChainsRpcUrls() async {
    return await _repository.chainsRepository.getChainsRpcUrls();
  }

  void updateChainsRPCUrls() async {
    try {
      final chainsRpcUrls = await getChainsRpcUrls();
      final networks = _chainConfigurationUseCase.networks.value;

      for (ChainRpcUrl chainRpcUrl in chainsRpcUrls.chainList ?? []) {
        final foundIndex = networks
            .indexWhere((element) => element.chainId == chainRpcUrl.chainId);

        if (foundIndex != -1) {
          final network = networks.elementAt(foundIndex);

          // If any change is detected
          if (network.web3RpcHttpUrl != chainRpcUrl.httpUrl ||
              network.web3RpcWebsocketUrl != chainRpcUrl.wssUrl) {
            final updatedNetwork = network.copyWith(
                web3RpcHttpUrl: chainRpcUrl.httpUrl,
                web3RpcWebsocketUrl: chainRpcUrl.wssUrl);
            // Update in DB
            _chainConfigurationUseCase.updateItem(updatedNetwork, foundIndex);

            if (network.enabled) {
              _chainConfigurationUseCase.updateSelectedNetwork(updatedNetwork);
              _authUseCase.resetNetwork(updatedNetwork);
            }
          }
        }
      }
    } catch (e) {
      // This update necessary since, RPC change might be essential.
      updateChainsRPCUrls();
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
