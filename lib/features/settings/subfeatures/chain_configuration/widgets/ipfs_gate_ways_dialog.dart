import 'package:moonchain_wallet/common/common.dart';
import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:mxc_ui/mxc_ui.dart';

Future<bool?> showIpfsGateWayDialog(BuildContext context,
    {required List<String> ipfsGateWays,
    required void Function(String text) onTap,
    required selectedIpfsGateway}) {
  String translate(String text) => FlutterI18n.translate(context, text);

  return showBaseBottomSheet<bool>(
    context: context,
    content: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsetsDirectional.only(
              start: Sizes.spaceNormal,
              end: Sizes.spaceNormal,
              bottom: Sizes.space2XLarge),
          child: MxcAppBarEvenly.title(
            titleText: translate('select_x')
                .replaceFirst('{0}', translate('ipfs_gateway')),
            action: Container(
              alignment: Alignment.centerRight,
              child: InkWell(
                child: Icon(
                  MxcIcons.close,
                  size: 32,
                  color: ColorsTheme.of(context, listen: false).iconPrimary,
                ),
                onTap: () => Navigator.of(context).pop(false),
              ),
            ),
          ),
        ),
        ...ipfsGateWays
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
                            e,
                            style: FontTheme.of(
                              context,
                              listen: false,
                            ).body2.primary(),
                            softWrap: true,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                      if (selectedIpfsGateway == e)
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
    ),
  );
}
