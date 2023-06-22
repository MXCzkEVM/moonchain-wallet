import 'package:datadashwallet/app/configuration.dart';
import 'package:datadashwallet/features/home/home.dart';
import 'package:ens_dart/ens_dart.dart';

import 'package:datadashwallet/core/core.dart';
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
  Future<void> dispose() {
    state.usernameController.dispose();
    _web3client.dispose();

    return super.dispose();
  }

  Future<void> queryNameAvailable() async {
    final ens = Ens(client: _web3client);
    final name = state.usernameController.text;

    try {
      final addr = await ens.withName(name).getAddress();
      state.isRegistered = ens.isRegistered(addr);

      notify();
    } catch (error, tackTrace) {
      addError(error, tackTrace);
    }
  }

  Future<void> claim() async => navigator?.push(route(HomePage()));
}
