import 'dart:async';

import 'package:datadashwallet/common/common.dart';
import 'package:datadashwallet/core/core.dart';
import 'package:datadashwallet/features/settings/subfeatures/chain_configuration/domain/chain_configuration_use_case.dart';
import 'package:mxc_logic/mxc_logic.dart';
import 'package:web3dart/web3dart.dart';

class TransactionsHistoryUseCase extends ReactiveUseCase {
  TransactionsHistoryUseCase(
      this._repository, this._web3Repository, this._chainConfigurationUseCase) {
    initTransactionHistoryListening();
  }

  final Web3Repository _web3Repository;
  final ChainConfigurationUseCase _chainConfigurationUseCase;

  final TransactionsHistoryRepository _repository;

  late final ValueStream<List<TransactionModel>> transactionsHistory =
      reactiveField(_repository.transactionsHistory);

  List<TransactionModel> getTransactionsHistory() => _repository.items;

  late final ValueStream<bool> shouldUpdateBalances = reactive(false);

  int? currentChainId;

  Map<String, StreamSubscription<TransactionReceipt?>> updatingTransactions =
      {};

  initTransactionHistoryListening() {
    transactionsHistory.listen(listenToTransactionsHistory);
  }

  listenToTransactionsHistory(List<TransactionModel> event) {
    final selectedNetwork = _chainConfigurationUseCase.selectedNetwork.value;
    if (selectedNetwork != null) {
      final chainId = selectedNetwork.chainId;
      checkChainChange(chainId);
      if (!Config.isMxcChains(chainId)) {
        checkForPendingTransactions();
      }
    }
  }

  void updateItem(TransactionModel item, {TransactionModel? newReplacement}) {
    final index = transactionsHistory.value.indexWhere(
      (element) => element.hash == item.hash,
    );

    if (index == -1) {
      _repository.addItem(newReplacement ?? item, index);
    } else {
      _repository.updateItem(
        newReplacement ?? item,
        index,
      );
    }

    update(transactionsHistory, _repository.items);
  }

  void removeAll() {
    _repository.removeAll();
    update(transactionsHistory, _repository.items);
  }

  void removeItem(TransactionModel item) {
    _repository.removeItem(item);
    update(transactionsHistory, _repository.items);
  }

  /// This function will spy on the given transaction
  void spyOnTransaction(
    TransactionModel item,
  ) {
    if (!updatingTransactions.keys.contains(item.hash)) {
      updatingTransactions[item.hash] =
          _web3Repository.tokenContract.spyTransaction(item.hash);

      updatingTransactions[item.hash]?.onData((receipt) {
        if (receipt?.status ?? false) {
          // success
          updatingTransactions[item.hash]?.cancel();

          // If there is no value, Put gas as value in tx History
          final itemValue = item.value ??
              (receipt!.gasUsed! * receipt.effectiveGasPrice!.getInWei)
                  .toString();

          final updatedItem =
              item.copyWith(status: TransactionStatus.done, value: itemValue);
          updateItem(
            updatedItem,
          );
          updatingTransactions.remove(item.hash);
          update(shouldUpdateBalances, true);
        }
      });
    }
  }

  void cancelSpyOnTransaction(String hash) {
    updatingTransactions[hash]?.cancel();
    updatingTransactions.remove(hash);
  }

  /// This function will run through all the transactions and will start spying on
  /// pending transactions
  void checkForPendingTransactions() async {
    final txList = transactionsHistory.value;
    final pendingTxList =
        txList.where((element) => element.status == TransactionStatus.pending);
    for (TransactionModel pendingTx in pendingTxList) {
      spyOnTransaction(
        pendingTx,
      );
    }
  }

  void spyOnUnknownTransaction(
    String hash,
    String address,
    Token token,
  ) async {
    TransactionInformation? receipt;

    receipt = await _web3Repository.tokenContract
        .getTransactionByHashCustomChain(hash);

    if (receipt != null) {
      final tx =
          TransactionModel.fromTransactionInformation(receipt, address, token);
      spyOnTransaction(tx);
      updateItem(
        tx,
      );
    }
  }

  void checkChainChange(int chainId) async {
    if (currentChainId != chainId) {
      final keys = updatingTransactions.keys.toList();
      for (String txHash in keys) {
        await updatingTransactions[txHash]?.cancel();
      }
      updatingTransactions.clear();
    }
    currentChainId = chainId;
  }

  void replaceSpeedUpTransaction(TransactionModel oldTransaction,
      TransactionModel newPendingTransaction, int chainId) {
    replaceTransaction(
        oldTransaction,
        newPendingTransaction,
        chainId,
        oldTransaction.action == TransactionActions.cancel
            ? TransactionActions.cancel
            : TransactionActions.speedUp);
  }

  void replaceCancelTransaction(TransactionModel oldTransaction,
      TransactionModel newPendingTransaction, int chainId) {
    replaceTransaction(oldTransaction, newPendingTransaction, chainId,
        TransactionActions.cancel);
  }

  void replaceTransaction(
      TransactionModel oldTransaction,
      TransactionModel newPendingTransaction,
      int chainId,
      TransactionActions transactionActions) {
    if (!Config.isMxcChains(chainId)) {
      newPendingTransaction =
          newPendingTransaction.copyWith(action: transactionActions);

      // Update transaction in DB
      updateItem(oldTransaction, newReplacement: newPendingTransaction);

      // Cancel spy on old pending transaction
      cancelSpyOnTransaction(oldTransaction.hash);

      // Start on spying on new pending transaction
      spyOnTransaction(
        newPendingTransaction,
      );
    }
  }
}
