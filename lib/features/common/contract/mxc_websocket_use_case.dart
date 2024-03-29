import 'dart:async';
import 'dart:convert';

import 'package:datadashwallet/app/app.dart';
import 'package:datadashwallet/common/common.dart';
import 'package:datadashwallet/core/core.dart';
import 'package:datadashwallet/features/common/common.dart';
import 'package:datadashwallet/features/settings/subfeatures/chain_configuration/domain/chain_configuration_use_case.dart';
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

  StreamSubscription<dynamic>? websocketStreamSubscription;
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
        if (value != null) {
          _functionUseCase.onlyMXCChainsFuncWrapper(() async {
            account = value;
            final address = value.address;
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
  }

  void clearStreamsSubscriptionAndDisconnect() {
    if (websocketStreamSubscription != null) {
      websocketStreamSubscription!.cancel();
    }
    disconnectWebsSocket();
  }

  void initializeWebSocketConnection() async {
    final selectedNetwork = _chainConfigurationUseCase.selectedNetwork.value;
    if (selectedNetwork!.web3WebSocketUrl?.isNotEmpty ?? false) {
      final isConnected = await connectToWebsSocket();
      if (isConnected) {
        initializeCloseStream();
      } else {
        throw 'Couldn\'t connect';
      }
    }
  }

  Future<Stream<dynamic>?> subscribeEvent(String event) async {
    return await _repository.tokenContract.subscribeEvent(
      event,
    );
  }

  Future<bool> connectToWebsSocket() async {
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
    if (res != null) {
      return res;
    } else {
      throw "Unable to subscribe to address events";
    }
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
