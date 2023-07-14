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
  PortfolioPresenter() : super(PortfolioState());

  late final _contractUseCase = ref.read(contractUseCaseProvider);
  late final _portfolioUseCase = ref.read(portfolioUseCaseProvider);
  late final _walletUserCase = ref.read(walletUseCaseProvider);

  @override
  void initState() {
    super.initState();
    listen(_contractUseCase.tokensList, (newTokenList) {
      if (newTokenList.isNotEmpty) {
        if (state.tokensList != null) {
          notify(() => state.tokensList = newTokenList);
        } else {
          state.tokensList = newTokenList;
        }
      }
    });
  }

  initializePortfolioPage() {
    _walletUserCase.getPublicAddress().then(
      (walletAddress) {
        // All other services are dependent on the wallet pubic address
        //  state.walletAddress = walletAddress;
        getWalletTokensBalance();
      },
    );
  }

  void getWalletTokensBalance() {
    _contractUseCase.getTokensBalance();
  }

  void getWalletNFTs() {}
}
