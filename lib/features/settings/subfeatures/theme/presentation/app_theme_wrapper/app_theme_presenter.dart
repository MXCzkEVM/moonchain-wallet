import 'dart:ui';

import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';
import 'package:datadashwallet/core/core.dart';
import 'package:datadashwallet/features/settings/settings.dart';

import 'app_theme_state.dart';

final appThemeContainer = PresenterContainer<AppThemePresenter, AppThemeState>(
    () => AppThemePresenter());

class AppThemePresenter extends Presenter<AppThemeState>
    with LoadingPresenter, ErrorPresenter {
  AppThemePresenter() : super(AppThemeState());

  ThemeUseCase get _useCase => ref.read(themeUseCaseProvider);

  bool get _isSystemDarkMode =>
      SchedulerBinding.instance.window.platformBrightness == Brightness.dark;

  @override
  void initState() {
    super.initState();
    state.darkMode = _darkThemeShouldBeShown();
    listen<ThemeOption>(_useCase.currentTheme, (_) => refreshTheme());
    WidgetsBinding.instance.window.onPlatformBrightnessChanged =
        () => refreshTheme();
  }

  void refreshTheme() {
    notify(() => state.darkMode = _darkThemeShouldBeShown());
  }

  bool _darkThemeShouldBeShown() {
    switch (_useCase.currentTheme.value) {
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
