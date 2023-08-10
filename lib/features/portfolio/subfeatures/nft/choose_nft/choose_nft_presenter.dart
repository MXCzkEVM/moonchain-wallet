import 'package:datadashwallet/core/core.dart';
import 'package:flutter/material.dart';

import 'choose_nft_state.dart';

final chooseNftPageContainer =
    PresenterContainer<ChooseNftPresenter, ChooseNftState>(
        () => ChooseNftPresenter());

class ChooseNftPresenter extends CompletePresenter<ChooseNftState> {
  ChooseNftPresenter() : super(ChooseNftState());

  late final _nftContractUseCase = ref.read(nftContractUseCaseProvider);
  late final _accountUserCase = ref.read(accountUseCaseProvider);
  late final _nftsUseCase = ref.read(nftsUseCaseProvider);
  late final TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();

    listen(_accountUserCase.walletAddress, (value) {
      if (value != null) {
        notify(() => state.walletAddress = value);
        loadPage();
      }
    });

    listen(_nftsUseCase.nfts, (value) {
      notify(() {
        state.nfts = value;
        state.filterNfts = value;
      });
    });
  }

  void loadPage() async {
    final nfts =
        await _nftContractUseCase.getNftsByAddress(state.walletAddress);
    _nftsUseCase.mergeNewList(nfts);
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
