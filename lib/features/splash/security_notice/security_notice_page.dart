import 'package:moonchain_wallet/common/common.dart';
import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:mxc_ui/mxc_ui.dart';

import 'security_notice_presenter.dart';
import 'widgets/warning_item.dart';

class SecurityNoticePage extends HookConsumerWidget {
  const SecurityNoticePage({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final presenter = ref.read(securityNoticeContainer.actions);

    return MxcPage(
      layout: LayoutType.scrollable,
      useSplashBackground: true,
      presenter: presenter,
      appBar: MxcAppBar.splashBack(text: ''),
      footer: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: MxcButton.primaryWhite(
          key: const Key('storedMyKeyButton'),
          title: FlutterI18n.translate(context, 'stored_my_key'),
          size: MXCWalletButtonSize.xl,
          onTap: () => presenter.confirm(),
          edgeType: UIConfig.splashScreensButtonsEdgeType,
        ),
      ),
      children: [
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SvgPicture.asset('assets/svg/splash/ic_warning.svg'),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Text(
                FlutterI18n.translate(context, 'security_notice'),
                style: FontTheme.of(context).h5.white(),
              ),
            ),
            Text(
              FlutterI18n.translate(context, 'ensure_saved_platform'),
              style: FontTheme.of(context).body1.white(),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            const WarningItem(
              icon: MxcIcons.lock,
              title: 'keep_phone_save',
              subTitle: 'keep_phone_save_description',
            ),
            const WarningItem(
              icon: MxcIcons.safety,
              iconSize: 32,
              title: 'beware_unauthorized_access',
              subTitle: 'beware_unauthorized_access_description',
            ),
            const WarningItem(
              icon: MxcIcons.wallet_1,
              iconSize: 32,
              title: 'potential_fund_loss',
              subTitle: 'potential_fund_loss_description1',
            ),
            Text(
              FlutterI18n.translate(
                  context, 'potential_fund_loss_description2'),
              style: FontTheme.of(context).subtitle1.secondary(),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ],
    );
  }
}
