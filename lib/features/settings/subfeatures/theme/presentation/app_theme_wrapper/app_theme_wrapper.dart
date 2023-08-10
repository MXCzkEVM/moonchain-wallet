import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:mxc_ui/mxc_ui.dart';
import 'app_theme_presenter.dart';

class AppThemeWrapper extends ConsumerWidget {
  const AppThemeWrapper({
    Key? key,
    required this.child,
  }) : super(key: key);

  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final darkMode = ref.watch(
      appThemeContainer.state.select((v) => v.darkMode),
    );

    return MxcTheme.fromOption(
      option: darkMode ? MxcThemeOption.night : MxcThemeOption.day,
      child: child,
    );
  }
}
