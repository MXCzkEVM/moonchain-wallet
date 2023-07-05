import 'package:datadashwallet/app/configuration.dart';
import 'package:datadashwallet/features/home/apps/apps.dart';
import 'package:datadashwallet/features/home/apps/subfeatures/open_dapp/open_dapp_page.dart';
import 'package:datadashwallet/features/home/home.dart';
import 'package:datadashwallet/features/splash/mns_process/data/ens_format.dart';
import 'package:datadashwallet/features/splash/mns_process/data/mns_service.dart';
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
  late final TextEditingController usernameController = TextEditingController();

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
    final name = usernameController.text;

    try {
      final res = await MnsService.queryNameAvailable(name);
      final valid = validateRegistered(res);
      notify(() => state.errorText = valid);

      if (valid == null) {
        claim(name);
      }
    } catch (error, tackTrace) {
      addError(error, tackTrace);
    }
  }

  String? validateRegistered(String value) {
    final name = ENSFormat.strip0x(value);
    if (name.isEmpty) return 'result: $value';

    if (BigInt.parse(name, radix: 16) != BigInt.zero) {
      return translate('domain_registered');
    }

    return null;
  }

  Future<void> claim(String name) async {
    navigator?.push(
      route.featureDialog(
        OpenAppPage(
          dapp: DApp(
            name: 'MNS',
            description: 'Own your .MXC domain',
            url: 'https://wannsee-mns.mxc.com/$name.mxc/register',
          ),
        ),
      ),
    );
  }
}
