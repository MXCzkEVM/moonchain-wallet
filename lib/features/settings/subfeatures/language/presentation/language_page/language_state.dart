import 'package:moonchain_wallet/features/settings/settings.dart';
import 'package:equatable/equatable.dart';

class LanguageState with EquatableMixin {
  late Language? currentLanguage;
  late final List<Language> languages;

  @override
  List<Object?> get props => [
        currentLanguage,
        languages,
      ];
}
