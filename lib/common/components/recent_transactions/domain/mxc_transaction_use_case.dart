import 'package:collection/collection.dart';
import 'package:moonchain_wallet/common/common.dart';
import 'package:moonchain_wallet/core/core.dart';
import 'package:moonchain_wallet/features/common/common.dart';
import 'package:mxc_logic/mxc_logic.dart';
import 'package:web3dart/web3dart.dart';

class MXCTransactionsUseCase extends ReactiveUseCase {
  MXCTransactionsUseCase(this._web3Repository, this._tokenContractUseCase);

  final Web3Repository _web3Repository;
  final TokenContractUseCase _tokenContractUseCase;

  Future<List<TransactionModel>?> getMXCTransactions(
      String walletAddress) async {
    // transactions list contains all the kind of transactions
    // It's going to be filtered to only have native coin transfer
    return await _tokenContractUseCase
        .getTransactionsByAddress(walletAddress)
        .then((newTransactionsList) async {
      // token transfer list contains only one kind transaction which is token transfer
      final newTokenTransfersList =
          await _tokenContractUseCase.getTokenTransfersByAddress(walletAddress);

      if (newTokenTransfersList != null && newTransactionsList != null) {
        // loading over and we have the data
        // merge
        if (newTransactionsList.items != null &&
            newTokenTransfersList.items != null) {
          // Separating token transfer from all transaction since they have different structure
          newTransactionsList = newTransactionsList.copyWith(
              items: removeTokenTransfersFromTxList(
                  newTransactionsList.items!, newTokenTransfersList.items!));
        }

        if (newTokenTransfersList.items != null) {
          addTokenTransfersToTxList(
              newTransactionsList.items!, newTokenTransfersList.items!);

          sortByDate(newTransactionsList.items!);

          final finalTxList =
              axsTxListFromMxcTxList(newTransactionsList.items!, walletAddress);

          removeInvalidTx(finalTxList);

          final newTxList = checkPendingTx(finalTxList);
          return newTxList;
        }
      } else {
        return null;
      }
    });
  }

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

  List<TransactionModel> applyTxDateLimit(List<TransactionModel> txList) {
    final sevenDays = DateTime.now()
        .subtract(Duration(days: Config.transactionsHistoryLimit));
    return txList.where((element) {
      return element.timeStamp != null
          ? element.timeStamp!.isAfter(sevenDays)
          : false;
    }).toList();
  }

  List<TransactionModel> checkPendingTx(List<TransactionModel> txList) {
    // If txs with same nonce
    // keep only the last one
    // Show buttons
    // If from to this account cancel operation otherwise It's speed up
    final pendingTransactions = txList
        .where((element) => element.status == TransactionStatus.pending)
        .toList();

    final pendingTxMap =
        pendingTransactions.groupListsBy((element) => element.nonce);

    for (List<TransactionModel> group in pendingTxMap.values.toList()) {
      if (group.isNotEmpty) {
        final latestTransaction = group.first;
        if (group.length > 1) {
          final isCancel = isCancelOperation(latestTransaction);
          if (isCancel) {
            txList[0] =
                latestTransaction.copyWith(action: TransactionActions.cancel);
          } else {
            txList[0] =
                latestTransaction.copyWith(action: TransactionActions.speedUp);
          }
          // Remove all transaction except the latest one
          for (TransactionModel transaction in group) {
            txList.removeWhere((element) =>
                element.hash == transaction.hash &&
                element.hash != latestTransaction.hash);
          }
        }
      }
    }

    return txList;
  }

  bool isCancelOperation(TransactionModel transaction) {
    if (transaction.from == transaction.to && transaction.value == '0') {
      return true;
    }
    return false;
  }
}
