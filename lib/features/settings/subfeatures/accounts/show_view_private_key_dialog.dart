import 'package:datadashwallet/common/common.dart';
import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:mxc_ui/mxc_ui.dart';

void showViewPrivateKeyDialog(
    {required BuildContext context,
    required String privateKey,
    required Function(String) onCopy}) {
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
            titleText: FlutterI18n.translate(context, 'private_key'),
            action: Container(
              alignment: Alignment.centerRight,
              child: InkWell(
                child: const Icon(Icons.close),
                onTap: () => Navigator.of(context).pop(false),
              ),
            ),
          ),
          SingleLineInfoItem(
            title: 'private_key',
            value: privateKey,
            valueActionIcon: IconButton(
                icon: Icon(
                  MxcIcons.copy,
                  size: 20,
                  color: ColorsTheme.of(context).iconGrey1,
                ),
                onPressed: () {
                  onCopy(privateKey);
                  Navigator.of(context).pop();
                }),
          ),
          const SizedBox(height: Sizes.spaceXSmall),
          MxcButton.primary(
            key: const ValueKey('doneButton'),
            title: FlutterI18n.translate(context, 'done'),
            onTap: () => Navigator.of(context).pop(false),
            size: AxsButtonSize.xl,
          ),
        ],
      ),
    ),
  );
}
