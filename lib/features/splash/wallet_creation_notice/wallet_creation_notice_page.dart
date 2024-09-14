import 'package:moonchain_wallet/common/common.dart';
import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:flutter_svg/svg.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:moonchain_wallet/main.dart';
import 'package:mxc_ui/mxc_ui.dart';

import 'wallet_creation_notice_presenter.dart';

const countDown = 5;

class WalletCreationNoticePage extends HookConsumerWidget {
  const WalletCreationNoticePage({
    Key? key,
  }) : super(key: key);

  Stream<int> countdownStream(int start) async* {
    for (int i = start; i >= 0; i--) {
      yield i;
      await Future.delayed(const Duration(seconds: 1));
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final presenter = ref.watch(walletCreationNoticeContainer.actions);

    return MxcPage(
      layout: LayoutType.column,
      presenter: presenter,
      useSplashBackground: true,
      childrenPadding: const EdgeInsets.symmetric(horizontal: 24),

      // footer: Column(
      //   mainAxisAlignment: MainAxisAlignment.end,
      //   children: [
      //     MxcButton.plainWhite(
      //       key: const ValueKey('continueNow'),
      //       title: FlutterI18n.translate(context, 'continue_now'),
      //       onTap: () => presenter.continueNow(),
      //       edgeType: UIConfig.securityScreensButtonsEdgeType,
      //     ),
      //   ],
      // ),
      children: [
        const SizedBox(height: 200),
        Text(
          appName,
          style: FontTheme.of(context).logo(),
        ),
        const SizedBox(
          height: 30,
        ),
        Container(
          padding: const EdgeInsets.symmetric(vertical: 5),
          decoration: BoxDecoration(
              color: ColorsTheme.of(context).white,
              borderRadius: UIConfig.defaultBorderRadiusAll),
          key: const ValueKey('accountSetupComplete'),
          child: Center(
              child: Text(
            FlutterI18n.translate(context, 'account_setup_complete'),
            style: FontTheme.of(context)
                .body2()
                .copyWith(color: ColorsTheme.of(context).blackDeep),
          )),
        ),
        // Padding(
        //   padding: const EdgeInsets.symmetric(vertical: 16),
        //   child: Text(
        //     FlutterI18n.translate(context, 'protect_your_wallet'),
        //     style: FontTheme.of(context).h4.white(),
        //   ),
        // ),
        const SizedBox(
          height: 30,
        ),
        Text(
          FlutterI18n.translate(
              context, 'you_will_be_directed_to_the_main_app'),
          style: FontTheme.of(context).h6.white(),
          textAlign: TextAlign.center,
        ),
        const SizedBox(
          height: 100,
        ),
        Text(
          FlutterI18n.translate(context, 'entering_the_app'),
          style: FontTheme.of(context).body2.white(),
          textAlign: TextAlign.center,
        ),
        const SizedBox(
          height: Sizes.spaceNormal,
        ),
        StreamBuilder(
          stream: countdownStream(countDown),
          builder: (context, snapshot) {
            final remainingTime = snapshot.data ?? countDown;
            final progress = remainingTime / countDown;
            if (snapshot.data == 0) {
              Future.delayed(
                const Duration(seconds: 1),
                () => presenter.continueNow(context),
              );
            }
            return Column(
              children: [
                CircularProgressIndicator(
                  value: progress,
                  color: ColorsTheme.of(context).white,
                  backgroundColor: const Color(0XFF313131),
                ),
                const SizedBox(
                  height: Sizes.spaceNormal,
                ),
                Text(
                  FlutterI18n.translate(context, 'in ${snapshot.data ?? 0}'),
                  style: FontTheme.of(context).body2.white(),
                  textAlign: TextAlign.center,
                )
              ],
            );
          },
        ),
        const Spacer(),
        MxcButton.plainWhite(
          key: const ValueKey('continueNow'),
          title: FlutterI18n.translate(context, 'continue_now'),
          onTap: () => presenter.continueNow(context),
          edgeType: UIConfig.securityScreensButtonsEdgeType,
        ),
      ],
    );
  }
}
