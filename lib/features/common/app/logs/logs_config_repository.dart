import 'package:mxc_logic/mxc_logic.dart';
import 'package:moonchain_wallet/core/core.dart';

class LogsConfigRepository extends GlobalCacheRepository {
  @override
  final String zone = 'ogs_config';

  late final Field<bool> notImportantLogsEnabled = fieldWithDefault<bool>(
      'notImportantLogsEnabled', false,
      serializer: (b) => b,
      deserializer: (b) => b);


  bool get item => notImportantLogsEnabled.value;

  void updateItem(bool value) {
    notImportantLogsEnabled.value = value;
  }
}
