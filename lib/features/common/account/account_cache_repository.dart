import 'package:datadashwallet/core/core.dart';
import 'package:mxc_logic/mxc_logic.dart';

class AccountCacheRepository extends ControlledCacheRepository {
  @override
  final String zone = 'account';

  late final Field<Account?> account = fieldWithDefault(
    'current-account',
    null,
    serializer: (s) => {
      'name': s?.name,
      'mns': s?.mns,
      'address': s?.address,
    },
    deserializer: (i) => Account(
      name: i['name'],
      mns: i['mns'],
      address: i['address'],
    ),
  );
  late final Field<String?> publicAddress = field('public-address');
  late final Field<String?> privateKey = field('pravate-key');

  late final Field<double> xsdConversionRate =
      fieldWithDefault('xsd-conversion-rate', 2.0);

  late final Field<List<Account>> accounts = fieldWithDefault<List<Account>>(
    'items',
    [],
    serializer: (t) => t
        .map((e) => {
              'name': e.name,
              'mns': e.mns,
              'address': e.address,
            })
        .toList(),
    deserializer: (t) => (t as List)
        .map((e) => Account(
              name: e['name'],
              mns: e['mns'],
              address: e['address'],
            ))
        .toList(),
  );

  List<Account> get accountItems => accounts.value;

  void addAccount(Account item) => accounts.value = [...accounts.value, item];
  void removeAccount(Account item) => accounts.value =
      accounts.value.where((e) => e.name != item.name).toList();
  void updateAccount(Account item) => accounts.value = accounts.value.map((e) {
        if (item.address == e.address) {
          e.mns = item.mns;
          return e;
        }
        return e;
      }).toList();
  void resetAccounts() => accounts.value = [];

  void setXsdConversionRate(double value) => xsdConversionRate.value = value;
  double getXsdConversionRate() => xsdConversionRate.value;

  void clear() => cleanFields([
        publicAddress,
        privateKey,
        xsdConversionRate,
        account,
        accounts,
      ]);
}
