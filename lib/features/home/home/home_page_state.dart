import 'package:equatable/equatable.dart';
import 'package:datadashwallet/features/home/home.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:mxc_logic/mxc_logic.dart';
import 'package:web3dart/web3dart.dart';

class HomeState with EquatableMixin {
  int currentIndex = 0;

  String walletBalance = "0.0";

  WannseeTransactionsModel? txList;

  bool isTxListLoading = true;

  List<Token> tokensList = [];

  EthereumAddress? walletAddress;

  bool hideBalance = false;

  List<FlSpot> balanceSpots =  [];

  double chartMaxAmount = 1.0;

  double chartMinAmount = 0.0;

  @override
  List<Object?> get props => [
        currentIndex,
        walletBalance,
        txList,
        isTxListLoading,
        tokensList,
        walletAddress,
        hideBalance,
        chartMaxAmount,
        chartMinAmount,
        balanceSpots
      ];
}
