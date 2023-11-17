import 'package:datadashwallet/common/common.dart';
import 'package:datadashwallet/features/common/common.dart';
import 'package:datadashwallet/features/settings/presentation/settings_page_presenter.dart';
import 'package:datadashwallet/features/settings/subfeatures/about_page/widgets/app_term.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:mxc_logic/mxc_logic.dart';
import 'package:mxc_ui/mxc_ui.dart';

class AboutPage extends HookConsumerWidget {
  const AboutPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settingsState = ref.watch(settingsContainer.state);

    return MxcPage(
      crossAxisAlignment: CrossAxisAlignment.center,
      appBar: AppNavBar(
        title: Text(
          FlutterI18n.translate(context, 'about'),
          style: FontTheme.of(context).body1.primary(),
        ),
      ),
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: Sizes.spaceNormal),
          child: Image(
            image: ImagesTheme.of(context).axs,
          ),
        ),
        Text(
          '${FlutterI18n.translate(context, 'app_version')}${settingsState.appVersion ?? ''}',
          style: FontTheme.of(context).subtitle1().copyWith(
                color: ColorsTheme.of(context).textGrey1,
              ),
        ),
        const SizedBox(height: Sizes.space2XLarge),
        const AppTerm(
          name: 'terms_and_service',
          externalLink: Urls.axsTermsConditions,
        ),
        const AppTerm(
          name: 'privacy_policy',
          externalLink: Urls.axsPrivacy,
        ),
      ],
    );
  }
}
