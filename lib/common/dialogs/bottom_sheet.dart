import 'package:flutter/material.dart';
import 'package:mxc_ui/mxc_ui.dart';

Future<T?> showGeneralBottomSheet<T>(
  BuildContext context, {
  required WidgetBuilder builder,
}) {
  return showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    useRootNavigator: true,
    useSafeArea: true,
    builder: (context) {
      return Container(
        decoration: ShapeDecoration(
          color: ColorsTheme.of(context).cardBackground,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(8),
              topRight: Radius.circular(8),
            ),
          ),
        ),
        margin: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 8),
            Center(
              child: Container(
                width: 44,
                height: 4,
                decoration: BoxDecoration(
                  color: ColorsTheme.of(context).textSecondary,
                  borderRadius: const BorderRadius.all(
                    Radius.circular(20),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Builder(builder: builder),
            const SizedBox(height: 30),
          ],
        ),
      );
    },
  );
}
