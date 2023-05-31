import 'package:datadashwallet/common/common.dart';
import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:mxc_ui/mxc_ui.dart';

import '../widgets/address_bar.dart';
import '../widgets/subdomain_bar.dart';
import 'splash_ens_success_page_presenter.dart';
import 'splash_ens_success_page_state.dart';

class SplashENSSuccessPage extends HookConsumerWidget {
  const SplashENSSuccessPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final presenter = ref.read(splashENSSuccessPageContainer.actions);

    return MxcPage(
      layout: LayoutType.column,
      useAppLinearBackground: true,
      presenter: presenter,
      children: [
        const SizedBox(height: 100),
        Text(
          '${FlutterI18n.translate(context, 'congratulations')} 🎉',
          style: FontTheme.of(context).h5.white(),
        ),
        const SizedBox(height: 33),
        const AddressBar(),
        const SizedBox(height: 8),
        SvgPicture.asset(
          'assets/svg/down_arrow.svg',
          height: 30,
        ),
        const SubDomainBar(),
        const SizedBox(height: 20),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 70),
          child: Column(
            children: [
              Text(
                FlutterI18n.translate(context, 'successfully_claimed'),
                style: FontTheme.of(context)
                    .h6
                    .white()
                    .copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 40),
              Text(FlutterI18n.translate(context, 'ready_crypto'),
                  style: FontTheme.of(context).body1.white()),
            ],
          ),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 72),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                MxcFullRoundedButton(
                  key: const ValueKey('enterPortalButton'),
                  title: FlutterI18n.translate(context, 'enter_protal'),
                  onTap: null,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
