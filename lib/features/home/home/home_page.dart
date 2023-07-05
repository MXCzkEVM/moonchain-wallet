import 'package:datadashwallet/core/core.dart';
import 'package:datadashwallet/features/home/apps/apps.dart';
import 'package:datadashwallet/features/home/home/presentation/widgets/slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:datadashwallet/features/home/home.dart';
import 'package:datadashwallet/common/common.dart';
import 'package:mxc_ui/mxc_ui.dart';

import 'home_page_presenter.dart';
import 'home_page_state.dart';
import 'presentation/widgets/balance_panel.dart';

class HomePage extends HookConsumerWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final presenter = ref.read(homeContainer.actions);
    final state = ref.watch(homeContainer.state);

    return MxcPage(
        isEditMode: state.isEditMode,
        onAdd: () => Navigator.of(context).push(
              route.featureDialog(
                const AddDApp(),
              ),
            ),
        useAppBar: true,
        onDone: () => presenter.changeEditMode(),
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
              const BalancePanel(),
              const SizedBox(
                height: 32,
              ),
              Row(
                children: [
                  Text(FlutterI18n.translate(context, 'transaction_history'),
                      style: FontTheme.of(context).h7().copyWith(
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                          color: ColorsTheme.of(context).secondaryText)),
                  const Spacer(),
                  MxcChipButton(
                    key: const Key('addTokenButton'),
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    titleStyle:
                        FontTheme.of(context).h7().copyWith(fontSize: 14),
                    onTap: () {},
                    title: FlutterI18n.translate(context, 'add_token'),
                    icon: const Icon(
                      Icons.add,
                      size: 20,
                    ),
                    buttonDecoration: BoxDecoration(
                      color: ColorsTheme.of(context).white.withOpacity(.16),
                      borderRadius: BorderRadius.circular(40),
                    ),
                    alignIconStart: true,
                  )
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
