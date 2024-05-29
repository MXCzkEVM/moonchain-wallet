import 'package:datadashwallet/features/splash/secure_recovery_phrase/secure_recovery_phrase.dart';
import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:mxc_ui/mxc_ui.dart';

import 'email_recovery_phrase_presenter.dart';
import 'email_recovery_phrase_state.dart';

class EmailRecoveryPhrasePage extends RecoveryPhraseBasePage {
  const EmailRecoveryPhrasePage({
    Key? key,
    this.settingsFlow = false,
  }) : super(key: key);

  final bool settingsFlow;

  @override
  ProviderBase<EmailRecoveryPhrasePresenter> get presenter =>
      emailRecoveryPhraseContainer.actions;

  @override
  ProviderBase<EmailRecoveryPhrasetState> get state =>
      emailRecoveryPhraseContainer.state;

  @override
  Widget icon(BuildContext context) => Icon(
        MxcIcons.email,
        size: 40,
        color: themeColor(),
      );

  @override
  Color themeColor({BuildContext? context}) => const Color(0xFFE64340);

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
              color: themeColor(),
            ),
            child: const Icon(
              MxcIcons.email,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            FlutterI18n.translate(context, 'email_to_myself_description'),
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
        key: const ValueKey('storeButton'),
        title: FlutterI18n.translate(context, 'email_to_myself'),
        titleColor: ColorsTheme.of(context).textBlack200,
        color: themeColor(),
        borderColor: themeColor(),
        onTap: () => ref.read(presenter).sendEmail(
              context,
              settingsFlow,
            ),
      );
}
