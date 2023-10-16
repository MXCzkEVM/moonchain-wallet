import 'package:datadashwallet/features/settings/subfeatures/accounts/row_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:mxc_ui/mxc_ui.dart';

import 'account_item.dart';

void showAddAccountsDialog({
  required BuildContext context,
  bool isLoading = false,
  required VoidCallback onAdd,
  required VoidCallback onImport,
}) {
  showModalBottomSheet<void>(
    context: context,
    useRootNavigator: true,
    isScrollControlled: true,
    useSafeArea: true,
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
            titleText: FlutterI18n.translate(context, 'add_account'),
            action: Container(
              alignment: Alignment.centerRight,
              child: InkWell(
                child: const Icon(Icons.close),
                onTap: () => Navigator.of(context).pop(false),
              ),
            ),
          ),
          RowItem(FlutterI18n.translate(context, 'add_new_account'),
              Icons.add_rounded, onAdd),
          RowItem(FlutterI18n.translate(context, 'import_account'),
              Icons.file_download_outlined, onImport),
        ],
      ),
    ),
  );
}
