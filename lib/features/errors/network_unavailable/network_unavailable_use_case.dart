import 'package:connectivity_plus/connectivity_plus.dart';

class NetworkUnavailableUseCase {
  NetworkUnavailableUseCase();

  final Connectivity _connectivity = Connectivity();

  /// Streams which exposes [true] if network is available, [false] otherwise
  Stream<bool> get stream => Connectivity()
      .onConnectivityChanged
      .map((e) => e != ConnectivityResult.none)
      .distinct();

  /// Returns [true] if network is available.
  Future<bool> check() async {
    final connectivity = await _connectivity.checkConnectivity();
    return connectivity != ConnectivityResult.none;
  }
}
