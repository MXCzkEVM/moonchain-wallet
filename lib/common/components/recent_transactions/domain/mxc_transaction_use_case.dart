import 'package:datadashwallet/common/common.dart';
import 'package:datadashwallet/core/core.dart';
import 'package:mxc_logic/mxc_logic.dart';
import 'package:web3dart/web3dart.dart';


class MXCTransactionsUseCase extends ReactiveUseCase {
  MXCTransactionsUseCase(this._web3Repository);

  final Web3Repository _web3Repository;

  /// Will remove token transfer (tx that are in general transaction) from general transaction
  List<WannseeTransactionModel> removeTokenTransfersFromTxList(
      List<WannseeTransactionModel> txList,
      List<TokenTransfer> tokenTransferList) {
    return txList.where((element) {
      if (element.hash != null) {
        // 1. Delete if txHash is null
        // 2. Delete if tx is token transfer
        return tokenTransferList.indexWhere(
                (e) => e.txHash == null ? true : e.txHash == element.hash) ==
            -1;
      } else {
        return false;
      }
    }).toList();
  }

  void addTokenTransfersToTxList(List<WannseeTransactionModel> txList,
      List<TokenTransfer> tokenTransferList) {
    for (int i = 0; i < tokenTransferList.length; i++) {
      final item = tokenTransferList[i];
      txList.add(WannseeTransactionModel(tokenTransfers: [item]));
    }
  }

  List<WannseeTransactionModel> keepOnlySixTransactions(
    List<WannseeTransactionModel> txList,
  ) {
    if (txList.length > 6) {
      return txList.sublist(0, 6);
    }
    return txList;
  }

  void sortByDate(List<WannseeTransactionModel> txList) {
    if (txList.isNotEmpty) {
      txList.sort((a, b) {
        // If not simple transaction If not token transfer Then It is pending tx
        final item1 =
            a.timestamp ?? a.tokenTransfers?[0].timestamp ?? DateTime.now();
        final item2 =
            b.timestamp ?? b.tokenTransfers?[0].timestamp ?? DateTime.now();

        return item2.compareTo(item1);
      });
    }
  }

  List<TransactionModel> axsTxListFromMxcTxList(
      List<WannseeTransactionModel> mxcTxList, String walletAddress) {
    return mxcTxList
        .map((e) => TransactionModel.fromMXCTransaction(e, walletAddress))
        .toList();
  }

  void removeInvalidTx(List<TransactionModel> txList) {
    txList.removeWhere(
      (element) => element.hash == "Unknown",
    );
  }

  List<WannseeTransactionModel> applyTxDateLimit(
      List<WannseeTransactionModel> txList) {
    final sevenDays = DateTime.now()
        .subtract(Duration(days: Config.transactionsHistoryLimit));
    return txList.where((element) {
      if (element.timestamp != null) {
        return element.timestamp!.isAfter(sevenDays);
      }
      return element.tokenTransfers![0].timestamp!.isAfter(sevenDays);
    }).toList();
  }
}
