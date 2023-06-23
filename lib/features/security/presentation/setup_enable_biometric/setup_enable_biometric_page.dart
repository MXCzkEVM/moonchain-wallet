import 'package:datadashwallet/common/common.dart';
import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:flutter_svg/svg.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
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
      footer: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            MxcButton.primary(
              key: const ValueKey('useBiometricButton'),
              title: FlutterI18n.translate(context, 'use_biometric')
                  .replaceFirst(
                      '{0}',
                      FlutterI18n.translate(
                          context, presenter.getAppBarTitle())),
              onTap: () => presenter.authenticateBiometrics(),
            ),
            MxcButton.plain(
              key: const ValueKey('createPasscodeButton'),
              title: FlutterI18n.translate(context, 'create_passcode'),
              onTap: () => presenter.createPasscode(),
            ),
          ],
        ),
      ),
      children: [
        const SizedBox(height: 75),
        Image(
          image: ImagesTheme.of(context).datadash,
          width: 80,
          height: 80,
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
              .replaceFirst('{0}',
                  FlutterI18n.translate(context, presenter.getAppBarTitle())),
          style: FontTheme.of(context).h6.white(),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 43),
        SvgPicture.asset(
          presenter.getSvg(),
          height: 64,
          width: 64,
          colorFilter: filterFor(ColorsTheme.of(context).purple400),
        ),
        const Spacer(),
      ],
    );
  }
}
