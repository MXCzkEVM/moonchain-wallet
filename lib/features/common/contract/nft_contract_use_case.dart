import 'dart:async';

import 'package:moonchain_wallet/core/core.dart';
import 'package:mxc_logic/mxc_logic.dart';

class NftContractUseCase extends ReactiveUseCase {
  NftContractUseCase(
    this._repository,
  );

  final Web3Repository _repository;

  late final ValueStream<bool> online = reactive(false);

  Future<void> checkConnectionToNetwork() async {
    final result = await _repository.tokenContract.checkConnectionToNetwork();

    update(online, result);
  }

  Future<String> getOwerOf({
    required String address,
    required int tokeId,
  }) async =>
      await _repository.nftContract.getOwnerOf(
        address: address,
        tokenId: tokeId,
      );

  Future<Nft> getNft({
    required String address,
    required int tokeId,
  }) async =>
      await _repository.nftContract.getNft(
        address: address,
        tokenId: tokeId,
      );

  Future<String> sendTransaction({
    required String address,
    required int tokenId,
    required String privateKey,
    required String to,
    TransactionGasEstimation? estimatedGasFee,
  }) async =>
      await _repository.nftContract.sendTransaction(
        address: address,
        tokenId: tokenId,
        privateKey: privateKey,
        to: to,
        estimatedGasFee: estimatedGasFee,
      );

  Future<List<Nft>> getNftsByAddress(
    String address,
    String ipfsGateWay,
  ) async {
    return await _repository.nftContract.getNftsByAddress(address, ipfsGateWay);
  }

  Future<List<Nft>> getDomainsByAddress(
    String address,
    String ipfsGateWay,
  ) async {
    return await _repository.nftContract
        .getDomainsByAddress(address, ipfsGateWay);
  }
}
