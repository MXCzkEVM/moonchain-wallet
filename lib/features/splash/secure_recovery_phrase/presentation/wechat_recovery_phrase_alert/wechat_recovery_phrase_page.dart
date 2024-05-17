import 'package:datadashwallet/common/common.dart';
import 'package:datadashwallet/features/splash/secure_recovery_phrase/secure_recovery_phrase.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:mxc_ui/mxc_ui.dart';

import 'wechat_recovery_phrase_presenter.dart';
import 'wechat_recovery_phrase_state.dart';

class WechatRecoveryPhrasePage extends RecoveryPhraseBasePage {
  const WechatRecoveryPhrasePage({
    Key? key,
    this.settingsFlow = false,
  }) : super(key: key);

  final bool settingsFlow;

  @override
  ProviderBase<WechatRecoveryPhrasePresenter> get presenter =>
      wechatRecoveryPhraseContainer.actions;

  @override
  ProviderBase<WechatRecoveryPhrasetState> get state =>
      wechatRecoveryPhraseContainer.state;

  @override
  Widget icon(BuildContext context) => Icon(
        MxcIcons.wechat,
        size: 52,
        color: themeColor(),
      );

  String name(BuildContext context) =>
      FlutterI18n.translate(context, 'wechat_favorites');

  @override
  Color themeColor({BuildContext? context}) => const Color(0xFF09BB07);

  @override
  Widget buildAlert(BuildContext context) {
    return Container(
      width: double.infinity,
      alignment: Alignment.centerLeft,
      padding: const EdgeInsets.only(top: 24, left: 24, bottom: 24),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.all(Radius.circular(10)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            FlutterI18n.translate(context, 'share'),
            style: FontTheme.of(context).subtitle2().copyWith(
                  color: const Color(0xFF25282B),
                ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 10),
            child: Divider(
              height: 1,
              color: Color(0xFFEBEFF2),
            ),
          ),
          Row(
            children: [
              Container(
                width: 43.2,
                height: 43.2,
                padding: const EdgeInsets.all(10),
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(0xFFCACACA),
                ),
                child: const Icon(
                  MxcIcons.wechat,
                  size: 22,
                ),
              ),
              const SizedBox(width: 20),
              Text(
                FlutterI18n.translate(context, 'wechat'),
                style: FontTheme.of(context).body1().copyWith(
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFFCACACA),
                    ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              ScaleAnimation(
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: const BorderRadius.all(Radius.circular(16)),
                    boxShadow: [
                      BoxShadow(
                        offset: const Offset(0.0, 8),
                        color: const Color(0xFF192027).withOpacity(0.1),
                        blurRadius: 10,
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      SvgPicture.asset(
                        'assets/svg/splash/ic_wechat_favorites.svg',
                      ),
                      const SizedBox(width: 22),
                      Text(
                        FlutterI18n.translate(context, 'wechat_favorites'),
                        style: FontTheme.of(context).body1().copyWith(
                              color: const Color(0xFF25282B),
                            ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 18),
              SvgPicture.asset(
                'assets/svg/splash/left_arrow.svg',
                width: 40,
              ),
            ],
          )
        ],
      ),
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
            ? () => ref.read(presenter).shareToWechat(settingsFlow)
            : null,
      );
}
