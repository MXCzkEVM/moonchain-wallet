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
      layout: LayoutType.scrollable,
      presenter: presenter,
      useSplashBackground: true,
      footer: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 30),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            MxcButton.primary(
              key: const ValueKey('confrimButton'),
              title: FlutterI18n.translate(context, 'confrim').toUpperCase(),
              onTap: () => presenter.authenticateBiometrics(),
            ),
            const SizedBox(height: 21),
            InkWell(
              key: const ValueKey('skipBiometrics'),
              child: Text(
                FlutterI18n.translate(context, 'maybe_later'),
                style: FontTheme.of(context).body2.white(),
              ),
              onTap: () => presenter.skip(),
            ),
          ],
        ),
      ),
      children: [
        const SizedBox(height: 75),
        Text(
          FlutterI18n.translate(context, 'biometrics_setup'),
          style: FontTheme.of(context).h5.white(),
        ),
        const SizedBox(height: 24),
        Image(
          image: ImagesTheme.of(context).datadash,
        ),
        const SizedBox(height: 43),
        SvgPicture.asset(
          presenter.getSvg(),
          height: 64,
          width: 64,
          colorFilter: filterFor(ColorsTheme.of(context).purple400),
        ),
        const SizedBox(height: 32),
        Text(
          FlutterI18n.translate(context, 'enable_x').replaceFirst('{0}',
              FlutterI18n.translate(context, presenter.getAppBarTitle())),
          style: FontTheme.of(context).body1.white(),
        ),
      ],
    );
  }
}
