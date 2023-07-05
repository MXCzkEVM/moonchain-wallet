import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:mxc_ui/mxc_ui.dart';

class TransactionStatusChip extends StatelessWidget {
  final Color color;
  final String title;

  const TransactionStatusChip(
      {super.key, required this.color, required this.title});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
          borderRadius: const BorderRadius.all(Radius.circular(100)),
          color: color.withOpacity(0.32),
          border: Border.all(color: color, width: 0.5)),
      child: Text(
        FlutterI18n.translate(context, title),
        style: FontTheme.of(context).h7().copyWith(fontSize: 10, color: color),
      ),
    );
  }
}
