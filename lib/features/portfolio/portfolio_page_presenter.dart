import 'package:datadashwallet/core/core.dart';
import 'portfolio_page_state.dart';

final portfolioContainer =
    PresenterContainer<PortfolioPresenter, PortfolioState>(
        () => PortfolioPresenter());

class PortfolioPresenter extends CompletePresenter<PortfolioState> {
  PortfolioPresenter() : super(PortfolioState());

  late final _accountUserCase = ref.read(accountUseCaseProvider);
  late final _contractUseCase = ref.read(contractUseCaseProvider);

  @override
  void initState() {
    super.initState();

    listen(_accountUserCase.walletAddress, (value) {
      if (value != null) {
        notify(() => state.walletAddress = value);
        initializePortfolioPage();
      }
    });

    listen(_contractUseCase.tokensList, (newTokenList) {
      if (newTokenList.isNotEmpty) {
        if (state.tokensList != null) {
          notify(() => state.tokensList = newTokenList);
        } else {
          state.tokensList = newTokenList;
        }
      }
    });

    _accountUserCase.refreshWallet();
  }

  initializePortfolioPage() {
    getWalletTokensBalance();
  }

  void getWalletTokensBalance() async {
    await _contractUseCase.getTokensBalance(state.walletAddress!);
  }

  void getWalletNFTs() {}

  void changeTokensOrNFTsTab() {
    notify(() => state.switchTokensOrNFTs = !state.switchTokensOrNFTs);
  }
}
