import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:mxc_ui/mxc_ui.dart';
import 'package:lottie/lottie.dart';

class GesturesInstructionItem {
  const GesturesInstructionItem({
    required this.image,
    required this.description,
  });

  final String image;
  final String description;
}

Future<bool?> showGesturesInstructionDialog(BuildContext context) async {
  return await showModalBottomSheet<bool>(
    context: context,
    useRootNavigator: true,
    isScrollControlled: true,
    isDismissible: false,
    enableDrag: false,
    backgroundColor: Colors.transparent,
    builder: (BuildContext context) => const GesturesInstruction(),
  );
}

class GesturesInstruction extends StatefulWidget {
  const GesturesInstruction({
    Key? key,
  }) : super(key: key);

  @override
  State<GesturesInstruction> createState() => _GesturesInstructionState();
}

class _GesturesInstructionState extends State<GesturesInstruction> {
  int _index = 0;
  final _gestures = [
    const GesturesInstructionItem(
      image: 'assets/lottie/gestures/swipe-right.json',
      description: 'swipe_right',
    ),
    const GesturesInstructionItem(
      image: 'assets/lottie/gestures/swipe-left.json',
      description: 'swipe_left',
    ),
    const GesturesInstructionItem(
      image: 'assets/lottie/gestures/double-tap.json',
      description: 'double_tap_reload',
    ),
    // Next sprint needs to do this feature
    // const GesturesInstructionItem(
    //   image: 'assets/lottie/gestures/pinch.json',
    //   description: 'pinch_all_dapps',
    // ),
  ];

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    String getButtonText() {
      if (_gestures.length == _index + 1) {
        return FlutterI18n.translate(context, 'done');
      }

      return '${FlutterI18n.translate(context, 'next')} ${_index + 1}/${_gestures.length}';
    }

    return WillPopScope(
      onWillPop: () => Future.value(false),
      child: BackdropFilter(
        filter: ImageFilter.blur(
          sigmaX: 20,
          sigmaY: 20,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: Sizes.spaceXLarge),
            Lottie.asset(
              _gestures[_index].image,
              width: 120,
              height: 120,
            ),
            Text(
              FlutterI18n.translate(
                context,
                _gestures[_index].description,
              ),
              textAlign: TextAlign.center,
              style: FontTheme.of(context)
                  .body2()
                  .copyWith(color: ColorsTheme.of(context).textGrey1),
            ),
            const SizedBox(height: Sizes.space7XLarge),
            MxcChipButton(
              key: const ValueKey('nextButton'),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 31, vertical: 12),
              title: getButtonText(),
              textStyle: FontTheme.of(context).body2().copyWith(
                  fontWeight: FontWeight.w600,
                  color: ColorsTheme.of(context).btnTextInvert2),
              buttonState: ChipButtonStates.activeState,
              onTap: () {
                if (_gestures.length <= _index + 1) {
                  Navigator.of(context).pop(true);
                  return;
                }
                setState(() => _index = _index + 1);
              },
            )
          ],
        ),
      ),
    );
  }
}
