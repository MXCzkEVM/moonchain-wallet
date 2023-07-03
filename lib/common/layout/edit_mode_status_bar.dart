import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:mxc_ui/mxc_ui.dart';

class EditAppsModeStatusBar extends StatelessWidget {
  const EditAppsModeStatusBar({
    super.key,
    this.onAdd,
    this.onDone,
  });

  final VoidCallback? onAdd;
  final VoidCallback? onDone;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
      child: Row(
        children: [
          EditModeButton(
            onTap: onAdd,
            child: const Icon(
              Icons.add,
              color: Colors.black,
            ),
          ),
          const Spacer(),
          EditModeButton(
            onTap: onDone,
            child: Text(
              FlutterI18n.translate(context, 'done'),
              style: FontTheme.of(context)
                  .body2()
                  .copyWith(color: Colors.black, fontWeight: FontWeight.w700),
            ),
          )
        ],
      ),
    );
  }
}

class EditModeButton extends StatelessWidget {
  const EditModeButton({
    super.key,
    required this.child,
    this.onTap,
  });

  final Widget child;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 66,
        height: 28,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.all(
            Radius.circular(30),
          ),
          color: ColorsTheme.of(context).white.withOpacity(0.5),
        ),
        child: child,
      ),
    );
  }
}
