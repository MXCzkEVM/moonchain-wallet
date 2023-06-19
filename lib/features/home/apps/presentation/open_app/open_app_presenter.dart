import 'package:datadashwallet/app/configuration.dart';
import 'package:datadashwallet/core/core.dart';
import 'package:datadashwallet/features/home/apps/apps.dart';
import 'package:flutter/material.dart';
import 'package:wallet_connect/wallet_connect.dart';
import 'package:web3_provider/web3_provider.dart';

import 'open_app_state.dart';

final openAppPageContainer =
    PresenterContainerWithParameter<OpenAppPresenter, OpenAppState, DAppCard>(
        (dapp) => OpenAppPresenter(dapp));

class OpenAppPresenter extends CompletePresenter<OpenAppState> {
  OpenAppPresenter(this.dapp) : super(OpenAppState());

  final DAppCard dapp;

  late final _walletUseCase = ref.read(walletUseCaseProvider);
  late WCClient _walletConnectClient;

  @override
  void initState() {
    super.initState();

    initDApp();
  }

  @override
  Future<void> dispose() {
    return super.dispose();
  }

  Future<void> initDApp() async {
    _walletConnectClient = WCClient(
      onSessionRequest: _onSessionRequest,
      onFailure: _onSessionError,
    );
    final address = await _walletUseCase.getPublicAddress();
    notify(() => state.address = address);
  }

  connectWalletHandler(String value) {
    if (value.contains('bridge') && value.contains('key')) {
      final session = WCSession.from(value);

      final peerMeta = WCPeerMeta(
        name: dapp.name,
        url: dapp.url!,
        description: dapp.description,
        icons: [],
      );
      _walletConnectClient.connectNewSession(
          session: session, peerMeta: peerMeta);
    }
  }

  void onWebViewCreated(InAppWebViewController controller) =>
      notify(() => state.webviewController = controller);

  _onSessionRequest(int id, WCPeerMeta peerMeta) async {
    _walletConnectClient.approveSession(
      accounts: [state.address!.hex],
      chainId: Sys.chainId,
    );
  }

  _onSessionError(dynamic error) => addError(error);
}
