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

  void updateItem(
    TransactionModel item,
  ) {
    final index = transactionsHistory.value.indexWhere(
      (element) => element.hash == item.hash,
    );

    if (index == -1) {
      _repository.addItem(item, index);
    } else {
      _repository.updateItem(
        item,
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
      final tx = TransactionModel.fromTransaction(receipt, address, token);
      spyOnTransaction(tx);
      updateItem(
        tx,
      );
    }
  }

  void checkChainChange(int chainId) async {
    if (currentChainId != chainId) {
      for (String txHash in updatingTransactions.keys) {
        await updatingTransactions[txHash]?.cancel();
      }
      updatingTransactions.clear();
    }
    currentChainId = chainId;
  }
}
