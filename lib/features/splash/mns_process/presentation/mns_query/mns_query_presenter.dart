import 'package:datadashwallet/common/common.dart';
import 'package:datadashwallet/common/config.dart';
import 'package:datadashwallet/features/dapps/dapps.dart';
import 'package:datadashwallet/core/core.dart';
import 'package:flutter/material.dart';
import 'mns_query_state.dart';
import '../widgets/no_balance_dialog.dart';
import 'mns_query_state.dart';

final splashMNSQueryContainer =
    PresenterContainer<SplashMNSQueryPresenter, SplashMNSQueryState>(
        () => SplashMNSQueryPresenter());

class SplashMNSQueryPresenter extends CompletePresenter<SplashMNSQueryState> {
  SplashMNSQueryPresenter() : super(SplashMNSQueryState());

  late final _tokenContractUseCase = ref.read(tokenContractUseCaseProvider);
  late final _accountUserCase = ref.read(accountUseCaseProvider);
  late final _chainConfigurationUseCase =
      ref.read(chainConfigurationUseCaseProvider);

  late final TextEditingController usernameController = TextEditingController();

  @override
  void initState() {
    super.initState();

    listen(_accountUserCase.account, (value) {
      if (value != null) {
        notify(() => state.walletAddress = value.address);
      }
    });

    listen(_chainConfigurationUseCase.selectedNetwork, (value) {
      if (value != null) {
        state.network = value;
      }
    });
  }

  Future<void> queryNameAvailable() async {
    final name = usernameController.text;
    loading = true;

    try {
      final result = await _tokenContractUseCase.getAddress(name);
      final valid = validateRegistered(result);
      notify(() => state.errorText = valid);

      if (valid == null) {
        claim(name);
      }
    } catch (error, tackTrace) {
      addError(error, tackTrace);
    } finally {
      loading = false;
    }
  }

  String? validateRegistered(String value) {
    if (BigInt.parse(value) != BigInt.zero) {
      return translate('domain_registered');
    }

    return null;
  }

  Future<void> checkBalance() async {
    notify(() => state.checking = true);

    try {
      final balance = await _tokenContractUseCase
          .getWalletNativeTokenBalance(state.walletAddress!);

      if (double.parse(balance) <= 0) {
        final result = await showNoBalanceDialog(context!);
        if (result != null) {
          if (result) {
            final network = state.network!;
            final walletAddress = state.walletAddress!;
            final chainId = network.chainId;
            showReceiveBottomSheet(
              context!,
              walletAddress,
              network.chainId,
              network.symbol,
              () {
                final l3BridgeUri = Urls.networkL3Bridge(chainId);
                Navigator.of(context!).push(route.featureDialog(
                  maintainState: false,
                  OpenAppPage(
                    url: l3BridgeUri,
                  ),
                ));
              },
              _chainConfigurationUseCase.launchUrlInPlatformDefault,
              true,
            );
          } else {
            navigator?.replaceAll(route(const DAppsPage()));
          }
        }
      } else {
        queryNameAvailable();
      }
    } catch (error, tackTrace) {
      addError(error, tackTrace);
    } finally {
      notify(() => state.checking = false);
    }
  }

  Future<void> claim(String name) async {
    final launchUrl = state.network!.chainId == Config.mxcMainnetChainId
        ? Config.mainnetMns(name)
        : Config.testnetMns(name);
    await navigator
        ?.push(route.featureDialog(OpenAppPage(url: launchUrl)))
        .then((_) {
      navigator?.replaceAll(route(const DAppsPage()));
    });
  }
}
