import 'package:equatable/equatable.dart';
import 'package:datadashwallet/features/home/home.dart';
import 'package:mxc_logic/mxc_logic.dart';
import 'package:web3dart/web3dart.dart';

class HomeState with EquatableMixin {
  int currentIndex = 0;

  bool isEditMode = false;

  String walletBalance = "0.0";

  WannseeTransactionsModel? txList;

  bool isTxListLoading = true;

  DefaultTokens defaultTokens = DefaultTokens();

  EthereumAddress? walletAddress;

  bool hideBalance = false;

  @override
  List<Object?> get props => [
        currentIndex,
        isEditMode,
        walletBalance,
        txList,
        isTxListLoading,
        defaultTokens,
        walletAddress,
        hideBalance
      ];
}
