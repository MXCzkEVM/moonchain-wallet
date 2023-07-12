import 'package:mxc_logic/mxc_logic.dart';
import 'package:datadashwallet/core/core.dart';

class BalanceRepository extends ControlledCacheRepository {
  @override
  String get zone => 'balance_history';

  late final Field<List<BalanceData>> balanceHistory =
      fieldWithDefault<List<BalanceData>>(
    'items',
    [],
    serializer: (t) => t
        .map((e) => {
              'balance': e.balance,
              'timeStamp': e.timeStamp,
            })
        .toList(),
    deserializer: (t) => (t as List)
        .map((e) => BalanceData(
              balance: e['balance'],
              timeStamp: e['timeStamp'],
            ))
        .toList(),
  );

  List<BalanceData> get items => balanceHistory.value;

  void addItem(BalanceData item) =>
      balanceHistory.value = [...balanceHistory.value, item];

  void removeItem(BalanceData item) => balanceHistory.value =
      balanceHistory.value.where((e) => e.timeStamp != item.timeStamp).toList();
}
