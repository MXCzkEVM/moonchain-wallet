import 'package:equatable/equatable.dart';
import 'package:web3_provider/web3_provider.dart';
import 'package:web3dart/credentials.dart';

class OpenDAppState with EquatableMixin {
  String? wallletAddress;
  InAppWebViewController? webviewController;
  int progress = 0;

  @override
  List<Object?> get props => [
        wallletAddress,
        webviewController,
        progress,
      ];
}
