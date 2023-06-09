import 'package:datadashwallet/features/home/home.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:flutter_svg/svg.dart';
import 'package:mxc_ui/mxc_ui.dart';

import '../../core/core.dart';
import '../mxc_icons.dart';

class MenuItem {
  const MenuItem(this.iconData, this.text);
  final IconData? iconData;
  final String text;
}

mixin HomeScreenMixin {
  Widget greyContainer(
      {Key? key, required BuildContext context, required child, padding}) {
    return Container(
      height: double.infinity,
      width: double.infinity,
      padding: padding ?? const EdgeInsets.all(5),
      decoration: BoxDecoration(
          color: ColorsTheme.of(context).box,
          borderRadius: const BorderRadius.all(Radius.circular(10))),
      child: child,
    );
  }

  PreferredSizeWidget appBar(BuildContext context) {
    return AppBar(
      leading: MxcCircleButton.icon(
        key: Key("burgerMenuButton"),
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
                          .h8()
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
    );
  }

  Widget bottomNavigationBar(BuildContext context, int currentIndex) {
    final menuItemList = <MenuItem>[
      MenuItem(MXCIcons.home, FlutterI18n.translate(context, 'home')),
      MenuItem(MXCIcons.apps, FlutterI18n.translate(context, 'apps')),
      MenuItem(MXCIcons.wallet, FlutterI18n.translate(context, 'wallet')),
    ];

    return BottomNavigationBar(
        iconSize: 32,
        selectedFontSize: 10,
        unselectedFontSize: 10,
        currentIndex: currentIndex,
        onTap: (int index) {
          switch (index) {
            case 0:
              Navigator.of(context).pushReplacement(
                route(
                  const HomePage(),
                ),
              );
              break;
            case 1:
              Navigator.of(context).pushReplacement(
                route(
                  const AppsTab(),
                ),
              );
              break;
            case 2:
              Navigator.of(context).pushReplacement(
                route(
                  const HomePage(),
                ),
              );
              break;
            default:
          }
        },
        backgroundColor: ColorsTheme.of(context).box,
        selectedIconTheme:
            IconThemeData(color: ColorsTheme.of(context).focusButton),
        selectedItemColor: ColorsTheme.of(context).secondaryText,
        items: menuItemList
            .map((menuItem) => BottomNavigationBarItem(
                icon: Icon(menuItem.iconData), label: menuItem.text))
            .toList());
  }
}
