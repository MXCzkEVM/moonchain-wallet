import 'package:mxc_logic/mxc_logic.dart';
import 'package:moonchain_wallet/core/core.dart';

class DappsOrderRepository extends ControlledCacheRepository {
  @override
  String get zone => 'dapps-order';

  late final Field<List<String>> order = fieldWithDefault<List<String>>(
    'order',
    [],
    serializer: (v) => v.map((e) => {'url': e}).toList(),
    deserializer: (v) => (v as List).map((e) => e['url'] as String).toList(),
  );

  void setOrder(List<String> value) => order.value = [...value];
}
