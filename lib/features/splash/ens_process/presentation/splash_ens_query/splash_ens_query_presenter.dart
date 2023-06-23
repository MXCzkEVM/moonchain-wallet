import 'package:datadashwallet/app/configuration.dart';
import 'package:datadashwallet/features/home/apps/apps.dart';
import 'package:datadashwallet/features/home/apps/presentation/open_app/open_app_page.dart';
import 'package:datadashwallet/features/home/home.dart';
import 'package:ens_dart/ens_dart.dart';

import 'package:datadashwallet/core/core.dart';
import 'package:flutter/material.dart';
import 'splash_ens_query_state.dart';
import 'package:http/http.dart';
import 'package:web3dart/web3dart.dart';
import 'package:web_socket_channel/io.dart';

final splashENSQueryContainer =
    PresenterContainer<SplashENSQueryPresenter, SplashENSQueryState>(
        () => SplashENSQueryPresenter());

class SplashENSQueryPresenter extends CompletePresenter<SplashENSQueryState> {
  SplashENSQueryPresenter() : super(SplashENSQueryState());

  late final Web3Client _web3client;

  @override
  void initState() {
    super.initState();

    _web3client = Web3Client(Sys.rpcUrl, Client(), socketConnector: () {
      return IOWebSocketChannel.connect(Sys.wsUrl).cast<String>();
    });
  }

  @override
  Future<void> dispose() async {
    _web3client.dispose();

    super.dispose();
  }

  Future<void> queryNameAvailable() async {
    final ens = Ens(client: _web3client);
    final name = state.usernameController.text;

    notify(() => state.errorText = validateName(name));
    if (state.errorText != null && state.errorText!.isNotEmpty) return;

    try {
      final addr = await ens.withName(name).getAddress();
      state.isRegistered = ens.isRegistered(addr);
      state.errorText = validateRegistered(state.isRegistered);

      notify();
    } catch (error, tackTrace) {
      addError(error, tackTrace);
    }
  }

  String? validateName(String name) {
    if (name.isEmpty) return '';

    if (name.length < 3 || name.length > 30) {
      return 'domain_limit';
    }

    if (!RegExp(r'^[ZA-ZZa-z0-9]+$').hasMatch(name)) {
      return 'domain_invalid';
    }

    return null;
  }

  String? validateRegistered(bool isRegistered) {
    if (isRegistered) {
      return 'domain_registered';
    }

    return null;
  }

  Future<void> claim() async {
    final name = state.usernameController.text;

    navigator?.push(
      route.featureDialog(
        OpenAppPage(
          dapp: DAppCard(
            name: 'ISO Launchpad',
            description: 'Accelerating IOT',
            url: 'https://wannsee-mns.mxc.com/$name.mxc/register',
          ),
        ),
      ),
    );
  }
}
