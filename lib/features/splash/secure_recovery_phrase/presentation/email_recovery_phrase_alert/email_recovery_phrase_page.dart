import 'package:moonchain_wallet/common/common.dart';
import 'package:moonchain_wallet/features/splash/secure_recovery_phrase/secure_recovery_phrase.dart';
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
        color: themeColor(context: context),
      );

  @override
  Color themeColor({BuildContext? context}) => const Color(0xFFE64340);

  String translate(BuildContext context, String text) =>
      FlutterI18n.translate(context, text);

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
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: themeColor(context: context),
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
  Widget? buildEmailInput(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: Sizes.space3XLarge),
        Text(
          '${FlutterI18n.translate(context, 'from')}:',
          style: FontTheme.of(context).caption1().copyWith(
                fontWeight: FontWeight.w500,
                color: ColorsTheme.of(context).textPrimary,
              ),
          textAlign: TextAlign.start,
        ),
        const SizedBox(height: Sizes.space2XSmall),
        Form(
          key: ref.watch(state).formKey,
          child: MxcTextField(
            key: const Key('fromTextField'),
            controller: ref.read(presenter).fromController,
            hint: FlutterI18n.translate(context, 'your_email_address'),
            keyboardType: TextInputType.emailAddress,
            validator: (value) {
              // ref.read(presenter).fromController;
              final res = Validation.notEmpty(
                  context,
                  value,
                  translate(context, 'x_not_empty')
                      .replaceFirst('{0}', translate(context, 'email')));

              if (res != null) {
                return res;
              }

              return Validation.checkEmailAddress(context, value!); //
            },
            onChanged: (value) =>
                ref.read(state).formKey.currentState!.validate(),
          ),
        ),
        const SizedBox(height: Sizes.spaceXSmall),
        Text(
          '${FlutterI18n.translate(context, 'to')}:',
          style: FontTheme.of(context).caption1().copyWith(
                fontWeight: FontWeight.w500,
                color: ColorsTheme.of(context).textPrimary,
              ),
          textAlign: TextAlign.start,
        ),
        const SizedBox(height: Sizes.spaceSmall),
        MxcTextField(
          key: const Key('fromTextField'),
          controller: ref.read(presenter).fromController,
          hint: FlutterI18n.translate(context, 'your_email_address'),
          keyboardType: TextInputType.emailAddress,
          readOnly: true,
          hasClearButton: false,
        ),
      ],
    );
  }

  @override
  Widget? buildFooter(BuildContext context, WidgetRef ref) =>
      MxcButton.primaryWhite(
        key: const ValueKey('storeButton'),
        title: FlutterI18n.translate(context, 'email_to_myself'),
        titleColor: ColorsTheme.of(context).textBlack200,
        titleSize: 18,
        onTap: () {
          if (!ref.read(state).formKey.currentState!.validate()) {
            return;
          }
          ref.read(presenter).sendEmail(
                context,
                settingsFlow,
                ref.read(presenter).fromController.text,
              );
        },
        edgeType: MXCWalletButtonEdgeType.hard,
      );
}
