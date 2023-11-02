import 'package:mxc_logic/mxc_logic.dart';
import 'package:datadashwallet/core/core.dart';

class TransactionsHistoryRepository extends ControlledCacheRepository {
  @override
  final String zone = 'transaction-history';

  late final Field<List<TransactionModel>> transactionsHistory =
      fieldWithDefault<List<TransactionModel>>('items', [],
          serializer: (b) => b.map((e) => e.toMap()).toList(),
          deserializer: (b) =>
              (b as List).map((e) => TransactionModel.fromMap(e)).toList());

  List<TransactionModel> get items => transactionsHistory.value;

  void addItem(TransactionModel item, int index) {
    final newList = transactionsHistory.value;
    newList.insert(0, item);
    transactionsHistory.value = newList;
  }

  void updateItem(
    TransactionModel item,
    int index,
  ) {
    final newList = transactionsHistory.value;

    newList[index] = item;

    transactionsHistory.value = newList;
  }

  void removeItem(TransactionModel item) => transactionsHistory.value =
      transactionsHistory.value.where((e) => e.hash != item.hash).toList();

  void removeAll() => transactionsHistory.value = [];
}
