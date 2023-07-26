import 'package:datadashwallet/common/common.dart';
import 'package:datadashwallet/features/common/common.dart';
import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:mxc_ui/mxc_ui.dart';

import 'language_page_presenter.dart';

class LanguagePage extends ConsumerWidget {
  const LanguagePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final presenter = ref.read(languageContainer.actions);
    final state = ref.watch(languageContainer.state);

    return MxcPage(
      appBar: AppNavBar(
        title: Text(
          FlutterI18n.translate(context, 'language'),
          style: FontTheme.of(context).body1.primary(),
        ),
      ),
      presenter: ref.watch(languageContainer.actions),
      children: [
        for (final language in state.languages)
          InkWell(
            onTap: () => presenter.changeLanguage(language),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: Sizes.spaceSmall),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    FlutterI18n.translate(context, language.nativeName),
                    style: FontTheme.of(context).body1(),
                  ),
                  if (state.currentLanguage == language) ...[
                    const Icon(Icons.check_rounded),
                  ] else ...[
                    const SizedBox(height: 24),
                  ]
                ],
              ),
            ),
          ),
      ],
    );
  }
}
