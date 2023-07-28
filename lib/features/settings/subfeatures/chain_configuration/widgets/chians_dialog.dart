import 'package:datadashwallet/common/common.dart';
import 'package:datadashwallet/features/settings/subfeatures/chain_configuration/entities/network.dart';
import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:mxc_ui/mxc_ui.dart';

Future<bool?> showChainsDialog(
  BuildContext context, {
  required List<Network> networks,
  required void Function(int chainId) onTap,
}) {
  String translate(String text) => FlutterI18n.translate(context, text);

  return showModalBottomSheet<bool>(
    context: context,
    useRootNavigator: true,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (BuildContext context) => Container(
      padding: const EdgeInsets.only(
          top: Sizes.spaceNormal, bottom: Sizes.space3XLarge),
      decoration: BoxDecoration(
        color: ColorsTheme.of(context).layerSheetBackground,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsetsDirectional.only(
                start: Sizes.spaceNormal,
                end: Sizes.spaceNormal,
                bottom: Sizes.space2XLarge),
            child: MxcAppBarEvenly.title(
              titleText:
                  translate('select_x').replaceFirst('{0}', translate('chain')),
              action: Container(
                alignment: Alignment.centerRight,
                child: InkWell(
                  child: Icon(MXCIcons.close,
                      size: 32, color: ColorsTheme.of(context).iconPrimary),
                  onTap: () => Navigator.of(context).pop(false),
                ),
              ),
            ),
          ),
          ...networks
              .map((e) => Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: Sizes.spaceSmall,
                        horizontal: Sizes.spaceXLarge),
                    child: Row(children: [
                      SvgPicture.asset(
                        e.logo,
                        height: 24,
                        width: 24,
                      ),
                      const SizedBox(
                        width: Sizes.spaceXSmall,
                      ),
                      Text(
                        e.label,
                        style: FontTheme.of(context).body2.primary(),
                      ),
                      const Spacer(),
                      if (e.enabled == true)
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: Sizes.spaceNormal),
                          child: Icon(
                            MXCIcons.check,
                            size: 24,
                            color: ColorsTheme.of(context).white400,
                          ),
                        ),
                    ]),
                  ))
              .toList(),
        ],
      ),
    ),
  );
}
