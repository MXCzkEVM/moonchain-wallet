import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:mxc_ui/mxc_ui.dart';

Future<T?> showBaseBottomSheet<T>({
  required BuildContext context,
  bool hasCloseButton = true,
  bool? closeButtonReturnValue,

  /// Has translation so just pass the key
  String? bottomSheetTitle,
  List<Widget>? widgets,
  Widget? content,
}) {
  assert(
      ((widgets != null && bottomSheetTitle != null) || content != null) &&
          (!((widgets != null && bottomSheetTitle != null) && content != null)),
      "Only one of content or widgets should be specified.");
  String translate(String text) => FlutterI18n.translate(context, text);

  return showModalBottomSheet<T>(
    context: context,
    useRootNavigator: true,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    useSafeArea: true,
    builder: (BuildContext context) => ConstrainedBox(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.95,
      ),
      child: Container(
        padding: const EdgeInsets.only(
            top: 0,
            bottom: Sizes.space3XLarge,
            right: Sizes.spaceNormal,
            left: Sizes.spaceNormal),
        decoration: BoxDecoration(
          color: ColorsTheme.of(context).layerSheetBackground,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: content ??
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsetsDirectional.only(
                      start: Sizes.spaceNormal,
                      end: Sizes.spaceNormal,
                      bottom: Sizes.space2XLarge),
                  child: MxcAppBarEvenly.title(
                    titleText: translate(bottomSheetTitle!),
                    action: hasCloseButton
                        ? Container(
                            alignment: Alignment.centerRight,
                            child: InkWell(
                              child: const Icon(Icons.close, size: 30),
                              onTap: () => Navigator.of(context)
                                  .pop(closeButtonReturnValue),
                            ),
                          )
                        : null,
                  ),
                ),
                ...widgets!
              ],
            ),
      ),
    ),
  );
}
