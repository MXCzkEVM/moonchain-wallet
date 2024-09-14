import 'package:moonchain_wallet/common/common.dart';
import 'package:moonchain_wallet/features/settings/presentation/settings_page_presenter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:mxc_ui/mxc_ui.dart';

class CopyableItem extends HookConsumerWidget {
  const CopyableItem(
      {super.key, required this.text, required this.copyableText});

  final String text;
  final String copyableText;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final presenter = ref.read(settingsContainer.actions);

    return InkWell(
      onTap: () {
        presenter.copyToClipboard(copyableText);
      },
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            text,
            style: FontTheme.of(context).body1.primary(),
          ),
          const SizedBox(
            width: Sizes.spaceXSmall,
          ),
          Icon(
            MxcIcons.copy,
            size: 20,
            color: ColorsTheme.of(context).iconGrey1,
          )
        ],
      ),
    );
  }
}
