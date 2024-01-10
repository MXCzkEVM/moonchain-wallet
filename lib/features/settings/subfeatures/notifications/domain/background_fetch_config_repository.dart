import 'package:mxc_logic/mxc_logic.dart';
import 'package:datadashwallet/core/core.dart';

class BackgroundFetchConfigRepository extends ControlledCacheRepository {
  @override
  final String zone = 'background-fetch-config';
  late final Field<PeriodicalCallData> periodicalCallData =
      fieldWithDefault<PeriodicalCallData>(
          'periodicalCallData', PeriodicalCallData.getDefault(),
          serializer: (b) => b.toMap(),
          deserializer: (b) => PeriodicalCallData.fromMap(b));

  PeriodicalCallData get item => periodicalCallData.value;

  void updateItem(PeriodicalCallData item) {
    periodicalCallData.value = item;
  }

  void removeItem(PeriodicalCallData item) =>
      periodicalCallData.value = PeriodicalCallData.getDefault();
}
