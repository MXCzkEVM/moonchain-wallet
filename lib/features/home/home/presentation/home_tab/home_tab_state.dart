import 'package:datadashwallet/features/home/apps/apps.dart';
import 'package:equatable/equatable.dart';
import 'package:mxc_logic/mxc_logic.dart';
import 'package:web3dart/web3dart.dart';

class HomeTabState extends Equatable {
  String _walletBalance = "0.0";
  set walletBalance(String value) => _walletBalance = value;
  String get walletBalance => _walletBalance;

  WannseeTransactionsModel? _txList = null;
  set txList(WannseeTransactionsModel? value) => _txList = value;
  WannseeTransactionsModel? get txList => _txList;

  DefaultTokens _defaultTokens = DefaultTokens();
  set defaultTokens(DefaultTokens value) => _defaultTokens = value;
  DefaultTokens get defaultTokens => _defaultTokens;

  EthereumAddress? _walletAddress = null;
  set walletAddress(EthereumAddress? value) => _walletAddress = value;
  EthereumAddress? get walletAddress => _walletAddress;

  @override
  List<Object?> get props =>
      [walletBalance, _txList, defaultTokens, walletAddress];
}
