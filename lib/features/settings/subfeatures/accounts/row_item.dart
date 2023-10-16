import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:mxc_ui/mxc_ui.dart';

class RowItem extends HookConsumerWidget {
  const RowItem(
    this.title,
    this.icon,
    this.onTap, {
    super.key,
  });

  final String title;
  final IconData icon;
  final void Function() onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      margin: const EdgeInsets.only(top: Sizes.spaceNormal),
      child: InkWell(
        onTap: () => onTap(),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: Sizes.spaceSmall),
          child: Row(
            children: [
              Icon(
                icon,
                size: 24,
                color: ColorsTheme.of(context).iconPrimary,
              ),
              const SizedBox(
                width: 24,
              ),
              Text(
                title,
                style: FontTheme.of(context).body2.primary(),
              ),
              const Spacer(),
              const SizedBox(
                width: 16,
              ),
              // trailingIcon != null
              //     ? Icon(
              //         MxcIcons.external_link,
              //         size: 24,
              //         color: ColorsTheme.of(context).iconPrimary,
              //       )
              //     : Icon(
              //         Icons.arrow_forward_ios,
              //         size: 16,
              //         color: ColorsTheme.of(context).iconWhite32,
              // )
            ],
          ),
        ),
      ),
    );
  }
}
