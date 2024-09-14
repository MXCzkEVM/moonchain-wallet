import 'package:mxc_logic/mxc_logic.dart';
import 'package:moonchain_wallet/core/core.dart';

class CustomTokensRepository extends ControlledCacheRepository {
  @override
  final String zone = 'custom-token';

  late final Field<List<Token>> tokens = fieldWithDefault<List<Token>>(
    'items',
    [],
    serializer: (t) => t
        .map((e) => {
              'name': e.name,
              'symbol': e.symbol,
              'decimals': e.decimals,
              'address': e.address,
              'balance': e.balance,
              'chainId': e.chainId,
              'logoUri': e.logoUri
            })
        .toList(),
    deserializer: (t) => (t as List)
        .map((e) => Token(
              name: e['name'],
              symbol: e['symbol'],
              decimals: e['decimals'],
              address: e['address'],
              balance: e['balance'],
              chainId: e['chainId'],
              logoUri: e['logoUr'],
            ))
        .toList(),
  );

  List<Token> get items => tokens.value;

  void addItem(Token item) => tokens.value = [...tokens.value, item];

  void removeAll() => tokens.value = [];

  void removeItem(Token item) =>
      tokens.value = tokens.value.where((e) => e.name != item.name).toList();
}
