import 'package:moonchain_wallet/common/common.dart';
import 'package:moonchain_wallet/core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:mxc_ui/mxc_ui.dart';

class AppTerm extends HookConsumerWidget {
  const AppTerm(
      {super.key,
      required this.name,
      required this.externalLink,
      this.isFile = false});

  final String name;
  final String externalLink;
  final bool isFile;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    late final launcherUseCase = ref.read(launcherUseCaseProvider);

    return InkWell(
      onTap: () => isFile
          ? launcherUseCase.openMXCWalletPrivacy(externalLink)
          : launcherUseCase.launchUrlInExternalAppWithString(externalLink),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: Sizes.spaceSmall),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              FlutterI18n.translate(context, name),
              style: FontTheme.of(context).body2(),
            ),
            const Icon(MxcIcons.external_link),
          ],
        ),
      ),
    );
  }
}
