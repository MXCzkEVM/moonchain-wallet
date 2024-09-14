import 'package:moonchain_wallet/core/core.dart';
import 'theme_cache_repository.dart';
import 'theme_option.dart';

class ThemeUseCase extends ReactiveUseCase {
  ThemeUseCase(this._repository);

  final ThemeCacheRepository _repository;

  late final ValueStream<ThemeOption> currentTheme =
      reactiveField(_repository.themeOption);

  void setCurrentTheme(ThemeOption option) => update(currentTheme, option);
}
