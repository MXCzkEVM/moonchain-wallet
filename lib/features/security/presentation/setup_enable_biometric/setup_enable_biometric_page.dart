import 'package:moonchain_wallet/common/common.dart';
import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:flutter_svg/svg.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:moonchain_wallet/main.dart';
import 'package:mxc_ui/mxc_ui.dart';

import 'setup_enable_biometric_presenter.dart';

class SetupEnableBiometricPage extends HookConsumerWidget {
  const SetupEnableBiometricPage({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final presenter = ref.watch(setupEnableBiometricContainer.actions);

    return MxcPage(
      layout: LayoutType.column,
      presenter: presenter,
      useSplashBackground: true,
      childrenPadding: const EdgeInsets.symmetric(horizontal: 24),
      footer: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          MxcButton.primaryWhite(
            key: const ValueKey('useBiometricButton'),
            title: FlutterI18n.translate(context, 'use_biometric').replaceFirst(
                '{0}',
                FlutterI18n.translate(context, presenter.getAppBarTitle())),
            onTap: () => presenter.authenticateBiometrics(),
            edgeType: UIConfig.securityScreensButtonsEdgeType,
          ),
          MxcButton.plainWhite(
            key: const ValueKey('createPasscodeButton'),
            title: FlutterI18n.translate(context, 'create_passcode'),
            onTap: () => presenter.createPasscode(),
            edgeType: UIConfig.securityScreensButtonsEdgeType,
          ),
        ],
      ),
      children: [
        const SizedBox(height: 200),
        Text(
          appName,
          style: FontTheme.of(context).logo(),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Text(
            FlutterI18n.translate(context, 'protect_your_wallet'),
            style: FontTheme.of(context).h4.white(),
          ),
        ),
        Text(
          FlutterI18n.translate(context, 'use_biometric_or_passcode')
              .replaceFirst(
                  '{0}',
                  FlutterI18n.translate(context, presenter.getAppBarTitle())
                      .toLowerCase()),
          style: FontTheme.of(context).h6.white(),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 24),
        SvgPicture.asset(
          presenter.getSvg(),
          height: 80,
          width: 80,
          colorFilter: filterFor(ColorsTheme.of(context).iconWhite),
        ),
        const Spacer(),
      ],
    );
  }
}
