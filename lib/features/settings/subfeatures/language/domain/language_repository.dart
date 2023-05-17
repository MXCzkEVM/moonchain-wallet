import 'package:mxc_logic/mxc_logic.dart';
import 'package:datadashwallet/core/core.dart';

class LanguageRepository extends GlobalCacheRepository {
  final List<Language> supportedLocales = const [
    Language('en', 'English'),
    Language('zh_CN', '简体中文'),
    Language('zh_TW', '繁体中文'),
    Language('de', 'Deutsch'),
    Language('tr', 'Türkçe'),
    Language('ro', 'Română'),
    Language('nl', 'Nederlands'),
    Language('es', 'Español'),
    Language('fr', 'Français'),
    Language('ko', '한국어'),
    Language('ja', '日本語'),
    Language('ru', 'Русский'),
    Language('pt', 'Portugués'),
    Language('id', 'Indonesio'),
    Language('tl', 'Tagalog'),
    Language('vi', 'Tiếng Việt'),
  ];

  @override
  String get zone => 'language';

  late final Field<Language?> currentLocale = field(
    'currentLocale',
    serializer: (t) => t.code,
    deserializer: (c) => supportedLocales.firstWhere((e) => e.code == c),
  );
}

class Language {
  const Language(this.code, this.nativeName);

  final String code;
  final String nativeName;
}
