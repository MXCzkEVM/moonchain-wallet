import 'package:datadashwallet/common/common.dart';
import 'package:datadashwallet/features/splash/secure_recovery_phrase/secure_recovery_phrase.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:mxc_ui/mxc_ui.dart';

import 'email_recovery_phrase_presenter.dart';
import 'email_recovery_phrase_state.dart';

class EmailRecoveryPhrasePage extends RecoveryPhraseBasePage {
  const EmailRecoveryPhrasePage({Key? key}) : super(key: key);

  @override
  ProviderBase<EmailRecoveryPhrasePresenter> get presenter =>
      emailRecoveryPhraseContainer.actions;

  @override
  ProviderBase<EmailRecoveryPhrasetState> get state =>
      emailRecoveryPhraseContainer.state;

  @override
  Widget icon(BuildContext context) => SvgPicture.asset(
        'assets/svg/splash/ic_wechat.svg',
        colorFilter: filterFor(themeColor()),
      );

  @override
  Color themeColor() => const Color(0xFFE64340);

  @override
  Widget buildAlert(BuildContext context) {
    return Container(
      width: double.infinity,
      alignment: Alignment.center,
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.all(Radius.circular(10)),
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
            child: SvgPicture.asset(
              'assets/svg/splash/ic_email.svg',
            ),
          ),
          const SizedBox(height: 12),
          Text(
            FlutterI18n.translate(context, 'email_to_myself_description'),
            style: FontTheme.of(context).body2().copyWith(
                  color: const Color(0xFF25282B),
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
        titleColor: Colors.white,
        color: themeColor(),
        borderColor: themeColor(),
        onTap: () => ref.read(presenter).sendEmail(context),
      );
}
