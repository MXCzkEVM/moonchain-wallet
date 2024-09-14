import 'package:moonchain_wallet/core/core.dart';
import 'package:moonchain_wallet/features/settings/settings.dart';

import 'theme_settings_state.dart';

final themeSettingsContainer =
    PresenterContainer<ThemeSettingsPresenter, ThemeSettingsState>(
        () => ThemeSettingsPresenter());

class ThemeSettingsPresenter extends CompletePresenter<ThemeSettingsState> {
  ThemeSettingsPresenter() : super(ThemeSettingsState());

  late final ThemeUseCase _themeUseCase = ref.read(themeUseCaseProvider);

  @override
  void initState() {
    listen<ThemeOption>(
      _themeUseCase.currentTheme,
      (value) => notify(() => state.option = value),
    );
  }

  void changeThemeOption(ThemeOption option) {
    _themeUseCase.setCurrentTheme(option);
  }
}
