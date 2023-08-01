import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:mxc_ui/mxc_ui.dart';

import 'account_item.dart';

void showAccountsDialog({
  required BuildContext context,
  VoidCallback? onTap,
}) {
  showModalBottomSheet<void>(
    context: context,
    useRootNavigator: true,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (BuildContext context) => Container(
      padding: const EdgeInsets.only(left: 16, right: 16, top: 0, bottom: 44),
      decoration: BoxDecoration(
        color: ColorsTheme.of(context).screenBackground,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          MxcAppBarEvenly.title(
            titleText: FlutterI18n.translate(context, 'accounts'),
            action: Container(
              alignment: Alignment.centerRight,
              child: InkWell(
                child: const Icon(Icons.close),
                onTap: () => Navigator.of(context).pop(false),
              ),
            ),
          ),
          ListView.builder(
            padding: EdgeInsets.zero,
            itemCount: 1,
            shrinkWrap: true,
            itemBuilder: (ctx, index) {
              return AccountItem(
                name: 'Account1',
                mns: 'ss',
                address: 'ssss',
              );
            },
          ),
          const SizedBox(height: Sizes.spaceXSmall),
          MxcButton.primary(
            key: const ValueKey('addAccountButton'),
            title: FlutterI18n.translate(context, 'add_new_account'),
            onTap: onTap,
            size: MxcButtonSize.xl,
          ),
        ],
      ),
    ),
  );
}
