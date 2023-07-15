import 'package:datadashwallet/app/configuration.dart';
import 'package:datadashwallet/features/home/apps/apps.dart';
import 'package:datadashwallet/features/home/apps/entities/bookmark.dart';
import 'package:datadashwallet/features/home/apps/subfeatures/open_dapp/open_dapp_page.dart';
import 'package:datadashwallet/features/home/home.dart';
import 'package:ens_dart/ens_dart.dart';

import 'package:datadashwallet/core/core.dart';
import 'package:flutter/material.dart';
import 'mns_query_state.dart';
import 'package:http/http.dart';
import 'package:web3dart/web3dart.dart';
import 'package:web_socket_channel/io.dart';

final splashMNSQueryContainer =
    PresenterContainer<SplashMNSQueryPresenter, SplashMNSQueryState>(
        () => SplashMNSQueryPresenter());

class SplashMNSQueryPresenter extends CompletePresenter<SplashMNSQueryState> {
  SplashMNSQueryPresenter() : super(SplashMNSQueryState());

  late final Web3Client _web3client;
  late final Ens _ens;
  late final TextEditingController usernameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _web3client = Web3Client(Sys.rpcUrl, Client(), socketConnector: () {
      return IOWebSocketChannel.connect(Sys.wsUrl).cast<String>();
    });
    _ens = Ens(client: _web3client, chainId: Sys.chainId);
  }

  @override
  Future<void> dispose() async {
    _web3client.dispose();

    super.dispose();
  }

  Future<void> queryNameAvailable() async {
    final name = usernameController.text;
    loading = true;

    try {
      final res = await _ens.withName(name).getAddress();
      final valid = validateRegistered(res.hex);
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
        ?.push(route.featureDialog(OpenAppPage(
            bookmark: Bookmark(
      id: 0,
      title: 'MNS',
      description: 'Own your .MXC domain',
      url: 'https://wannsee-mns.mxc.com/$name.mxc/register',
    ))))
        .then((_) {
      navigator?.replaceAll(route(const HomePage()));
    });
  }
}
