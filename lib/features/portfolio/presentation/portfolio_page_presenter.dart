import 'package:moonchain_wallet/common/common.dart';
import 'package:moonchain_wallet/core/core.dart';
import 'package:moonchain_wallet/features/dapps/dapps.dart';
import 'package:flutter/material.dart';
import 'package:mxc_logic/mxc_logic.dart';

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
  late final _launcherUseCase = ref.read(launcherUseCaseProvider);

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

    listen(_chainConfigurationUseCase.selectedNetwork, (value) {
      if (value != null) {
        state.network = value;
      }
    });

    listen(_accountUserCase.account, (value) {
      if (value != null) {
        notify(() => state.walletAddress = value.address);
        initializePortfolioPage();
      }
    });

    listen(_tokenContractUseCase.tokensList, (newTokenList) {
      if (state.tokensList != null && newTokenList.isNotEmpty) {
        notify(() => state.tokensList = newTokenList);
      } else {
        state.tokensList = newTokenList;
      }
    });

    listen(_nftUseCase.nfts, (newNFTList) {
      notify(() => state.nftList = newNFTList);
    });
  }

  initializePortfolioPage() {
    getNfts();
    getBuyEnabled();
  }

  getNfts() async {
    final nftList = await _nftContractUseCase.getNftsByAddress(
        state.walletAddress!, state.ipfsGateway!);
    final domainsList = await _nftContractUseCase.getDomainsByAddress(
        state.walletAddress!, state.ipfsGateway!);

    nftList.addAll(domainsList);
    _nftUseCase.mergeNewList(nftList);
  }

  void changeTokensOrNFTsTab(bool toggle) {
    if (toggle == state.switchTokensOrNFTs) return;
    notify(() => state.switchTokensOrNFTs = toggle);
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

  String? getNftMarketPlaceUrl() {
    return _launcherUseCase.getNftMarketPlaceUrl();
  }

  void showReceiveSheet() {
    final walletAddress = state.walletAddress!;
    final chainId = state.network!.chainId;
    final networkSymbol = state.network!.symbol;
    showReceiveBottomSheet(context!, walletAddress, chainId, networkSymbol, () {
      final jannowitzUri = Urls.networkJannowitz(chainId);
      Navigator.of(context!).push(route.featureDialog(
        maintainState: false,
        OpenDAppPage(
          url: jannowitzUri,
        ),
      ));
    }, _launcherUseCase.launchUrlInPlatformDefaultWithString, false);
  }
}
