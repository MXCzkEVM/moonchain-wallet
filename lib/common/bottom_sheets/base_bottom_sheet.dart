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
  bool isDismissible = true,
  bool enableDrag = true,
  Color? bottomSheetBackgroundColor,
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
    isDismissible: isDismissible,
    enableDrag: enableDrag,
    backgroundColor: Colors.transparent,
    useSafeArea: true,
    builder: (BuildContext context) => ConstrainedBox(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.9,
      ),
      child: Container(
        padding: const EdgeInsets.only(
            top: 0,
            bottom: Sizes.space3XLarge,
            right: Sizes.spaceNormal,
            left: Sizes.spaceNormal),
        decoration: BoxDecoration(
          color: bottomSheetBackgroundColor ??
              ColorsTheme.of(context).layerSheetBackground,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Container(
          padding: const EdgeInsetsDirectional.only(
              start: Sizes.spaceSmall,
              end: Sizes.spaceSmall,
              bottom: Sizes.space2XLarge),
          child: content ??
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  MxcAppBarEvenly.title(
                    titleText: translate(bottomSheetTitle!),
                    action: hasCloseButton
                        ? Container(
                            alignment: Alignment.centerRight,
                            child: InkWell(
                              child: const Icon(Icons.close, size: 24),
                              onTap: () => Navigator.of(context)
                                  .pop(closeButtonReturnValue),
                            ),
                          )
                        : null,
                  ),
                  ...widgets!
                ],
              ),
        ),
      ),
    ),
  );
}
