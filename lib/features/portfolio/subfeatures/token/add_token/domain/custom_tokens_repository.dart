import 'package:mxc_logic/mxc_logic.dart';
import 'package:moonchain_wallet/core/core.dart';

// NOTE: This repository is used to store custom tokens that are not specific to a account. It is used to store tokens that are used in the app globally, but not specific to a account.
// We are migrating from custom token repo to this repo 
// TODO: Remove global from begging 
class GlobalCustomTokensRepository extends GlobalCacheRepository {
  @override
  final String zone = 'global-custom-tokens';

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
