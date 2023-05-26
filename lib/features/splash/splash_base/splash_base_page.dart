import 'package:datadashwallet/common/common.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'splash_base_page_presenter.dart';
import 'splash_base_page_state.dart';

abstract class SplashBasePage extends HookConsumerWidget
    with SplashScreenMixin {
  const SplashBasePage({Key? key}) : super(key: key);

  List<Widget> setButtons(BuildContext context, WidgetRef ref);

  ProviderBase<SplashBasePagePresenter> get presenter;

  ProviderBase<SplashBasePageState> get state;

  Widget separator() {
    return const SizedBox(
      height: 28,
    );
  }

  List<Widget> getButtons(BuildContext context, WidgetRef ref) {
    final children = setButtons(context, ref);
    for (var i = children.length; i-- > 0;) {
      if (i > 0) children.insert(i, separator());
    }

    return children;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MxcPage(
      layout: LayoutType.column,
      useAppLinearBackground: true,
      presenter: ref.read(presenter),
      children: [
        Expanded(
          child: appLogo(context),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 72),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: getButtons(context, ref),
            ),
          ),
        ),
      ],
    );
  }
}
