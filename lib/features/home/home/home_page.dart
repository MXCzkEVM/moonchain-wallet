import 'package:datadashwallet/features/home/home/presentation/home_tab/home_tab.dart';
import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:flutter_svg/svg.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:datadashwallet/features/home/home.dart';
import 'package:datadashwallet/common/common.dart';
import 'package:mxc_ui/mxc_ui.dart';

import 'home_page_presenter.dart';
import 'home_page_state.dart';

class MenuItem {
  const MenuItem(this.iconData, this.text);
  final IconData iconData;
  final String text;
}

String formatBigNumber(double number) {
  if (number >= 1000000000) {
    // Convert to millions
    double num = number / 1000000000.0;
    return '${num.toStringAsFixed(num.truncateToDouble() == num ? 0 : 1)}B';
  } else if (number >= 1000000) {
    // Convert to millions
    double num = number / 1000000.0;
    return '${num.toStringAsFixed(num.truncateToDouble() == num ? 0 : 1)}M';
  } else if (number >= 1000) {
    // Convert to thousands
    double num = number / 1000.0;
    return '${num.toStringAsFixed(num.truncateToDouble() == num ? 0 : 1)}K';
  } else {
    int accuracy = number.toString().split('.').last.length;
    var str = number.toString();
    if (str.endsWith('.0')) {
      return str.substring(0, str.length - 2);
    }
    return number.toStringAsFixed(accuracy);
  }
}

String formatWalletAddress(String inputString) {
  String formattedString =
      '${inputString.substring(0, 6)}...${inputString.substring(inputString.length - 4)}';
  return formattedString;
}

class HomePage extends HookConsumerWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final menuItemList = <MenuItem>[
      MenuItem(MXCIcons.home, FlutterI18n.translate(context, 'home')),
      MenuItem(MXCIcons.apps, FlutterI18n.translate(context, 'apps')),
      MenuItem(MXCIcons.wallet, FlutterI18n.translate(context, 'wallet')),
    ];
    final presenter = ref.read(homeContainer.actions);
    final state = ref.watch(homeContainer.state);

    return MxcPage(
        appBar: AppBar(
          leading: MxcCircleButton.icon(
            key: const Key("burgerMenuButton"),
            icon: Icons.menu_rounded,
            onTap: () {},
            iconSize: 30,
            color: ColorsTheme.of(context).primaryText,
          ),
          centerTitle: true,
          // profile image commented because It might be used in future.
          // actions: [
          //   Container(
          //       height: 35,
          //       width: 35,
          //       padding: const EdgeInsets.all(2),
          //       margin: const EdgeInsetsDirectional.only(end: 10),
          //       decoration: BoxDecoration(boxShadow: [
          //         BoxShadow(color: Color(0xffF43178), blurRadius: 6, spreadRadius: -3),
          //         BoxShadow(color: ColorsTheme.of(context).white, blurRadius: 2, spreadRadius: -1),
          //       ], shape: BoxShape.circle),
          //       child: CircleAvatar(backgroundImage: ImagesTheme.of(context).ruben))
          // ],
          title: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      MXCDropDown<String>(
                        itemList: ["MXC zkEVM", "Testnet"],
                        onChanged: (String? newValue) {},
                        selectedItem: "MXC zkEVM",
                        icon: const Padding(
                          padding: EdgeInsetsDirectional.only(start: 10),
                        ),
                      ),
                      Text(FlutterI18n.translate(context, 'active'),
                          style: FontTheme.of(context)
                              .h7()
                              .copyWith(fontWeight: FontWeight.w500)),
                      const SizedBox(width: 12),
                      Container(
                        height: 6,
                        width: 6,
                        decoration: BoxDecoration(
                            color: ColorsTheme.of(context).active,
                            shape: BoxShape.circle),
                      )
                    ],
                  ),
                  MXCDropDown<String>(
                    itemList: ["TheLegend27.mxc", "TheLegend28.mxc"],
                    onChanged: (String? newValue) {},
                    selectedItem: "TheLegend27.mxc",
                    icon: Padding(
                      padding: const EdgeInsetsDirectional.only(start: 10),
                      child: SvgPicture.asset("assets/svg/drop_down.svg"),
                    ),
                  ),
                ],
              ),
            ],
          ),
          backgroundColor: ColorsTheme.of(context).box,
        ),
        presenter: presenter,
        resizeToAvoidBottomInset: true,
        backgroundColor: ColorsTheme.of(context).primaryBackground,
        bottomNavigationBar: BottomNavigationBar(
            iconSize: 32,
            selectedFontSize: 10,
            unselectedFontSize: 10,
            currentIndex: state.currentIndex,
            onTap: (int index) {
              presenter.changeIndex(index);
            },
            backgroundColor: ColorsTheme.of(context).box,
            selectedIconTheme:
                IconThemeData(color: ColorsTheme.of(context).focusButton),
            selectedItemColor: ColorsTheme.of(context).secondaryText,
            items: menuItemList
                .map((menuItem) => BottomNavigationBarItem(
                    icon: Icon(menuItem.iconData), label: menuItem.text))
                .toList()),
        layout: LayoutType.column,
        useContentPadding: false,
        childrenPadding:
            const EdgeInsets.symmetric(vertical: 25, horizontal: 20),
        children: [_buildChildren(state.currentIndex)]);
  }

  Widget _buildChildren(int currentIndex) {
    switch (currentIndex) {
      case 0:
        return const HomeTab();
      case 1:
        return const AppsTab();
      case 2:
        return const HomeTab();
      default:
        return const HomeTab();
    }
  }
}
