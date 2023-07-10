import 'package:datadashwallet/core/core.dart';
import 'package:datadashwallet/features/home/home.dart';
import 'dart:convert';
import 'dart:math';
import 'package:mxc_logic/mxc_logic.dart';
import 'package:url_launcher/url_launcher.dart';
import 'portfolio_page_state.dart';

final portfolioContainer =
    PresenterContainer<PortfolioPresenter, PortfolioState>(
        () => PortfolioPresenter());

class PortfolioPresenter extends CompletePresenter<PortfolioState> {
  late final _homeUseCase = ref.read(homeUseCaseProvider);
  late final _portfolioUseCase = ref.read(portfolioUseCaseProvider);
  late final _walletUserCase = ref.read(walletUseCaseProvider);
  PortfolioPresenter() : super(PortfolioState());

  @override
  void initState() {
    super.initState();
    _walletUserCase.getPublicAddress().then(
      (walletAddress) {
        // All other services are dependent on the wallet pubic address
        state.walletAddress = walletAddress;
        getWalletTokensBalance();
      },
    );
  }

  void getWalletTokensBalance() async {
    final tokensBalanceList =
        await _portfolioUseCase.getTokensBalanceByAddress(state.walletAddress!);
    notify(() => state.tokensBalanceList = tokensBalanceList);
  }

  void getWalletNFTs() {}
}
