import 'package:mxc_logic/mxc_logic.dart';
import 'package:datadashwallet/core/core.dart';

class DappsOrderRepository extends GlobalCacheRepository {
  @override
  String get zone => 'dapps-order';

  late final Field<List<String>> order =
      fieldWithDefault<List<String>>('order', []);

  void setOrder(List<String> value) => order.value = value;
}
