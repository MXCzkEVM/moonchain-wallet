import 'package:datadashwallet/features/home/apps/subfeatures/add_dapp/domain/bookmark_use_case.dart';
import 'package:datadashwallet/features/home/apps/subfeatures/apps_tab/domain/bookmark_pagination_use_case.dart';
import 'package:datadashwallet/features/security/security.dart';
import 'package:datadashwallet/features/splash/splash.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:datadashwallet/core/core.dart';
import 'package:datadashwallet/features/settings/settings.dart';
import 'package:mxc_logic/mxc_logic.dart';

import '../../../features/home/home/domain/home_use_case.dart';

final Provider<ThemeUseCase> themeUseCaseProvider = Provider(
  (ref) => ThemeUseCase(
    ref.watch(globalCacheProvider).theme,
  ),
);

final Provider<LanguageUseCase> languageUseCaseProvider = Provider(
  (ref) => LanguageUseCase(ref.watch(globalCacheProvider).language),
);

final Provider<WalletUseCase> walletUseCaseProvider = Provider(
  (ref) => WalletUseCase(
    ref.watch(apiRepositoryProvider),
  ),
);

final Provider<HomeUseCase> homeUseCaseProvider = Provider(
  (ref) => HomeUseCase(
    ref.watch(apiRepositoryProvider),
  ),
);

final Provider<PasscodeUseCase> passcodeUseCaseProvider = Provider(
  (ref) => PasscodeUseCase(ref.watch(globalCacheProvider).passcode),
);

final Provider<AuthUseCase> authUseCaseProvider = Provider(
  (ref) => AuthUseCase(ref.watch(userSetupProvider)),
);

final Provider<BookmarkUseCase> bookmarksUseCaseProvider = Provider(
  (ref) => BookmarkUseCase(ref.watch(globalCacheProvider).bookmarks),
);

final Provider<BookmarkPaginationUseCase> bookmarkPaginationUseCaseProvider =
    Provider((ref) =>
        BookmarkPaginationUseCase(ref.watch(globalCacheProvider).bookmarks));
