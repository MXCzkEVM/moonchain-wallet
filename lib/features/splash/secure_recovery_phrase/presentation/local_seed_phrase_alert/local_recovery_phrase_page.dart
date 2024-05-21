import 'package:datadashwallet/features/splash/secure_recovery_phrase/secure_recovery_phrase.dart';
import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:mxc_ui/mxc_ui.dart';

import 'local_recovery_phrase_presenter.dart';
import 'local_recovery_phrase_state.dart';

class LocalRecoveryPhrasePage extends RecoveryPhraseBasePage {
  const LocalRecoveryPhrasePage({
    Key? key,
    this.settingsFlow = false,
  }) : super(key: key);

  final bool settingsFlow;

  @override
  ProviderBase<LocalRecoveryPhrasePresenter> get presenter =>
      emailRecoveryPhraseContainer.actions;

  @override
  ProviderBase<LocalRecoveryPhraseState> get state =>
      emailRecoveryPhraseContainer.state;

  @override
  Widget icon(BuildContext context) => Icon(
        Icons.file_download_rounded,
        size: 40,
        color: themeColor(context: context),
      );

  @override
  Color themeColor({BuildContext? context}) => ColorsTheme.of(context!).primary;

  @override
  Widget buildAlert(BuildContext context) {
    return Container(
      width: double.infinity,
      alignment: Alignment.center,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: ColorsTheme.of(context).cardBackground,
        borderRadius: const BorderRadius.all(Radius.circular(10)),
      ),
      child: Column(
        children: [
          Container(
            width: 72,
            height: 72,
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: themeColor(context: context),
            ),
            child: const Icon(
              Icons.file_download_rounded,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            FlutterI18n.translate(context, 'save_locally_description'),
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
  Widget? buildFooter(BuildContext context, WidgetRef ref) => MxcButton.primary(
        key: const ValueKey('saveLocallyButton'),
        title: FlutterI18n.translate(context, 'save_locally'),
        titleColor: ColorsTheme.of(context).textBlack200,
        color: themeColor(context: context),
        borderColor: themeColor(context: context),
        onTap: () => ref.read(presenter).saveLocally(
              settingsFlow,
            ),
      );
}
