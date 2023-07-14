import 'package:datadashwallet/core/core.dart';
import 'package:mxc_logic/mxc_logic.dart';

class AccountCacheRepository extends ControlledCacheRepository {
  @override
  final String zone = 'account';

  late final Field<String?> publicAddress = field('public-address');
  late final Field<String?> privateKey = field('pravate-key');
}
