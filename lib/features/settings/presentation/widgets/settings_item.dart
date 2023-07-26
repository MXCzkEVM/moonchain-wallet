import 'package:datadashwallet/core/core.dart';
import 'package:datadashwallet/features/settings/entities/setting.dart';
import 'package:flutter/material.dart';
import 'package:mxc_ui/mxc_ui.dart';

class SettingItem extends StatelessWidget {
  const SettingItem({super.key, required this.settingData});

  final Setting settingData;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: Sizes.spaceNormal),
      child: InkWell(
        onTap: () => Navigator.of(context).push(route(settingData.page)),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: Sizes.spaceSmall),
          child: Row(
            children: [
              Icon(
                settingData.icon,
                size: 24,
                color: ColorsTheme.of(context).iconGrey3,
              ),
              const SizedBox(
                width: 24,
              ),
              Text(
                settingData.title,
                style: FontTheme.of(context).body2.primary(),
              ),
              const Spacer(),
              const SizedBox(
                width: 16,
              ),
              Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: ColorsTheme.of(context).iconWhite32,
              )
            ],
          ),
        ),
      ),
    );
  }
}
