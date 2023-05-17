import 'package:datadashwallet/common/common.dart';
import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:mxc_ui/mxc_ui.dart';

import 'login_page_presentater.dart';

class LoginPage extends ConsumerWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MxcContextHook(
      bridge: ref.watch(loginPageContainer.actions).bridge,
      child: Material(
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: <Color>[
                Color(0xff8D023F),
                Color(0xff09379E),
              ],
              tileMode: TileMode.mirror,
            ),
          ),
          child: Column(
            children: [
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Image(
                      image: ImagesTheme.of(context).datadash,
                      // width: 160,
                      // height: 160,
                    ),
                    Text(
                      'DataDash',
                      style: FontTheme.of(context).h4().copyWith(
                            color: ColorsTheme.of(context).white,
                            fontWeight: FontWeight.w500,
                          ),
                    ),
                    Text(
                      'WALLET',
                      style: FontTheme.of(context).h5().copyWith(
                            color: ColorsTheme.of(context).white,
                          ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 88),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    // mainAxisSize: MainAxisSize.min,
                    children: [
                      MxcFullRoundedButton(
                        key: const ValueKey('createButton'),
                        title: FlutterI18n.translate(context, 'create_wallet'),
                        onTap: () {},
                      ),
                      const SizedBox(
                        height: 40,
                      ),
                      MxcFullRoundedButton(
                        key: const ValueKey('importButton'),
                        title: FlutterI18n.translate(context, 'import_wallet'),
                        onTap: () {},
                      )
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
