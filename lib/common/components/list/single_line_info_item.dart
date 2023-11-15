import 'package:datadashwallet/common/common.dart';
import 'package:datadashwallet/core/src/providers/providers_use_cases.dart';
import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:mxc_ui/mxc_ui.dart';

class SingleLineInfoItem extends HookConsumerWidget {
  const SingleLineInfoItem(
      {super.key,
      required this.title,
      required this.value,
      this.hint,
      this.valueActionIcon});

  final String title;
  final String value;
  final String? hint;
  final Widget? valueActionIcon;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    late final launcherUseCase = ref.read(launcherUseCaseProvider);

    final isAddress = Validation.isAddress(value);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: Sizes.spaceXSmall),
      child: Row(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Text(
                FlutterI18n.translate(context, title),
                style: FontTheme.of(context).body1.secondary(),
              ),
              const SizedBox(width: 10),
            ],
          ),
          Expanded(
            child: InkWell(
              onTap:
                  isAddress ? () => launcherUseCase.viewAddress(value) : null,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Expanded(
                    child: Text(
                      value,
                      style: FontTheme.of(context).body1.primary(),
                      softWrap: true,
                      textAlign: TextAlign.end,
                    ),
                  ),
                  if (valueActionIcon != null)
                    valueActionIcon!
                  else if (isAddress) ...[
                    const SizedBox(width: 8),
                    Icon(
                      MxcIcons.external_link,
                      size: 24,
                      color: ColorsTheme.of(context).textSecondary,
                    ),
                  ],
                  if (hint != null) ...[
                    const SizedBox(width: 4),
                    Text(
                      hint ?? '--',
                      style: FontTheme.of(context).body1().copyWith(
                            color: ColorsTheme.of(context).textGrey2,
                          ),
                    ),
                  ]
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
