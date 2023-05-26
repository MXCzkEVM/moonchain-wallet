import 'package:datadashwallet/common/common.dart';
import 'package:datadashwallet/core/core.dart';
import 'package:datadashwallet/features/login/login_page.dart';
import 'package:datadashwallet/features/splash/splash.dart';
import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:datadashwallet/features/settings/settings.dart';
import 'package:mxc_ui/mxc_ui.dart';

final appNavigatorKey = GlobalKey<NavigatorState>();

class DataDashWallet extends HookConsumerWidget {
  const DataDashWallet({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final languageState = ref.watch(languageContainer.state);

    return AppThemeWrapper(
      child: Builder(
        builder: (context) => MaterialApp(
          theme: MxcTheme.of(context).toThemeData(),
          locale: languageState.language?.toLocale(),
          localizationsDelegates: [
            FlutterI18nDelegate(
              translationLoader: FileTranslationLoader(
                useCountryCode: true,
              ),
            ),
            GlobalMaterialLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
          ],
          supportedLocales: [
            for (final l in languageState.supportedLanguages) l.toLocale(),
          ],
          navigatorKey: appNavigatorKey,
          onGenerateRoute: (_) => null,
          builder: (context, child) {
            child = Navigator(
              key: appNavigatorKey,
              reportsRouteUpdateToEngine: true,
              onGenerateRoute: (s) {
                assert(s.name == '/', 'Named routes are not supported');
                return route(const SplashSetupWalletPage());
              },
            );

            // Close keyboard on tap. Default behavior on iOS.
            child = GestureDetector(
              onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
              child: child,
            );

            child = ScrollConfiguration(
              behavior: const MxcScrollBehavior(
                scrollPhysics: BouncingScrollPhysics(),
              ),
              child: child,
            );

            return child;
          },
        ),
      ),
    );
  }
}
