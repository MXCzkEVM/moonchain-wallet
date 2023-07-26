import 'package:datadashwallet/common/common.dart';
import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:mxc_ui/mxc_ui.dart';

class AppTerm extends StatelessWidget {
  const AppTerm({
    super.key,
    required this.name,
    required this.externalLink,
  });

  final String name;
  final String externalLink;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => openUrl(externalLink),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: Sizes.spaceSmall),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              FlutterI18n.translate(context, name),
              style: FontTheme.of(context).body2(),
            ),
            const Icon(MXCIcons.external_link),
          ],
        ),
      ),
    );
  }
}
