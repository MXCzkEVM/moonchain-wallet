import 'package:datadashwallet/features/home/apps/apps.dart';
import 'package:datadashwallet/features/home/apps/subfeatures/apps_tab/presentation/apps_page_presenter.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class DAppIcon extends HookConsumerWidget {
  const DAppIcon({
    super.key,
    required this.dapp,
    this.onTap,
    this.isEditMode = false,
  });

  final DApp dapp;
  final VoidCallback? onTap;
  final bool isEditMode;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: GestureDetector(
        onLongPress: () => ref.read(appsPagePageContainer.actions).changeEditMode(),
        onTap: isEditMode ? null : () => openAppPage(context, dapp),
        child: dapp.image != null
            ? Image(image: AssetImage(dapp.image!))
            : const SizedBox(),
      ),
    );
  }
}
