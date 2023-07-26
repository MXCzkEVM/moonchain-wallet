import 'package:datadashwallet/common/common.dart';
import 'package:datadashwallet/features/settings/settings_page_presenter.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:mxc_ui/mxc_ui.dart';

class CopyableItem extends HookConsumerWidget {
  const CopyableItem({super.key, required this.text});

  final String text;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final presenter = ref.read(settingsContainer.actions);

    return InkWell(
      onTap: (){
        presenter.copyToClipboard(text);
      },
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Text(
            text,
            style: FontTheme.of(context).body1.primary(),
          ),
          const SizedBox(width: Sizes.spaceXSmall,),
          Icon(
            MXCIcons.copy,
            size: 20,
            color: ColorsTheme.of(context).iconGrey1,
          )
        ],
      ),
    );
  }
}