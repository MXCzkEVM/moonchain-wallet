import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:mxc_logic/mxc_logic.dart';
import 'package:mxc_ui/mxc_ui.dart';

import '../../dapps_presenter.dart';

getContextMenuActions(
  DAppsPagePresenter actions,
  BuildContext context,
  Dapp dapp,
  void Function()? shatter,
) =>
    dapp is Bookmark?
        ? getBookMarkContextMenuAction(
            actions,
            context,
            dapp,
            shatter!,
          )
        : getDAppMarkContextMenuAction(
            actions,
            context,
            dapp,
          );

List<Widget> getDAppMarkContextMenuAction(
  DAppsPagePresenter actions,
  BuildContext context,
  Dapp dapp,
) =>
    [
      CupertinoContextMenuAction(
          child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            FlutterI18n.translate(context, 'about'),
            style: FontTheme.of(context)
                .caption1
                .primary()
                .copyWith(fontWeight: FontWeight.w700),
          ),
          Text(
            dapp.app?.description ??
                FlutterI18n.translate(context, 'no_description'),
            style: FontTheme.of(context).caption1.primary(),
          ),
        ],
      )),
      CupertinoContextMenuAction(
          trailingIcon: Icons.phone_iphone_rounded,
          child: Text(FlutterI18n.translate(context, 'edit_home_screen'),
              style: FontTheme.of(context).subtitle1()),
          onPressed: () => popWrapper(actions.changeEditMode, context)),
      CupertinoContextMenuAction(
          trailingIcon: Icons.add_circle_outline_rounded,
          child: Text(FlutterI18n.translate(context, 'add_new_dapp'),
              style: FontTheme.of(context).subtitle1()),
          onPressed: () => popWrapper(actions.addBookmark, context)),
    ];

getBookMarkContextMenuAction(
  DAppsPagePresenter actions,
  BuildContext context,
  Dapp dapp,
  void Function() shatter,
) =>
    [
      CupertinoContextMenuAction(
          child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            FlutterI18n.translate(context, 'about'),
            style: FontTheme.of(context)
                .caption1
                .primary()
                .copyWith(fontWeight: FontWeight.w700),
          ),
          Text(
            getDappAbout(context, dapp),
            style: FontTheme.of(context).caption1.primary(),
          ),
        ],
      )),
      CupertinoContextMenuAction(
          trailingIcon: Icons.phone_iphone_rounded,
          child: Text(FlutterI18n.translate(context, 'edit_home_screen'),
              style: FontTheme.of(context).body1()),
          onPressed: () => popWrapper(actions.changeEditMode, context)),
      CupertinoContextMenuAction(
          trailingIcon: Icons.add_circle_outline_rounded,
          child: Text(FlutterI18n.translate(context, 'add_new_dapp'),
              style: FontTheme.of(context).body1()),
          onPressed: () => popWrapper(actions.addBookmark, context)),
      CupertinoContextMenuAction(
          isDestructiveAction: true,
          trailingIcon: Icons.remove_circle_outline_rounded,
          onPressed: () => popWrapper(() async {
                actions.removeBookmarkDialog(dapp as Bookmark, shatter);
              }, context),
          child: Text(FlutterI18n.translate(context, 'remove_dapp'),
              style: FontTheme.of(context).body1Cl()))
    ];

void popWrapper(void Function()? func, BuildContext context) {
  Navigator.pop(context);
  Future.delayed(
    const Duration(milliseconds: 500),
    () => {if (func != null) func()},
  );
}

String getDappAbout(
  BuildContext context,
  Dapp dapp,
) {
  final dappAbout = dapp is Bookmark
      ? (dapp).title
      : dapp.app?.description ??
          FlutterI18n.translate(context, 'no_description');
  return dappAbout;
}
