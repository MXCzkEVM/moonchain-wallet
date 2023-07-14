import 'package:mxc_logic/mxc_logic.dart';
import 'package:datadashwallet/core/core.dart';

class BalanceRepository extends ControlledCacheRepository {
  @override
  final String zone = 'balance-history';

  late final Field<List<BalanceData>> balanceHistory =
      fieldWithDefault<List<BalanceData>>(
    'items',
    [],
    serializer: (b) => b
        .map((e) => {
              'balance': e.balance,
              'timeStamp': e.timeStamp.toString(),
            })
        .toList(),
    deserializer: (b) {
      final bList = (b as List)
          .map((e) => BalanceData(
                balance: e['balance'],
                timeStamp: DateTime.parse(e['timeStamp']),
              ))
          .toList();

      // Filtering the data for only 7 days data
      final now = DateTime.now();
      final sevenDaysAgo = now.subtract(const Duration(days: 7));

      return bList
          .where((data) => data.timeStamp.isAfter(sevenDaysAgo))
          .toList();
    },
  );

  List<BalanceData> get items => balanceHistory.value;

  void addItem(BalanceData item) {
    // if already added today update It
    final itemIndex = balanceHistory.value.indexWhere((e) =>
        e.timeStamp.day == item.timeStamp.day &&
        e.timeStamp.month == item.timeStamp.month &&
        e.timeStamp.year == item.timeStamp.year);
    if (itemIndex == -1) {
      // doesn't exist
      balanceHistory.value = [...balanceHistory.value, item];
    } else {
      // print(item);
      final newList = balanceHistory.value;
      newList.removeAt(itemIndex);
      newList.insert(itemIndex, item);
      balanceHistory.value = newList;
    }
  }

  void removeItem(BalanceData item) => balanceHistory.value =
      balanceHistory.value.where((e) => e.timeStamp != item.timeStamp).toList();
}
