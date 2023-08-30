import 'package:datadashwallet/features/dapps/dapps.dart';
import 'package:datadashwallet/core/core.dart';
import 'package:datadashwallet/features/portfolio/presentation/widgets/show_wallet_address_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/src/consumer.dart';
import 'mns_query_state.dart';
import '../widgets/no_balance_dialog.dart';

final splashMNSQueryContainer =
    PresenterContainer<SplashMNSQueryPresenter, SplashMNSQueryState>(
        () => SplashMNSQueryPresenter());

class SplashMNSQueryPresenter extends CompletePresenter<SplashMNSQueryState> {
  SplashMNSQueryPresenter() : super(SplashMNSQueryState());

  late final _tokenContractUseCase = ref.read(tokenContractUseCaseProvider);
  late final _accountUserCase = ref.read(accountUseCaseProvider);

  late final TextEditingController usernameController = TextEditingController();

  @override
  void initState() {
    super.initState();

    listen(_accountUserCase.account, (value) {
      if (value != null) {
        notify(() => state.walletAddress = value.address);
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
            showWalletAddressDialog(
              context: context!,
              walletAddress: state.walletAddress,
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
    await navigator
        ?.push(route.featureDialog(
            OpenAppPage(url: 'https://wannsee-mns.mxc.com/$name.mxc/register')))
        .then((_) {
      navigator?.replaceAll(route(const DAppsPage()));
    });
  }
}
