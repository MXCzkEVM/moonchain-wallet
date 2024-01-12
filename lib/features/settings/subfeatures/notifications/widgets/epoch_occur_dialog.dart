import 'package:datadashwallet/common/common.dart';
import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:mxc_ui/mxc_ui.dart';

Future<bool?> showEpochOccurDialog(BuildContext context,
    {required void Function(int occur) onTap, required selectedOccur}) {
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
              titleText: translate('select_x')
                  .replaceFirst('{0}', translate('occurrence').toLowerCase()),
              action: Container(
                alignment: Alignment.centerRight,
                child: InkWell(
                  child: Icon(
                    MxcIcons.close,
                    size: 32,
                    color: ColorsTheme.of(context).iconPrimary,
                  ),
                  onTap: () => Navigator.of(context).pop(false),
                ),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
                itemCount: 100,
                itemBuilder: (context, index) => InkWell(
                      onTap: () {
                        onTap(index + 1);
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
                                (index + 1).toString(),
                                style: FontTheme.of(context).body2.primary(),
                                softWrap: true,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),
                          if (selectedOccur == index + 1)
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: Sizes.spaceNormal),
                              child: Icon(
                                MxcIcons.check,
                                size: 24,
                                color: ColorsTheme.of(context).white400,
                              ),
                            ),
                        ],
                      ),
                    )),
          )
        ],
      ),
    ),
  );
}
