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
      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 22),
      child: Row(
        children: [
          EditModeButton(
            onTap: onAdd,
            child: Icon(
              Icons.add,
              size: 20,
              color: ColorsTheme.of(context).iconPrimary,
            ),
          ),
          const Spacer(),
          EditModeButton(
            onTap: onDone,
            child: Text(
              FlutterI18n.translate(context, 'done'),
              style: FontTheme.of(context).subtitle1().copyWith(
                  color: ColorsTheme.of(context).textPrimary,
                  fontWeight: FontWeight.w700),
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
        width: 56,
        height: 22,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.all(
            Radius.circular(30),
          ),
          color: ColorsTheme.of(context).grey3,
        ),
        child: child,
      ),
    );
  }
}
