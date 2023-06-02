import 'package:datadashwallet/common/common.dart';
import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:mxc_ui/mxc_ui.dart';

import 'splash_ens_register_page_presenter.dart';
import 'splash_ens_register_page_state.dart';

class SplashENSRegisterPage extends HookConsumerWidget {
  const SplashENSRegisterPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final presenter = ref.read(splashENSRegisterPageContainer.actions);

    return MxcPage(
      layout: LayoutType.scrollable,
      useAppLinearBackground: true,
      childrenPadding: const EdgeInsets.symmetric(horizontal: 10),
      presenter: presenter,
      children: [
        const SizedBox(height: 50),
        Text(
          FlutterI18n.translate(context, 'choose_your_username'),
          style: FontTheme.of(context).h4.white(),
        ),
        const SizedBox(height: 32),
        Text(
          FlutterI18n.translate(context, 'ens_register_description'),
          style: FontTheme.of(context).caption1.white(),
        ),
        const SizedBox(height: 32),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              FlutterI18n.translate(context, 'username'),
              style: FontTheme.of(context).caption2.white(),
            ),
            Container(
              margin: const EdgeInsets.symmetric(vertical: 4),
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.all(Radius.circular(5)),
                border: Border.all(color: ColorsTheme.of(context).white),
              ),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: const BorderRadius.all(Radius.circular(5)),
                ),
                child: TextField(
                  autofocus: true,
                  style: FontTheme.of(context).body1.white(),
                  decoration: InputDecoration(
                    constraints: const BoxConstraints(maxHeight: 36),
                    focusedBorder: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    suffix: Padding(
                      padding: const EdgeInsets.only(right: 10),
                      child: Text(
                        '.mxc',
                        style: FontTheme.of(context).body1.white(),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Text(
              FlutterI18n.translate(context, 'prowerd_zkevm'),
              style: FontTheme.of(context).caption1.white(),
            ),
          ],
        ),
        const SizedBox(height: 20),
        Row(
          children: [
            Image(
              image: ImagesTheme.of(context).mxc,
            ),
            Flexible(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    FlutterI18n.translate(context, 'use_ens'),
                    style: FontTheme.of(context).body2.white(),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    FlutterI18n.translate(context, 'mxc_import_wallet'),
                    style: FontTheme.of(context).caption1.white(),
                    softWrap: true,
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      InkWell(
                        child: Text(
                          FlutterI18n.translate(context, 'learn_more'),
                          style: FontTheme.of(context).caption2.white(),
                        ),
                        onTap: () => openUrl(''),
                      ),
                      const SizedBox(width: 5),
                      SvgPicture.asset(
                        'assets/svg/right_arrow.svg',
                      ),
                    ],
                  )
                ],
              ),
            )
          ],
        ),
        Row(
          children: [
            Theme(
              data: Theme.of(context).copyWith(
                unselectedWidgetColor: ColorsTheme.of(context).white,
              ),
              child: Checkbox(
                activeColor: Colors.transparent,
                value: false,
                onChanged: (_) {},
              ),
            ),
            Text.rich(TextSpan(children: [
              TextSpan(
                text: FlutterI18n.translate(context, 'agree_terms1'),
                style: FontTheme.of(context).caption1.white(),
              ),
              const TextSpan(text: ' '),
              TextSpan(
                text: FlutterI18n.translate(context, 'agree_terms2'),
                style: FontTheme.of(context).caption2.white(),
              )
            ]))
          ],
        ),
        const SizedBox(height: 50),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 72),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              MxcFullRoundedButton(
                key: const ValueKey('claimMyUsernameButton'),
                title: FlutterI18n.translate(context, 'claim_my_username'),
                onTap: null,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
