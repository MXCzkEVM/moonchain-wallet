import 'package:datadashwallet/features/settings/settings.dart';
import 'package:equatable/equatable.dart';

class LanguagePageState with EquatableMixin {
  late Language? currentLanguage;
  late final List<Language> languages;

  @override
  List<Object?> get props => [
        currentLanguage,
        languages,
      ];
}
