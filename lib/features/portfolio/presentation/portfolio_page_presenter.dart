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

    listen(_chainConfigurationUseCase.networks, (value) {
      getBuyEnabled();
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
  }

  initializePortfolioPage() {
    getWalletTokensBalance();
    getNfts();
    getBuyEnabled();
  }

  getNfts() async {
    final newNftList =
        await _nftContractUseCase.getNftsByAddress(state.walletAddress!);
    _nftUseCase.mergeNewList(newNftList);
  }

  void getWalletTokensBalance() async {
    _tokenContractUseCase.getTokensBalance(state.walletAddress!);
  }

  void changeTokensOrNFTsTab(bool toggle) {
    if (toggle == state.switchTokensOrNFTs) return;
    notify(() => state.switchTokensOrNFTs = toggle);
  }

  void copyWalletAddressToClipboard() async {
    FlutterClipboard.copy(state.walletAddress ?? '')
        .then((value) => notify(() => state.isWalletAddressCopied = true));
  }

  void resetCopyState() {
    notify(() => state.isWalletAddressCopied = false);
  }

  getBuyEnabled() {
    final enabledNetwork = _chainConfigurationUseCase.networks.value
        .where((element) => element.enabled)
        .toList()[0];
    if (enabledNetwork.chainId == Config.mxcTestnetChainId) {
      notify(() => state.buyEnabled = true);
    } else if (enabledNetwork.chainId == Config.mxcMainnetChainId) {
      notify(() => state.buyEnabled = true);
    } else {
      notify(() => state.buyEnabled = false);
    }
  }

  void buyNFt() {
    final enabledNetwork = _chainConfigurationUseCase.networks.value
        .where((element) => element.enabled)
        .toList()[0];
    if (enabledNetwork.chainId == Config.mxcTestnetChainId) {
      openUrl(Urls.mxcTestnetNftMarketPlace);
    } else if (enabledNetwork.chainId == Config.mxcMainnetChainId) {
      openUrl(Urls.mxcMainnetNftMarketPlace);
    }
  }

  void openUrl(String url) async {
    (await canLaunchUrl(Uri.parse(url))) == true
        ? launchUrl(Uri.parse(url), mode: LaunchMode.inAppWebView)
        : null;
  }
}
