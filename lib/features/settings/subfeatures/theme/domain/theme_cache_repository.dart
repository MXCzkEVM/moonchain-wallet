import 'package:mxc_logic/mxc_logic.dart';

import 'package:moonchain_wallet/common/serialization.dart';
import 'package:moonchain_wallet/core/core.dart';

import 'theme_option.dart';

class ThemeCacheRepository extends GlobalCacheRepository {
  @override
  final String zone = 'theme';

  late final Field<ThemeOption> themeOption = fieldWithDefault(
    'themeOption',
    ThemeOption.dark,
    deserializer: enumDeserializer(ThemeOption.values),
    serializer: enumSerializer<ThemeOption>(),
  );
}
