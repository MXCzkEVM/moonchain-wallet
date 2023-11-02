import 'package:datadashwallet/common/common.dart';
import 'package:datadashwallet/common/components/recent_transactions/domain/mxc_transaction_use_case.dart';
import 'package:datadashwallet/features/common/account/log_out_use_case.dart';
import 'package:datadashwallet/features/common/common.dart';
import 'package:datadashwallet/features/common/contract/chains_use_case.dart';
import 'package:datadashwallet/features/common/contract/nft_contract_use_case.dart';
import 'package:datadashwallet/features/common/contract/pricing_use_case.dart';
import 'package:datadashwallet/features/common/contract/tweets_use_case.dart';
import 'package:datadashwallet/features/dapps/domain/dapp_store_use_case.dart';
import 'package:datadashwallet/features/dapps/domain/gestures_instruction_use_case.dart';
import 'package:datadashwallet/features/errors/network_unavailable/network_unavailable_use_case.dart';
import 'package:datadashwallet/features/portfolio/subfeatures/nft/domain/nfts_use_case.dart';
import 'package:datadashwallet/features/settings/domain/app_version_use_case.dart';
import 'package:datadashwallet/features/settings/subfeatures/address_book/address_book.dart';
import 'package:datadashwallet/features/portfolio/subfeatures/token/add_token/domain/custom_tokens_use_case.dart';
import 'package:datadashwallet/features/dapps/subfeatures/add_dapp/domain/bookmark_use_case.dart';
import 'package:datadashwallet/features/portfolio/domain/portfolio_use_case.dart';
import 'package:datadashwallet/features/security/security.dart';
import 'package:datadashwallet/features/settings/subfeatures/chain_configuration/domain/chain_configuration_use_case.dart';
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

final Provider<GesturesInstructionUseCase> gesturesInstructionUseCaseProvider =
    Provider(
  (ref) => GesturesInstructionUseCase(
      ref.watch(globalCacheProvider).gesturesInstruction),
);

final Provider<TokenContractUseCase> tokenContractUseCaseProvider = Provider(
  (ref) => TokenContractUseCase(
    ref.watch(web3RepositoryProvider),
  ),
);

final Provider<NftContractUseCase> nftContractUseCaseProvider = Provider(
  (ref) => NftContractUseCase(
    ref.watch(web3RepositoryProvider),
  ),
);

final Provider<TweetsUseCase> tweetsUseCaseProvider = Provider(
  (ref) => TweetsUseCase(
    ref.watch(web3RepositoryProvider),
  ),
);

final Provider<PricingUseCase> pricingUseCaseProvider = Provider(
  (ref) => PricingUseCase(
    ref.watch(web3RepositoryProvider),
  ),
);

final Provider<PortfolioUseCase> portfolioUseCaseProvider = Provider(
  (ref) => PortfolioUseCase(
    ref.watch(web3RepositoryProvider),
  ),
);

final Provider<PasscodeUseCase> passcodeUseCaseProvider = Provider(
  (ref) => PasscodeUseCase(ref.watch(globalCacheProvider).passcode),
);

final Provider<AuthUseCase> authUseCaseProvider = Provider(
  (ref) => AuthUseCase(
    ref.watch(web3RepositoryProvider).walletAddress,
    ref.watch(authenticationStorageProvider),
    ref.watch(authenticationCacheRepository),
  ),
);

final Provider<AccountUseCase> accountUseCaseProvider = Provider(
  (ref) => AccountUseCase(
    ref.watch(web3RepositoryProvider),
    ref.watch(globalCacheProvider).account,
    ref.watch(authenticationStorageProvider),
  ),
);

final Provider<BookmarkUseCase> bookmarksUseCaseProvider = Provider(
  (ref) => BookmarkUseCase(ref.watch(datadashCacheProvider).bookmarks),
);

final Provider<CustomTokensUseCase> customTokensUseCaseProvider = Provider(
  (ref) => CustomTokensUseCase(ref.watch(datadashCacheProvider).custonTokens),
);

final Provider<BalanceUseCase> balanceHistoryUseCaseProvider = Provider(
  (ref) => BalanceUseCase(ref.watch(datadashCacheProvider).balanceHistory),
);

final Provider<RecipientsUseCase> recipientsCaseProvider = Provider(
  (ref) => RecipientsUseCase(ref.watch(datadashCacheProvider).recipients),
);

final Provider<NftsUseCase> nftsUseCaseProvider = Provider(
  (ref) => NftsUseCase(ref.watch(datadashCacheProvider).nfts),
);

final Provider<ChainConfigurationUseCase> chainConfigurationUseCaseProvider =
    Provider(
  (ref) => ChainConfigurationUseCase(
    ref.watch(globalCacheProvider).chainConfigurationRepository,
  ),
);

final Provider<MXCTransactionsUseCase> mxcTransactionsUseCaseProvider =
    Provider(
  (ref) => MXCTransactionsUseCase(
    ref.watch(web3RepositoryProvider),
  ),
);

final Provider<TransactionsHistoryUseCase> transactionHistoryUseCaseProvider =
    Provider(
  (ref) => TransactionsHistoryUseCase(
    ref.watch(datadashCacheProvider).transactionsHistoryRepository,
    ref.watch(web3RepositoryProvider),
  ),
);

final Provider<NetworkUnavailableUseCase> networkUnavailableUseCaseProvider =
    Provider(
  (ref) => NetworkUnavailableUseCase(),
);

final Provider<LogOutUseCase> logOutUseCaseProvider = Provider(
  (ref) => LogOutUseCase(
    accountCacheRepository: ref.watch(globalCacheProvider).account,
    authUseCase: ref.watch(authUseCaseProvider),
    passcodeUseCase: ref.watch(passcodeUseCaseProvider),
    webviewUseCase: WebviewUseCase(),
  ),
);

final Provider<DappStoreUseCase> dappStoreUseCaseProvider = Provider(
  (ref) => DappStoreUseCase(
    ref.watch(web3RepositoryProvider),
  ),
);

final Provider<AppVersionUseCase> appVersionUseCaseProvider = Provider(
  (ref) => AppVersionUseCase(
    ref.watch(web3RepositoryProvider),
  ),
);

final Provider<ChainsUseCase> chainsUseCaseProvider = Provider(
  (ref) => ChainsUseCase(
    ref.watch(web3RepositoryProvider),
    ref.watch(chainConfigurationUseCaseProvider),
    ref.watch(authUseCaseProvider),
  ),
);

final Provider<ErrorUseCase> errorUseCaseProvider = Provider(
  (ref) => ErrorUseCase(
    ref.watch(web3RepositoryProvider),
    ref.watch(accountUseCaseProvider),
    ref.watch(chainConfigurationUseCaseProvider),
  ),
);
