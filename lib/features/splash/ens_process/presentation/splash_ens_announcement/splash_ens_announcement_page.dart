import 'package:datadashwallet/common/common.dart';
import 'package:datadashwallet/core/core.dart';
import 'package:datadashwallet/features/splash/ens_process/ens.dart';
import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:mxc_ui/mxc_ui.dart';

import '../widgets/address_bar.dart';
import '../widgets/subdomain_bar.dart';
import 'splash_ens_announcement_presenter.dart';

class SplashENSAnnouncementPage extends HookConsumerWidget {
  const SplashENSAnnouncementPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final presenter = ref.read(splashENSAnnouncementContainer.actions);

    return MxcPage(
      layout: LayoutType.scrollable,
      useSplashBackground: true,
      presenter: presenter,
      footer: Padding(
        padding: const EdgeInsets.all(30),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            MxcButton.primary(
              key: const ValueKey('claimButton'),
              title: FlutterI18n.translate(context, 'claim').toUpperCase(),
              onTap: () =>
                  Navigator.of(context).push(route(const SplashENSQueryPage())),
            ),
          ],
        ),
      ),
      children: [
        const SizedBox(height: 50),
        Image(
          image: ImagesTheme.of(context).mxc,
        ),
        const SizedBox(height: 27),
        Text(
          FlutterI18n.translate(context, 'meta_x_connect'),
          style: FontTheme.of(context).h5.white(),
        ),
        const SizedBox(height: 20),
        const AddressBar(),
        const SizedBox(height: 8),
        SvgPicture.asset(
          'assets/svg/down_arrow.svg',
          height: 30,
        ),
        const SubDomainBar(),
        Text(
          FlutterI18n.translate(context, 'mxc_zkevm_username'),
          style: FontTheme.of(context).h5.white(),
        ),
        const SizedBox(height: 6),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 56),
          child: Text(
            FlutterI18n.translate(context, 'ens_announcement_description'),
            style: FontTheme.of(context).caption1.white(),
          ),
        ),
      ],
    );
  }
}
