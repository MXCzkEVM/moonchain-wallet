import 'package:clipboard/clipboard.dart';
import 'package:datadashwallet/common/common.dart';
import 'package:datadashwallet/core/core.dart';
import 'package:mxc_logic/mxc_logic.dart';
import 'package:url_launcher/url_launcher.dart';
import 'portfolio_page_state.dart';

final portfolioContainer =
    PresenterContainer<PortfolioPresenter, PortfolioState>(
        () => PortfolioPresenter());

class PortfolioPresenter extends CompletePresenter<PortfolioState> {
  PortfolioPresenter() : super(PortfolioState());

  late final _accountUserCase = ref.read(accountUseCaseProvider);
  late final _tokenContractUseCase = ref.read(tokenContractUseCaseProvider);
  late final _nftContractUseCase = ref.read(nftContractUseCaseProvider);
  late final _nftUseCase = ref.read(nftsUseCaseProvider);
  late final _chainConfigurationUseCase =
      ref.read(chainConfigurationUseCaseProvider);

  @override
  void initState() {
    super.initState();

    listen(_chainConfigurationUseCase.selectedIpfsGateWay, (newIpfsGateWay) {
      if (newIpfsGateWay != null) {
        notify(() => state.ipfsGateway = newIpfsGateWay);
      }
    });

    listen(_accountUserCase.account, (value) {
      if (value != null) {
        notify(() => state.walletAddress = value.address);
        initializePortfolioPage();
      }
    });

    listen(_tokenContractUseCase.tokensList, (newTokenList) {
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
        await _nftContractUseCase.getNftsByAddress(state.walletAddress!);
    _nftUseCase.mergeNewList(newNftList);
  }

  void getWalletTokensBalance() async {
    await _tokenContractUseCase.getTokensBalance(state.walletAddress!);
  }

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

  void buyNFt() {
    if (_chainConfigurationUseCase.networks.value
            .where((element) => element.enabled)
            .toList()[0]
            .chainId ==
        Network.fixedNetworks()[0].chainId) {
      openUrl(Urls.mxcTestnetNftMarketPlace);
    } else if (_chainConfigurationUseCase.selectedNetwork.value!.chainId ==
        Network.fixedNetworks()[1].chainId) {
      openUrl(Urls.mxcMainnetNftMarketPlace);
    }
  }

  void openUrl(String url) async {
    (await canLaunchUrl(Uri.parse(url))) == true
        ? launchUrl(Uri.parse(url))
        : null;
  }
}
