import 'package:moonchain_wallet/core/core.dart';
import 'package:flutter/material.dart';

import 'choose_nft_state.dart';

final chooseNftPageContainer =
    PresenterContainer<ChooseNftPresenter, ChooseNftState>(
        () => ChooseNftPresenter());

class ChooseNftPresenter extends CompletePresenter<ChooseNftState> {
  ChooseNftPresenter() : super(ChooseNftState());

  late final _nftContractUseCase = ref.read(nftContractUseCaseProvider);
  late final _accountUserCase = ref.read(accountUseCaseProvider);
  late final _nftUseCase = ref.read(nftsUseCaseProvider);
  late final _chainConfigurationUseCase =
      ref.read(chainConfigurationUseCaseProvider);

  late final TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();

    listen(_accountUserCase.account, (value) {
      if (value != null) {
        notify(() => state.account = value);
        loadPage();
      }
    });

    listen(_nftUseCase.nfts, (value) {
      notify(() {
        state.nfts = value;
        state.filterNfts = value;
      });
    });

    listen(_chainConfigurationUseCase.selectedIpfsGateWay, (newIpfsGateWay) {
      if (newIpfsGateWay != null) {
        notify(() => state.ipfsGateway = newIpfsGateWay);
      }
    });
  }

  void loadPage() async {
    final nftList = await _nftContractUseCase.getNftsByAddress(
        state.account!.address, state.ipfsGateway!);
    final domainsList = await _nftContractUseCase.getDomainsByAddress(
        state.account!.address, state.ipfsGateway!);

    nftList.addAll(domainsList);
    _nftUseCase.mergeNewList(nftList);
  }

  void fliterNfts(String value) {
    final result = state.nfts
        .where((item) =>
            item.name.contains(RegExp(value, caseSensitive: false)) ||
            item.address
                .toString()
                .contains(RegExp(value, caseSensitive: false)))
        .toList();

    notify(() => state.filterNfts = result);
  }
}
