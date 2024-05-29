import 'package:datadashwallet/features/splash/secure_recovery_phrase/secure_recovery_phrase.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:mxc_ui/mxc_ui.dart';

import 'telegram_recovery_phrase_presenter.dart';
import 'telegram_recovery_phrase_state.dart';

class TelegramRecoveryPhrasePage extends RecoveryPhraseBasePage {
  const TelegramRecoveryPhrasePage({
    Key? key,
    this.settingsFlow = false,
  }) : super(key: key);

  final bool settingsFlow;

  @override
  ProviderBase<TelegramRecoveryPhrasePresenter> get presenter =>
      telegramRecoveryPhraseContainer.actions;

  @override
  ProviderBase<TelegramRecoveryPhrasetState> get state =>
      telegramRecoveryPhraseContainer.state;

  @override
  Widget icon(BuildContext context) => Icon(
        MxcIcons.telegram,
        size: 52,
        color: themeColor(),
      );

  String name(BuildContext context) =>
      FlutterI18n.translate(context, 'saved_messages');

  @override
  Color themeColor({BuildContext? context}) => const Color(0xFF37AEE2);

  @override
  Widget buildAlert(BuildContext context) {
    return Column(
      children: [
        Container(
          decoration: const BoxDecoration(
            color: Color(0xFF527DA3),
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(10),
              topRight: Radius.circular(10),
            ),
          ),
          child: Column(children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
              child: Row(
                children: [
                  Text(
                    '10:00',
                    style: FontTheme.of(context).subtitle1.white(),
                  ),
                  const Spacer(),
                  const Icon(
                    Icons.signal_cellular_4_bar,
                    size: 18,
                    color: Colors.white,
                  ),
                  const Padding(
                    padding: EdgeInsets.only(left: 6, right: 2),
                    child: Icon(
                      Icons.signal_wifi_statusbar_4_bar,
                      size: 18,
                      color: Colors.white,
                    ),
                  ),
                  const Icon(
                    Icons.battery_full,
                    size: 18,
                    color: Colors.white,
                  ),
                ],
              ),
            ),
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 18.4, vertical: 10.5),
              child: Row(
                children: [
                  const Icon(
                    Icons.arrow_back,
                    color: Colors.white,
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 30),
                      child: Text(
                        FlutterI18n.translate(context, 'select_chat'),
                        style: FontTheme.of(context).body1.white(),
                      ),
                    ),
                  ),
                  const Icon(
                    Icons.search,
                    color: Colors.white,
                  ),
                ],
              ),
            )
          ]),
        ),
        Container(
          height: 80,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(10),
              bottomRight: Radius.circular(10),
            ),
          ),
          child: ScaleAnimation(
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.all(Radius.circular(10)),
              ),
              child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 18),
                  child: Row(
                    children: [
                      Container(
                        width: 43.2,
                        height: 43.2,
                        padding: const EdgeInsets.all(10),
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Color(0xFF37AEE2),
                        ),
                        child: const Icon(
                          MxcIcons.saved_messages,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        name(context),
                        style: FontTheme.of(context).body1().copyWith(
                              fontWeight: FontWeight.w500,
                              color: const Color(0xFF25282B),
                            ),
                      ),
                    ],
                  )),
            ),
          ),
        )
      ],
    );
  }

  @override
  Widget? buildAccept(BuildContext context, WidgetRef ref) => Row(
        children: [
          Expanded(
            child: Text(
              FlutterI18n.translate(context, 'confirm_store_app')
                  .replaceFirst('{0}', name(context)),
              style: FontTheme.of(context).subtitle1.white(),
            ),
          ),
          CupertinoSwitch(
            value: ref.watch(state).acceptAgreement,
            onChanged: (_) => ref.read(presenter).changeAcceptAggreement(),
          )
        ],
      );

  @override
  Widget? buildFooter(BuildContext context, WidgetRef ref) => MxcButton.primary(
        key: const ValueKey('storeButton'),
        title: FlutterI18n.translate(context, 'store_to')
            .replaceFirst('{0}', name(context)),
        titleColor: ColorsTheme.of(context).textBlack200,
        color: themeColor(),
        borderColor: themeColor(),
        onTap: ref.watch(state).acceptAgreement
            ? () => ref.read(presenter).shareToTelegram(settingsFlow)
            : null,
      );
}
