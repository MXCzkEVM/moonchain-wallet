import 'package:datadashwallet/core/core.dart';
import 'package:flutter/material.dart';

import 'choose_nft_state.dart';

final chooseNFTPageContainer =
    PresenterContainer<ChooseNFTPresenter, ChooseNFTState>(
        () => ChooseNFTPresenter());

class ChooseNFTPresenter extends CompletePresenter<ChooseNFTState> {
  ChooseNFTPresenter() : super(ChooseNFTState());

  late final _contractUseCase = ref.read(contractUseCaseProvider);
  late final _accountUserCase = ref.read(accountUseCaseProvider);
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

    listen(_contractUseCase.tokensList, (newTokens) {
      if (newTokens.isNotEmpty) {
        notify(() {
          // state.tokens = newTokens;
          // state.filterTokens = newTokens;
        });
      }
    });
  }

  Future<void> loadPage() async {
    await _contractUseCase.getTokensBalance(state.walletAddress);
  }

  void fliterNFTs(String value) {
    final tokens = state.nfts
        ?.where((item) =>
            item.address.contains(RegExp(value, caseSensitive: false)) ||
            item.collectionID.contains(RegExp(value, caseSensitive: false)))
        .toList();

    notify(() => state.filterNFTs = tokens);
  }

  @override
  Future<void> dispose() async {
    super.dispose();
  }
}
