import 'package:equatable/equatable.dart';
import 'package:web3_provider/web3_provider.dart';
import 'package:web3dart/credentials.dart';

class OpenAppState with EquatableMixin {
  EthereumAddress? address;
  InAppWebViewController? webviewController;

  @override
  List<Object?> get props => [
        address,
        webviewController,
      ];
}
