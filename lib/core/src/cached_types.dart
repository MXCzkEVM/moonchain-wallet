import 'package:decimal/decimal.dart';
import 'package:mxc_logic/internal.dart';

void registerCacheTypes(CacheManager manager) {
  manager.registerType<Decimal>(
    deserializer: (t) => Decimal.parse(t),
    serializer: (t) => t.toString(),
  );
  manager.registerType<DateTime>(
    deserializer: (t) => DateTime.parse(t),
    serializer: (t) => t.toString(),
  );
}
