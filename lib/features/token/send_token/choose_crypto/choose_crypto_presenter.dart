import 'package:datadashwallet/core/core.dart';
import 'package:flutter/material.dart';

import 'choose_crypto_state.dart';

final addTokenPageContainer =
    PresenterContainer<ChooseCryptoPresenter, ChooseCryptoState>(
        () => ChooseCryptoPresenter());

class ChooseCryptoPresenter extends CompletePresenter<ChooseCryptoState> {
  ChooseCryptoPresenter() : super(ChooseCryptoState());

  late final _contractUseCase = ref.read(contractUseCaseProvider);
  late final TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();

    listen(_contractUseCase.tokensList, (newTokens) {
      if (newTokens.isNotEmpty) {
        notify(() {
          state.tokens = newTokens;
          state.fliterTokens = newTokens;
        });
      }
    });
  }

  void fliterTokenByName(String value) {
    final tokens = state.tokens
        ?.where((item) =>
            item.name!.contains(RegExp(value, caseSensitive: false)) ||
            item.symbol!.contains(RegExp(value, caseSensitive: false)))
        .toList();

    notify(() => state.fliterTokens = tokens);
  }

  @override
  Future<void> dispose() async {
    super.dispose();
  }
}
