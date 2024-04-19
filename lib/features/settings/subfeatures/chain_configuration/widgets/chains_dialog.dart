import 'package:datadashwallet/common/common.dart';
import 'package:mxc_logic/src/domain/entities/network.dart';
import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:mxc_ui/mxc_ui.dart';

import 'chain_logo_widget.dart';

Future<bool?> showChainsDialog(BuildContext context,
    {required List<Network> networks,
    required void Function(int chainId) onTap,
    required selectedChainId}) {
  String translate(String text) => FlutterI18n.translate(context, text);

  return showModalBottomSheet<bool>(
    context: context,
    useRootNavigator: true,
    isScrollControlled: true,
    useSafeArea: true,
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
                  child: Icon(MxcIcons.close,
                      size: 32, color: ColorsTheme.of(context).iconPrimary),
                  onTap: () => Navigator.of(context).pop(false),
                ),
              ),
            ),
          ),
          ...networks
              .map((e) => InkWell(
                    onTap: () {
                      onTap(e.chainId);
                      Navigator.of(context).pop(false);
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: Sizes.spaceSmall,
                          horizontal: Sizes.spaceXLarge),
                      child: Row(children: [
                        ChainLogoWidget(logo: e.logo),
                        const SizedBox(
                          width: Sizes.spaceXSmall,
                        ),
                        Text(
                          e.label ?? e.web3RpcHttpUrl,
                          style: FontTheme.of(context).body2.primary(),
                        ),
                        const Spacer(),
                        if (selectedChainId == e.chainId)
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: Sizes.spaceNormal),
                            child: Icon(
                              MxcIcons.check,
                              size: 24,
                              color: ColorsTheme.of(context).white400,
                            ),
                          ),
                      ]),
                    ),
                  ))
              .toList(),
        ],
      ),
    ),
  );
}
