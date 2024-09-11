import 'dart:ui';

import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';
import 'package:moonchain_wallet/core/core.dart';
import 'package:moonchain_wallet/features/settings/settings.dart';

import 'app_theme_state.dart';

final appThemeContainer = PresenterContainer<AppThemePresenter, AppThemeState>(
    () => AppThemePresenter());

class AppThemePresenter extends Presenter<AppThemeState>
    with LoadingPresenter, ErrorPresenter {
  AppThemePresenter() : super(AppThemeState());

  ThemeUseCase get _themeUseCase => ref.read(themeUseCaseProvider);

  bool get _isSystemDarkMode =>
      SchedulerBinding.instance.window.platformBrightness == Brightness.dark;

  @override
  void initState() {
    super.initState();
    state.darkMode = _darkThemeShouldBeShown();
    listen<ThemeOption>(_themeUseCase.currentTheme, (_) => refreshTheme());
    WidgetsBinding.instance.window.onPlatformBrightnessChanged =
        () => refreshTheme();
  }

  void refreshTheme() {
    notify(() => state.darkMode = _darkThemeShouldBeShown());
  }

  bool _darkThemeShouldBeShown() {
    switch (_themeUseCase.currentTheme.value) {
      case ThemeOption.system:
        return _isSystemDarkMode;
      case ThemeOption.dark:
        return true;
      case ThemeOption.light:
        return false;
    }
  }

  @override
  Future<void> dispose() async {
    super.dispose();
    WidgetsBinding.instance.window.onPlatformBrightnessChanged = null;
  }
}
