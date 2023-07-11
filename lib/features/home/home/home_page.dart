import 'package:datadashwallet/core/core.dart';
import 'package:datadashwallet/features/home/add_token/add_token_page.dart';
import 'package:datadashwallet/features/home/home/presentation/widgets/slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:datadashwallet/features/home/home.dart';
import 'package:datadashwallet/common/common.dart';
import 'package:mxc_ui/mxc_ui.dart';

import 'home_page_presenter.dart';
import 'home_page_state.dart';

class HomePage extends HookConsumerWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final presenter = ref.read(homeContainer.actions);
    final state = ref.watch(homeContainer.state);

    return MxcPage(
        useAppBar: true,
        presenter: presenter,
        resizeToAvoidBottomInset: true,
        backgroundColor: ColorsTheme.of(context).secondaryBackground,
        layout: LayoutType.column,
        useContentPadding: false,
        childrenPadding: const EdgeInsets.only(top: 25, right: 24, left: 24),
        children: [
          Expanded(
              child: ListView(
            children: [
              Text(FlutterI18n.translate(context, 'wallet'),
                  style: FontTheme.of(context).h4().copyWith(
                      fontSize: 34,
                      fontWeight: FontWeight.w400,
                      color: ColorsTheme.of(context).primaryText)),
              const SizedBox(
                height: 6,
              ),
              const BalancePanel(false),
              const SizedBox(
                height: 32,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text(FlutterI18n.translate(context, 'transaction_history'),
                      style: FontTheme.of(context).h7().copyWith(
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                          color: ColorsTheme.of(context).secondaryText)),
                ],
              ),
              const SizedBox(
                height: 12,
              ),
              const RecentTransactions(),
              const SizedBox(
                height: 32,
              ),
              const HomeSlider(),
            ],
          ))
        ]);
  }
}
