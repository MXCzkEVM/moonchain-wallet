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
        onDone: () => presenter.changeEditMode(),
        appBar: state.isEditMode
            ? null
            : AppBar(
                elevation: 0.0,
                leading: MxcCircleButton.icon(
                  key: const Key("burgerMenuButton"),
                  icon: Icons.menu_rounded,
                  shadowRadius: 0,
                  onTap: () {},
                  iconSize: 30,
                  color: ColorsTheme.of(context).primaryText,
                  iconFillColor: Colors.transparent,
                ),
                shadowColor: Colors.transparent,
                centerTitle: true,
                actions: [
                  Padding(
                    padding: const EdgeInsetsDirectional.only(end: 16),
                    child: MxcCircleButton.icon(
                      key: const Key("appsButton"),
                      icon: MXCIcons.apps_1,
                      shadowRadius: 30,
                      onTap: () {
                        Navigator.of(context).push(
                          route(
                            const AppsTab(),
                          ),
                        );
                      },
                      iconSize: 30,
                      color: ColorsTheme.of(context).primaryText,
                      iconFillColor:
                          ColorsTheme.of(context).secondaryBackground,
                    ),
                  ),
                ],
                title: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            MXCDropDown<String>(
                              itemList: const ["MXC zkEVM", "Testnet"],
                              onChanged: (String? newValue) {},
                              selectedItem: "MXC zkEVM",
                              icon: const Padding(
                                padding: EdgeInsetsDirectional.only(start: 10),
                              ),
                            ),
                            Container(
                              height: 8,
                              width: 8,
                              decoration: BoxDecoration(
                                  color: ColorsTheme.of(context)
                                      .systemStatusActive,
                                  shape: BoxShape.circle),
                            ),
                            const SizedBox(width: 6),
                            Text(FlutterI18n.translate(context, 'online'),
                                style: FontTheme.of(context)
                                    .h7()
                                    .copyWith(fontWeight: FontWeight.w500)),
                          ],
                        ),
                        MXCDropDown<String>(
                          itemList: [
                            state.walletAddress != null
                                ? Formatter.formatWalletAddress(
                                    state.walletAddress!.hex)
                                : "",
                          ],
                          onChanged: (String? newValue) {},
                          selectedItem: state.walletAddress != null
                              ? Formatter.formatWalletAddress(
                                  state.walletAddress!.hex)
                              : "",
                          textStyle: FontTheme.of(context).h7().copyWith(
                              fontSize: 16, fontWeight: FontWeight.w400),
                          icon: Padding(
                            padding: const EdgeInsetsDirectional.only(start: 0),
                            child: Icon(
                              Icons.arrow_drop_down_rounded,
                              size: 32,
                              color: ColorsTheme.of(context).purpleMain,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                backgroundColor: ColorsTheme.of(context).secondaryBackground,
              ),
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
