import 'package:datadashwallet/core/core.dart';
import 'package:flutter/material.dart';

import 'choose_nft_state.dart';

final chooseNftPageContainer =
    PresenterContainer<ChooseNftPresenter, ChooseNftState>(
        () => ChooseNftPresenter());

class ChooseNftPresenter extends CompletePresenter<ChooseNftState> {
  ChooseNftPresenter() : super(ChooseNftState());

  late final _contractUseCase = ref.read(contractUseCaseProvider);
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

    listen(_nftsUseCase.nfts, (nfts) {
      if (nfts.isNotEmpty) {
        notify(() {
          state.nfts = nfts;
          state.filterNfts = nfts;
        });
      }
    });

    loadPage();
  }

  Future<void> loadPage() async {
    _nftsUseCase.getNfts();
  }

  void fliterNfts(String value) {
    final tokens = state.nfts
        ?.where((item) =>
            item.address.contains(RegExp(value, caseSensitive: false)) ||
            item.tokenId
                .toString()
                .contains(RegExp(value, caseSensitive: false)))
        .toList();

    notify(() => state.filterNfts = tokens);
  }

  @override
  Future<void> dispose() async {
    super.dispose();
  }
}
