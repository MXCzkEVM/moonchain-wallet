import 'package:datadashwallet/common/common.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:mxc_ui/mxc_ui.dart';

import 'recovery_phrase_base_presenter.dart';
import 'recovery_phrase_base_state.dart';

abstract class RecoveryPhraseBasePage extends HookConsumerWidget {
  const RecoveryPhraseBasePage({Key? key}) : super(key: key);

  ProviderBase<RecoveryPhraseBasePresenter> get presenter;

  ProviderBase<RecoveryPhraseBaseState> get state;

  Widget icon(BuildContext context);
  Color themeColor({BuildContext? context});

  Widget buildAppBar(BuildContext context, WidgetRef ref) =>
      MxcAppBar.close(text: '');

  Widget? buildFooter(BuildContext context, WidgetRef ref) => null;

  Widget buildAppLogo(BuildContext context) {
    return Container(
      width: 88,
      height: 88,
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: icon(context),
    );
  }

  Widget buildAlert(BuildContext context);

  Widget? buildAccept(BuildContext context, WidgetRef ref) => null;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final acceptComponent = buildAccept(context, ref);

    return MxcPage(
      layout: LayoutType.column,
      useSplashBackground: true,
      childrenPadding: const EdgeInsets.symmetric(horizontal: 24),
      presenter: ref.watch(presenter),
      appBar: buildAppBar(context, ref),
      footer: buildFooter(context, ref),
      children: [
        buildAppLogo(context),
        const Spacer(),
        buildAlert(context),
        const Spacer(),
        if (acceptComponent != null) ...[
          acceptComponent,
          const SizedBox(height: 16),
        ]
      ],
    );
  }
}
