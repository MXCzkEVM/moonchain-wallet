import 'package:mxc_logic/mxc_logic.dart';
import 'package:datadashwallet/core/core.dart';

class GesturesInstructionRepository extends GlobalCacheRepository {
  @override
  String get zone => 'gestures-instruction';

  late final Field<bool> educated = fieldWithDefault('educated', false);

  void setEducated(bool value) => educated.value = value;
}
