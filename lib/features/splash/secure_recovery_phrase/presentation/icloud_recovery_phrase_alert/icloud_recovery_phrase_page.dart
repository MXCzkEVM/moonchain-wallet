import 'package:moonchain_wallet/features/splash/secure_recovery_phrase/secure_recovery_phrase.dart';
import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:mxc_ui/mxc_ui.dart';

class ICloudRecoveryPhrasePage extends RecoveryPhraseBasePage {
  const ICloudRecoveryPhrasePage({
    Key? key,
    this.settingsFlow = false,
  }) : super(key: key);

  final bool settingsFlow;

  @override
  ProviderBase<ICloudRecoveryPhrasePresenter> get presenter =>
      iCloudRecoveryPhraseContainer.actions;

  @override
  ProviderBase<ICloudRecoveryPhraseState> get state =>
      iCloudRecoveryPhraseContainer.state;

  @override
  Widget icon(BuildContext context) => getIcon(context);

  @override
  Color themeColor({BuildContext? context}) => ColorsTheme.of(context!).white;

  Widget getIcon(BuildContext context) {
    return Icon(
      MxcIcons.icloud,
      color: ColorsTheme.of(context).blackDeep,
      size: 42,
    );
  }

  @override
  Widget buildAlert(BuildContext context) {
    return Container(
      width: double.infinity,
      alignment: Alignment.center,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: ColorsTheme.of(context).cardBackground,
        borderRadius: const BorderRadius.all(Radius.zero),
      ),
      child: Column(
        children: [
          Container(
              width: 72,
              height: 72,
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.all(Radius.circular(16)),
                color: themeColor(context: context),
              ),
              child: getIcon(context)),
          const SizedBox(height: 12),
          Text(
            FlutterI18n.translate(context,
                    'ensure_that_your_keys_are_stored_correctly_in_your_x')
                .replaceFirst('{0}', FlutterI18n.translate(context, 'icloud')),
            style: FontTheme.of(context).body1().copyWith(
                  fontWeight: FontWeight.w500,
                  color: ColorsTheme.of(context).textPrimary,
                ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  @override
  Widget? buildFooter(BuildContext context, WidgetRef ref) =>
      MxcButton.primaryWhite(
        key: const ValueKey('storeButton'),
        title: FlutterI18n.translate(context, 'store_in_x')
            .replaceFirst('{0}', FlutterI18n.translate(context, 'icloud')),
        titleColor: ColorsTheme.of(context).textBlack200,
        titleSize: 18,
        onTap: () => ref.read(presenter).saveToICloud(settingsFlow),
        edgeType: MXCWalletButtonEdgeType.hard,
      );
}
