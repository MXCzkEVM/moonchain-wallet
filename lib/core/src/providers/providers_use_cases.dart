import 'package:datadashwallet/features/secured_storage/secured_storage.dart';
import 'package:datadashwallet/features/security/security.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:datadashwallet/core/core.dart';
import 'package:datadashwallet/features/settings/settings.dart';

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

final Provider<PasscodeUseCase> passcodeUseCaseProvider = Provider(
  (ref) => PasscodeUseCase(ref.watch(globalCacheProvider).passcode),
);