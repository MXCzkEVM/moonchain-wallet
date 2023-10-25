import 'package:datadashwallet/common/config.dart';
import 'package:datadashwallet/core/core.dart';
import 'package:flutter/material.dart';

import 'choose_crypto_state.dart';

final chooseCryptoPageContainer =
    PresenterContainer<ChooseCryptoPresenter, ChooseCryptoState>(
        () => ChooseCryptoPresenter());

class ChooseCryptoPresenter extends CompletePresenter<ChooseCryptoState> {
  ChooseCryptoPresenter() : super(ChooseCryptoState());

  late final _chainConfigurationUseCase =
      ref.read(chainConfigurationUseCaseProvider);
  late final _tokenContractUseCase = ref.read(tokenContractUseCaseProvider);
  late final _accountUserCase = ref.read(accountUseCaseProvider);
  late final TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();

    listen(_accountUserCase.account, (value) {
      if (value != null) {
        notify(() => state.account = value);
      }
    });

    listen(_chainConfigurationUseCase.selectedNetwork, (value) {
      if (value != null) {
        state.network = value;
        if (state.account != null) {
          loadPage();
        }
      }
    });

    listen(_tokenContractUseCase.tokensList, (newTokens) {
      if (newTokens.isNotEmpty) {
        notify(() {
          state.tokens = newTokens;
          state.filterTokens = newTokens;
        });
      }
    });
  }

  Future<void> loadPage() async {
    final chainId = state.network!.chainId;
    final shouldGetPrice =
        Config.isMxcChains(chainId) || Config.isEthereumMainnet(chainId);
    await _tokenContractUseCase.getTokensBalance(
        null, state.account!.address, shouldGetPrice);
  }

  void fliterTokenByName(String value) {
    final tokens = state.tokens
        ?.where((item) =>
            item.name!.contains(RegExp(value, caseSensitive: false)) ||
            item.symbol!.contains(RegExp(value, caseSensitive: false)))
        .toList();

    notify(() => state.filterTokens = tokens);
  }

  @override
  Future<void> dispose() async {
    super.dispose();
  }
}
