import 'package:datadashwallet/common/common.dart';
import 'package:datadashwallet/core/core.dart';
import 'package:datadashwallet/features/home/home.dart';
import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:mxc_ui/mxc_ui.dart';

import '../widgets/address_bar.dart';
import '../widgets/subdomain_bar.dart';
import 'splash_ens_success_presenter.dart';

class SplashENSSuccessPage extends HookConsumerWidget {
  const SplashENSSuccessPage({
    Key? key,
    required this.address,
    required this.domain,
  }) : super(key: key);

  final String address;
  final String domain;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final presenter = ref.read(splashENSSuccessContainer.actions);

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
        AddressBar(
          address: address,
        ),
        const SizedBox(height: 8),
        SvgPicture.asset(
          'assets/svg/down_arrow.svg',
          height: 30,
        ),
        SubDomainBar(
          domain: '$domain.mxc',
        ),
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
              Text(
                  FlutterI18n.translate(context, 'ready_crypto')
                      .replaceFirst('{0}', domain),
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
                  onTap: () => Navigator.of(context)
                      .replaceAll(route(const HomeMainPage())),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
