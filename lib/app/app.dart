import 'package:moonchain_wallet/app/app_presenter.dart';
import 'package:moonchain_wallet/common/common.dart';
import 'package:moonchain_wallet/core/core.dart';
import 'package:moonchain_wallet/features/dapps/dapps.dart';
import 'package:moonchain_wallet/features/errors/network_unavailable/network_unavailable.dart';
import 'package:moonchain_wallet/features/file_listener/file_listener_wrapper.dart';
import 'package:moonchain_wallet/features/security/security.dart';
import 'package:moonchain_wallet/features/splash/splash.dart';
import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:moonchain_wallet/features/settings/settings.dart';
import 'package:mxc_ui/mxc_ui.dart';

final appNavigatorKey = GlobalKey<NavigatorState>();

class MXCWallet extends HookConsumerWidget {
  const MXCWallet({
    Key? key,
    required this.isLoggedIn,
  }) : super(key: key);

  final bool isLoggedIn;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final languageState = ref.watch(languageContainer.state);
    final appPresenter = ref.watch(appContainer.actions);

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
                if (!isLoggedIn) {
                  return route(const SplashSetupWalletPage());
                }

                return route(
                  const PasscodeRequireWrapperPage(
                    child: DAppsPage(),
                  ),
                );
              },
            );

            // Place there top-level widgets which should be presented above all pages
            // The widgets will be able to use Theme and Locale, but you can't use
            // [Navigator] through Navigator.of(context), you must use navigatorKey.

            child = FileListenerWrapper(child: child);

            child = NetworkUnavailableWrapper(child: child);

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
