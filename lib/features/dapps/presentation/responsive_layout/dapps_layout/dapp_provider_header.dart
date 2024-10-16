import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:mxc_ui/mxc_ui.dart';

class DAppProviderHeader extends StatelessWidget {
  final String providerTitle;
  const DAppProviderHeader({super.key, required this.providerTitle});

  @override
  Widget build(
    BuildContext context,
  ) {
    return Column(
      children: [
        const SizedBox(
          height: 10,
        ),
        Row(
          children: [
            Text(
              providerTitle,
              style: FontTheme.of(context).h7().copyWith(
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                  color: ColorsTheme.of(context).textPrimary),
            ),
            const Spacer(),
            Text(
              FlutterI18n.translate(context, 'see_all'),
              style: FontTheme.of(context).h7().copyWith(
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                  color: const Color(0xFF00AEFF)),
            ),
          ],
        ),
      ],
    );
  }
}
