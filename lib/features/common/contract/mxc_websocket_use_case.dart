import 'dart:async';
import 'dart:convert';

import 'package:moonchain_wallet/app/app.dart';
import 'package:moonchain_wallet/common/common.dart';
import 'package:moonchain_wallet/core/core.dart';
import 'package:moonchain_wallet/features/common/common.dart';
import 'package:moonchain_wallet/features/settings/subfeatures/chain_configuration/domain/chain_configuration_use_case.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:mxc_logic/mxc_logic.dart';

class MXCWebsocketUseCase extends ReactiveUseCase {
  MXCWebsocketUseCase(
    this._repository,
    this._chainConfigurationUseCase,
    this._accountUseCase,
    this._functionUseCase,
  ) {
    initializeListeners();
  }

  final Web3Repository _repository;
  final ChainConfigurationUseCase _chainConfigurationUseCase;
  final AccountUseCase _accountUseCase;
  final FunctionUseCase _functionUseCase;

  late final ValueStream<Stream<dynamic>?> websocketStreamSubscription =
      reactive(null);
  StreamSubscription<dynamic>? websocketCloseStreamSubscription;
  late final ValueStream<Stream<dynamic>> addressStream =
      reactive(const Stream.empty());
  StreamSubscription<dynamic>? addressStreamSubscription;
  Account? account;

  void initializeListeners() {
    _chainConfigurationUseCase.selectedNetwork.listen((value) {
      if (value != null) {
        _functionUseCase.chainsFuncWrapper(
            () => Utils.retryFunction(initializeWebSocketConnection),
            clearStreamsSubscriptionAndDisconnect);
      }
    });

    _accountUseCase.account.listen(
      (value) {
        account = value;
        if (value != null && websocketStreamSubscription.hasValue) {
          _functionUseCase.onlyMXCChainsFuncWrapper(() async {
            final address = account!.address;
            Utils.retryFunction(() async {
              final subscription = await subscribeToAddressEvents(address);
              update(addressStream, subscription);
            });
          });
        }
      },
    );

    addressStream.listen((value) {
      _functionUseCase.onlyMXCChainsFuncWrapper(() {
        if (addressStreamSubscription != null) {
          addressStreamSubscription!.cancel();
        }
        addressStreamSubscription = value.listen(listenToTopUpEvents);
      });
    });

    websocketStreamSubscription.listen((value) {
      if (value != null) {
        final address = account!.address;
        Utils.retryFunction(() async {
          final subscription = await subscribeToAddressEvents(address);
          update(addressStream, subscription);
        });
      }
    });
  }

  void clearStreamsSubscriptionAndDisconnect() {
    disconnectWebsSocket();
  }

  void initializeWebSocketConnection() async {
    final selectedNetwork = _chainConfigurationUseCase.selectedNetwork.value;
    if (selectedNetwork!.web3WebSocketUrl?.isNotEmpty ?? false) {
      final subscription = await connectToWebsSocket();
      update(websocketStreamSubscription, subscription);
    }
  }

  Future<Stream<dynamic>> subscribeEvent(String event) async {
    if (_repository.tokenContract.isWebsocketConnected()) {
      return await _repository.tokenContract.subscribeEvent(
        event,
      );
    }
    throw "Websocket not connected!";
  }

  Future<Stream<dynamic>> connectToWebsSocket() async {
    return await _repository.tokenContract.connectToWebSocket();
  }

  void disconnectWebsSocket() {
    return _repository.tokenContract.disconnectWebSocket();
  }

  Stream<dynamic>? getCloseStream() {
    return _repository.tokenContract.getCloseStream();
  }

  void initializeCloseStream() {
    final closeStream = getCloseStream();
    websocketCloseStreamSubscription = closeStream!.listen((event) {
      websocketCloseStreamSubscription!.cancel();
      initializeWebSocketConnection();
    });
  }

  Future<Stream<dynamic>> subscribeToAddressEvents(String address) async {
    final res = await subscribeEvent(
      "addresses:$address".toLowerCase(),
    );
    return res;
  }

  void listenToTopUpEvents(dynamic event) {
    switch (event.event.value as String) {
      case 'transaction':
        final newMXCTx = WannseeTransactionModel.fromJson(
            json.encode(event.payload['transactions'][0]));

        final newTx =
            TransactionModel.fromMXCTransaction(newMXCTx, account!.address);

        if (newTx.token.symbol == Config.mxcName &&
            newTx.type == TransactionType.received) {
          final decimal = newTx.token.decimals ?? Config.ethDecimals;
          final formattedValue =
              MXCFormatter.convertWeiToEth(newTx.value ?? '0', decimal);
          showNotification(
              translate('mxc_top_up_notification_title'),
              translate('mxc_top_up_notification_text')
                  .replaceFirst(
                    '{0}',
                    account!.mns ??
                        MXCFormatter.formatWalletAddress(account!.address),
                  )
                  .replaceFirst('{1}', formattedValue));
        }
        // Sometimes getting the tx list from remote right away, results in having the pending tx in the list too (Which shouldn't be)
        break;
      default:
    }
  }

  String translate(String key) {
    return FlutterI18n.translate(appNavigatorKey.currentContext!, key);
  }
}
