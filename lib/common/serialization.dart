import 'package:mxc_logic/internal.dart';

Deserializer<T> enumDeserializer<T extends Enum>(List<T> values) {
  return (i) => values[i];
}

Serializer<T> enumSerializer<T extends Enum>() {
  return (T v) => v.index as dynamic;
}
