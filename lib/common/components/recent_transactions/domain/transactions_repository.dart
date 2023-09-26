import 'package:datadashwallet/common/components/recent_transactions/entity/transaction_history_model.dart';
import 'package:mxc_logic/mxc_logic.dart';
import 'package:datadashwallet/core/core.dart';

class TransactionsHistoryRepository extends ControlledCacheRepository {
  @override
  final String zone = 'transaction-history';

  late final Field<List<TransactionHistoryModel>> transactionsHistory =
      fieldWithDefault<List<TransactionHistoryModel>>('items', [],
          serializer: (b) => b
              .map((e) => {
                    'chainId': e.chainId,
                    'txList': e.txList.map((e) => e.toMap()).toList()
                  })
              .toList(),
          deserializer: (b) => (b as List)
              .map((e) => TransactionHistoryModel(
                    chainId: e['chainId'],
                    txList: (e['txList'] as List)
                        .map((e) => TransactionModel.fromMap(e))
                        .toList(),
                  ))
              .toList());

  List<TransactionHistoryModel> get items => transactionsHistory.value;

  void addItem(TransactionHistoryModel item) =>
      transactionsHistory.value = [...transactionsHistory.value, item];

  void addItemTx(TransactionModel item, int index) {
    final newList = transactionsHistory.value;
    newList[index].txList.insert(0, item);
    transactionsHistory.value = newList;
  }

  void updateItem(TransactionHistoryModel item, int index) {
    final newList = transactionsHistory.value;
    newList.removeAt(index);
    newList.insert(index, item);
    transactionsHistory.value = newList;
  }

  void updateItemTx(TransactionModel item, int index, int txIndex) {
    final newList = transactionsHistory.value;

    newList[index].txList[txIndex] = item;

    transactionsHistory.value = newList;
  }

  void removeItem(TransactionHistoryModel item) =>
      transactionsHistory.value = transactionsHistory.value
          .where((e) => e.chainId != item.chainId)
          .toList();

  void removeAll() => transactionsHistory.value = [];
}
