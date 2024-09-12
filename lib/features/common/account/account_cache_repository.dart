import 'package:moonchain_wallet/core/core.dart';
import 'package:mxc_logic/mxc_logic.dart';

class AccountCacheRepository extends GlobalCacheRepository {
  @override
  final String zone = 'account';

  late final Field<Account?> account = fieldWithDefault('current-account', null,
      serializer: (s) => {
            'name': s?.name,
            'mns': s?.mns,
            'privateKey': s?.privateKey,
            'address': s?.address,
            'isCustom': s?.isCustom
          },
      deserializer: (i) => Account(
            name: i['name'],
            mns: i['mns'],
            privateKey: i['privateKey'],
            address: i['address'],
            isCustom: (i as Map<String, dynamic>).containsKey('isCustom')
                ? i['isCustom']
                : false,
          ));
  late final Field<String?> publicAddress = field('public-address');
  late final Field<String?> privateKey = field('pravate-key');

  late final Field<double> xsdConversionRate =
      fieldWithDefault('xsd-conversion-rate', 1.0);

  late final Field<List<Account>> accounts = fieldWithDefault<List<Account>>(
      'items', [],
      serializer: (t) => t
          .map((e) => {
                'name': e.name,
                'mns': e.mns,
                'privateKey': e.privateKey,
                'address': e.address,
                'isCustom': e.isCustom
              })
          .toList(),
      deserializer: (t) => (t as List)
          .map((e) => Account(
              name: e['name'],
              mns: e['mns'],
              privateKey: e['privateKey'],
              address: e['address'],
              // This key is new so It wil handle in old versions
              isCustom: (e as Map<String, dynamic>).containsKey('isCustom')
                  ? e['isCustom']
                  : false))
          .toList());

  List<Account> get accountItems => accounts.value;
  Account get accountItem => account.value!;

  void addAccount(Account item, {int? index}) {
    if (index == null) {
      accounts.value = [...accounts.value, item];
    } else {
      final newList = accounts.value;
      newList.insert(index, item);
      accounts.value = newList;
    }
  }

  void removeAccount(Account item) => accounts.value =
      accounts.value.where((e) => e.address != item.address).toList();

  void updateAccount(Account item) => accounts.value = accounts.value.map((e) {
        if (item.address == account.value!.address) {
          account.value = item;
        }
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
