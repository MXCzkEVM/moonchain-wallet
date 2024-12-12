import 'package:moonchain_wallet/common/common.dart';
import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:mxc_logic/mxc_logic.dart';
import 'package:mxc_ui/mxc_ui.dart';

Future<bool?> showBGNotificationsFrequencyDialog(
  BuildContext context, {
  required void Function(PeriodicalCallDuration duration) onTap,
  required PeriodicalCallDuration selectedFrequency,
}) {
  String translate(String text) => FlutterI18n.translate(context, text);

  return showBaseBottomSheet<bool>(
    context: context,
    bottomSheetTitle: translate('select_x')
        .replaceFirst('{0}', translate('frequency').toLowerCase()),
    closeButtonReturnValue: false,
    widgets: [
      ...PeriodicalCallDuration.values
          .map((e) => InkWell(
                onTap: () {
                  onTap(e);
                  Navigator.of(context).pop(false);
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: Sizes.spaceXLarge,
                            vertical: Sizes.spaceSmall),
                        alignment: AlignmentDirectional.centerStart,
                        child: Text(
                          e.toStringFormatted(),
                          style: FontTheme.of(context, listen: false)
                              .body2
                              .primary(),
                          softWrap: true,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                    if (selectedFrequency == e)
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: Sizes.spaceNormal),
                        child: Icon(
                          MxcIcons.check,
                          size: 24,
                          color:
                              ColorsTheme.of(context, listen: false).white400,
                        ),
                      ),
                  ],
                ),
              ))
          .toList(),
    ],
  );
}
