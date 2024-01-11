import 'dart:async';
import 'dart:convert';
import 'package:datadashwallet/app/logger.dart';
import 'package:datadashwallet/common/common.dart';
import 'package:datadashwallet/core/core.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:background_fetch/background_fetch.dart';
import 'package:mxc_logic/mxc_logic.dart';
import 'package:http/http.dart';

import 'app/app.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // If you're going to use other Firebase services in the background, such as Firestore,
  // make sure you call `initializeApp` before using other Firebase services.
  print(message.data);
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await AXSNotification().setupFlutterNotifications();
  // Firebase triggers notifications Itself
  // axsNotification.showFlutterNotification(message);
  print('Handling a background message ${message.messageId}');
}

@pragma(
    'vm:entry-point') // Mandatory if the App is obfuscated or using Flutter 3.1+
void callbackDispatcher(HeadlessTask task) async {
  String taskId = task.taskId;
  bool isTimeout = task.timeout;
  if (isTimeout) {
    // This task has exceeded its allowed running-time.
    // You must stop what you're doing and immediately .finish(taskId)
    print("[BackgroundFetch] Headless task timed-out: $taskId");
    BackgroundFetch.finish(taskId);
    return;
  }
  await loadProviders();

  final container = ProviderContainer();
  final authUseCase = container.read(authUseCaseProvider);
  final chainConfigurationUseCase =
      container.read(chainConfigurationUseCaseProvider);
  final accountUseCase = container.read(accountUseCaseProvider);
  final backgroundFetchConfigUseCase =
      container.read(backgroundFetchConfigUseCaseProvider);

  final selectedNetwork =
      chainConfigurationUseCase.getCurrentNetworkWithoutRefresh();
  PeriodicalCallData periodicalCallData =
      backgroundFetchConfigUseCase.periodicalCallData.value;
  final chainId = selectedNetwork.chainId;

  final isLoggedIn = authUseCase.loggedIn;
  final web3Rpc = selectedNetwork.web3RpcHttpUrl;
  final account = accountUseCase.account.value;
  final lowBalanceLimit = periodicalCallData.lowBalanceLimit;
  final expectedTransactionFee = periodicalCallData.expectedTransactionFee;
  final lowBalanceLimitEnabled = periodicalCallData.lowBalanceLimitEnabled;
  final expectedTransactionFeeEnabled =
      periodicalCallData.expectedTransactionFeeEnabled;
  final lastEpoch = periodicalCallData.lasEpoch;
  final expectedEpochOccurrence = periodicalCallData.expectedEpochOccurrence;
  final expectedEpochOccurrenceEnabled =
      periodicalCallData.expectedEpochOccurrenceEnabled;
  final client = Client();

  final web3Client = Web3Client(
    web3Rpc,
    client,
  );

  // Make sure user is logged in
  if (isLoggedIn && Config.isMxcChains(chainId)) {
    AXSNotification().setupFlutterNotifications(shouldInitFirebase: false);

    if (lowBalanceLimitEnabled) {
      print("lowBalanceLimitEnabled");
      final balance = await web3Client
          .getBalance(EthereumAddress.fromHex(account!.address));
      final balanceDouble = balance.getInEther.toDouble();
      print("lowBalanceLimitEnabled $balanceDouble $lowBalanceLimit");
      if (balanceDouble < lowBalanceLimit) {
        AXSNotification().showNotification('Time to top up!',
            'Your balance is currently below $balanceDouble.');
      }
    }

    if (expectedTransactionFeeEnabled) {
      print("expectedTransactionFeeEnabled");

      final gasPrice = await web3Client.getGasPrice();
      final gasPriceDouble = gasPrice.getInEther.toDouble();
      final transactionFee = gasPriceDouble * Config.minerDAppGasLimit;

      print(
          "expectedTransactionFeeEnabled $transactionFee $expectedTransactionFee");
      if (transactionFee < expectedTransactionFee) {
        AXSNotification().showNotification(
            'Transaction fee below expected price!',
            'Transaction fee is currently $transactionFee MXC, Lower than $expectedTransactionFee MXC.');
      }
    }

    if (expectedEpochOccurrenceEnabled) {
      print('expectedEpochOccurrenceEnabled');
      final res = await client.get(Uri.parse(Urls.mepEpochList));
      if (res.statusCode == 200) {
        final epochDetails = MEPEpochDetails.fromJson(
            json.decode(res.body) as Map<String, dynamic>);

        final epochNumberString = epochDetails.epochDetails![0].epochNumber;
        final epochNumber = int.parse(epochNumberString!);

        print(
            "expectedEpochOccurrenceEnabled $lastEpoch $epochNumber $expectedEpochOccurrence");
        if (lastEpoch == 0) {
          periodicalCallData =
              periodicalCallData.copyWith(lasEpoch: epochNumber);
          return;
        }

        int epochQuantity = epochNumber - lastEpoch;

        if (expectedEpochOccurrence == epochQuantity) {
          periodicalCallData =
              periodicalCallData.copyWith(lasEpoch: epochNumber);
          AXSNotification().showNotification('Expected epoch just happened!',
              'The epoch that you were waiting for is now reached.');
        }
      }
    }

    backgroundFetchConfigUseCase.updateItem(periodicalCallData);
  } else {
    // terminate background fetch
    BackgroundFetch.stop(taskId);
  }
  BackgroundFetch.finish(taskId);
}

// Foreground
void callbackDispatcherForeGround(String task) async {
  // await loadProviders();

  final container = ProviderContainer();
  final chainConfigurationUseCase =
      container.read(chainConfigurationUseCaseProvider);

  print(chainConfigurationUseCase.getCurrentNetworkWithoutRefresh());
  // final isLoggedIn = authUseCase.loggedIn;
  //       final web3Rpc = periodicalCallData.web3Rpc;
  //       final account = periodicalCallData.account;
  //       final balanceLimit = periodicalCallData.lowBalanceLimit;
  //       final gasPriceLimit = periodicalCallData.gasPrice;
  //       final chainId = periodicalCallData.chainId;
  //       final client = Client();

  //       final web3Client = Web3Client(
  //         web3Rpc,
  //         client,
  //       );
  AXSNotification().setupFlutterNotifications(shouldInitFirebase: false);
  AXSNotification().showNotification(
      'Background task ${DateTime.now().toIso8601String()}', '');
  print('[BackgroundFetch] Headless event received.');
}

void main() {
  var onError = FlutterError.onError;
  FlutterError.onError = (FlutterErrorDetails details) {
    onError?.call(details);
    reportErrorAndLog(details);
  };

  runZoned(
    () async {
      WidgetsFlutterBinding.ensureInitialized();

      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );

      FirebaseMessaging.onBackgroundMessage(
          _firebaseMessagingBackgroundHandler);

      await dotenv.load(fileName: 'assets/.env');
      await initLogs();
      await loadProviders();

      final container = ProviderContainer();
      final authUseCase = container.read(authUseCaseProvider);
      final isLoggedIn = authUseCase.loggedIn;

      await Biometric.load();

      final appVersionUseCase = container.read(appVersionUseCaseProvider);
      await appVersionUseCase.checkLatestVersion();

      final initializationUseCase = container.read(chainsUseCaseProvider);
      initializationUseCase.updateChains();

      runApp(
        UncontrolledProviderScope(
          container: container,
          child: AxsWallet(
            isLoggedIn: isLoggedIn,
          ),
        ),
      );
    },
    zoneSpecification: ZoneSpecification(
      print: (Zone self, ZoneDelegate parent, Zone zone, String line) {
        collectLog(line);
        parent.print(zone, line);
      },
      handleUncaughtError: (Zone self, ZoneDelegate parent, Zone zone,
          Object error, StackTrace stackTrace) {
        reportErrorAndLog(
            FlutterErrorDetails(exception: error, stack: stackTrace));
        parent.print(zone, '${error.toString()} $stackTrace');
      },
    ),
  );
}
