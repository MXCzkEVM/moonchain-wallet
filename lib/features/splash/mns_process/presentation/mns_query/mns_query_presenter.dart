import 'package:datadashwallet/features/dapps/dapps.dart';
import 'package:datadashwallet/core/core.dart';
import 'package:flutter/material.dart';
import 'mns_query_state.dart';

final splashMNSQueryContainer =
    PresenterContainer<SplashMNSQueryPresenter, SplashMNSQueryState>(
        () => SplashMNSQueryPresenter());

class SplashMNSQueryPresenter extends CompletePresenter<SplashMNSQueryState> {
  SplashMNSQueryPresenter() : super(SplashMNSQueryState());

  late final _tokenContractUseCase = ref.read(tokenContractUseCaseProvider);
  late final TextEditingController usernameController = TextEditingController();

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

  Future<void> claim(String name) async {
    await navigator
        ?.push(route.featureDialog(
            OpenAppPage(url: 'https://wannsee-mns.mxc.com/$name.mxc/register')))
        .then((_) {
      navigator?.replaceAll(route(const DAppsPage()));
    });
  }
}
