import 'package:moonchain_wallet/core/core.dart';

import 'language_repository.dart';

class LanguageUseCase extends ReactiveUseCase {
  LanguageUseCase(this._repository);
  final LanguageRepository _repository;

  List<Language> get supportedLocales => _repository.supportedLocales;

  late final ValueStream<Language?> currentLocale =
      reactiveField(_repository.currentLocale);

  void setCurrentLocale(Language? l) => update(currentLocale, l);
}
