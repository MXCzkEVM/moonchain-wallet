import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:mxc_ui/mxc_ui.dart';

class StatusBar extends StatelessWidget {
  const StatusBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
      child: Row(
        children: [
          GestureDetector(
            onTap: () {},
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
              child: const Icon(
                Icons.add,
                color: Colors.black,
              ),
            ),
          ),
          const Spacer(),
          GestureDetector(
            onTap: () {},
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
              child: Text(
                FlutterI18n.translate(context, 'done'),
                style: FontTheme.of(context)
                    .body2()
                    .copyWith(color: Colors.black, fontWeight: FontWeight.w700),
              ),
            ),
          )
        ],
      ),
    );
  }
}
