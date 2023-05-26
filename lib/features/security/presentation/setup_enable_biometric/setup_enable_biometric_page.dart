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
      presenter: presenter,
      backgroundColor: ColorsTheme.of(context).secondaryBackground,
      fixedFooter: true,
      footer: Padding(
        padding: mxcPageButtonPadding,
        child: Column(
          children: [
            // InkWell(
            //   key: const ValueKey('skip_biometrics'),
            //   onTap: presenter.skip,
            //   child: Text(
            //     FlutterI18n.translate(context, 'use_passcode'),
            //     style: FontTheme.of(context).body2(),
            //   ),
            // ),
            const SizedBox(height: 24),
            MxcPrimaryButton(
              key: const ValueKey('enable_face_id'),
              title: FlutterI18n.translate(context, 'enable_x').replaceFirst(
                  '{0}',
                  FlutterI18n.translate(context, presenter.getAppBarTitle())),
              onTap: () => presenter.authenticateBiometrics(),
            ),
          ],
        ),
      ),
      children: [
        const SizedBox(height: 78),
        SvgPicture.asset(
          presenter.getSvg(),
          height: 64,
          width: 64,
          color: ColorsTheme.of(context).purple400,
        ),
        const SizedBox(height: 64),
        Text(
          FlutterI18n.translate(context, presenter.getDesc()),
          textAlign: TextAlign.center,
          style: FontTheme.of(context).body1(),
        ),
        const SizedBox(height: 16),
        Text(
          FlutterI18n.translate(context, 'enable_biometrics_desc2'),
          style: FontTheme.of(context).subtitle1.secondary(),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
