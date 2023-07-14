import 'package:datadashwallet/common/common.dart';
import 'package:datadashwallet/features/common/common.dart';
import 'package:datadashwallet/features/settings/subfeatures/recipient/recipient.dart';
import 'package:datadashwallet/features/token/add_token/domain/custom_tokens_use_case.dart';
import 'package:datadashwallet/features/home/apps/subfeatures/add_dapp/domain/bookmark_use_case.dart';
import 'package:datadashwallet/features/home/apps/subfeatures/apps_page/domain/bookmark_pagination_use_case.dart';
import 'package:datadashwallet/features/portfolio/domain/portfolio_use_case.dart';
import 'package:datadashwallet/features/security/security.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:datadashwallet/core/core.dart';
import 'package:datadashwallet/features/settings/settings.dart';
import 'package:mxc_logic/mxc_logic.dart';

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

final Provider<ContractUseCase> contractUseCaseProvider = Provider(
  (ref) => ContractUseCase(
    ref.watch(apiRepositoryProvider),
  ),
);

final Provider<PortfolioUseCase> portfolioUseCaseProvider = Provider(
  (ref) => PortfolioUseCase(
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
  (ref) => BookmarkUseCase(ref.watch(datadashCacheProvider).bookmarks),
);

final Provider<BookmarkPaginationUseCase> bookmarkPaginationUseCaseProvider =
    Provider((ref) =>
        BookmarkPaginationUseCase(ref.watch(datadashCacheProvider).bookmarks));

final Provider<CustomTokensUseCase> customTokensCaseProvider = Provider(
  (ref) => CustomTokensUseCase(ref.watch(datadashCacheProvider).custonTokens),
);

final Provider<BalanceUseCase> balanceHistoryUseCaseProvider = Provider(
  (ref) => BalanceUseCase(ref.watch(datadashCacheProvider).balanceHistory),
);

final Provider<RecipientsUseCase> recipientsCaseProvider = Provider(
  (ref) => RecipientsUseCase(ref.watch(datadashCacheProvider).recipients),
);
