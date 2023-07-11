import 'package:mxc_logic/mxc_logic.dart';
import 'package:datadashwallet/core/core.dart';

class CustomTokensRepository extends ControlledCacheRepository {
  @override
  String get zone => 'custom_token';

  late final Field<List<Token>> tokens = fieldWithDefault<List<Token>>(
    'items',
    [],
    serializer: (t) => t
        .map((e) => {
              'name': e.name,
              'symbol': e.symbol,
              'decimals': e.decimals,
            })
        .toList(),
    deserializer: (t) => (t as List)
        .map((e) => Token(
              name: e['name'],
              symbol: e['symbol'],
              decimals: e['decimals'],
            ))
        .toList(),
  );

  List<Token> get items => tokens.value;

  void addItem(Token item) => tokens.value = [...tokens.value, item];

  void removeItem(Token item) =>
      tokens.value = tokens.value.where((e) => e.name != item.name).toList();
}
