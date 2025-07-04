import 'dart:async';
import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:moonchain_wallet/app/logger.dart';
import 'package:mxc_logic/mxc_logic.dart';

class NetworkUnavailableUseCase {
  NetworkUnavailableUseCase() {
    startWeakConnectionStream();
  }

  final Connectivity _connectivity = Connectivity();

  /// Streams which exposes [true] if network is available, [false] otherwise
  Stream<bool> get stream => Connectivity()
      .onConnectivityChanged
      .map((e) => e != ConnectivityResult.none)
      .distinct();

  Stream<bool> get weakConnectionStream =>
      _weakConnectionStreamController.stream;

  final _weakConnectionStreamController = StreamController<bool>();

  /// Returns [true] if network is available.
  Future<bool> check() async {
    final connectivity = await _connectivity.checkConnectivity();
    return connectivity != ConnectivityResult.none;
  }

  startWeakConnectionStream() {
    Timer.periodic(Config.weakInternetConnectionCheckDuration, (event) async {
      final isWeak = await checkWeakConnection();
      if (isWeak) {
        _weakConnectionStreamController.sink.add(true);
      } else {
        _weakConnectionStreamController.sink.add(false);
      }
    });
  }

  /// Returns [true] if network is weak and weak.
  Future<bool> checkWeakConnection(
      {Duration timeout = Config.httpClientTimeOut}) async {
    final stopwatch = Stopwatch()..start();
    try {
      final result = await InternetAddress.lookup('google.com')
          .timeout(timeout); 
      stopwatch.stop();

      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        final latencyMs = stopwatch.elapsedMilliseconds;
        collectLog('DNS latency: $latencyMs ms');
        return latencyMs > 800; 
      }
    } catch (_) {
      stopwatch.stop();
      // Looks like there is no connection so We will show No connection snackbar
      return false;
    }
    return false;
  }
}
