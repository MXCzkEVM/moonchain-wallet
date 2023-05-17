import 'package:equatable/equatable.dart';
import 'package:datadashwallet/features/settings/settings.dart';

class LanguageState with EquatableMixin {
  late final List<Language> supportedLanguages;
  Language? language;

  @override
  List<Object?> get props => [
        language,
        supportedLanguages,
      ];
}
