import 'package:clipboard/clipboard.dart';
import 'package:datadashwallet/core/core.dart';
import 'package:mxc_logic/mxc_logic.dart';
import 'portfolio_page_state.dart';
import 'package:web3dart/web3dart.dart';

final portfolioContainer =
    PresenterContainer<PortfolioPresenter, PortfolioState>(
        () => PortfolioPresenter());

class PortfolioPresenter extends CompletePresenter<PortfolioState> {
  PortfolioPresenter() : super(PortfolioState());

  late final _accountUserCase = ref.read(accountUseCaseProvider);
  late final _contractUseCase = ref.read(contractUseCaseProvider);
  late final _nftUseCase = ref.read(nftsUseCaseProvider);

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

    listen(_nftUseCase.nfts, (newNFTList) {
      notify(() => state.nftList = newNFTList);
    });

    _accountUserCase.refreshWallet();
  }

  initializePortfolioPage() {
    getWalletTokensBalance();
    getNfts();
  }

  getNfts() async {
    final newNftList =
        await _contractUseCase.getNftsByAddress(state.walletAddress!);
    _nftUseCase.mergeNewList(newNftList);
  }

  void getWalletTokensBalance() async {
    await _contractUseCase.getTokensBalance(state.walletAddress!);
  }

  void getWalletNFTs() {}

  void changeTokensOrNFTsTab() {
    notify(() => state.switchTokensOrNFTs = !state.switchTokensOrNFTs);
  }

  void copyWalletAddressToClipboard() async {
    FlutterClipboard.copy(state.walletAddress ?? '')
        .then((value) => notify(() => state.isWalletAddressCopied = true));
  }

  void resetCopyState() {
    notify(() => state.isWalletAddressCopied = false);
  }
}
