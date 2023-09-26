import 'package:mxc_logic/mxc_logic.dart';

class TransactionHistoryModel {
  TransactionHistoryModel({
    required this.chainId,
    required this.txList,
  });

  int chainId;
  List<TransactionModel> txList;
}
