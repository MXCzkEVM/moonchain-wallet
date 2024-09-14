import 'dart:io';

import 'package:moonchain_wallet/common/common.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:moonchain_wallet/main.dart';
import 'package:mxc_ui/mxc_ui.dart';
import 'splash_base_presenter.dart';
import 'splash_base_state.dart';

abstract class SplashBasePage extends HookConsumerWidget {
  const SplashBasePage({Key? key}) : super(key: key);

  ProviderBase<SplashBasePresenter> get presenter;

  ProviderBase<SplashBaseState> get state;

  bool get drawAnimated => false;

  Widget separator() {
    return const SizedBox(
      height: 16,
    );
  }

  List<Widget>? setButtons(BuildContext context, WidgetRef ref) => null;

  List<Widget> getButtons(BuildContext context, WidgetRef ref) {
    final children = setButtons(context, ref);

    if (children == null) return [];

    for (var i = children.length; i-- > 0;) {
      if (i > 0) children.insert(i, separator());
    }

    return children;
  }

  Widget buildAppBar(BuildContext context, WidgetRef ref) =>
      const SizedBox(height: 20);

  Widget? buildFooter(BuildContext context, WidgetRef ref) => null;

  Widget appLogo(BuildContext context) {
    return Text(
      appName,
      style: FontTheme.of(context).logo(),
    );
  }

  Widget? buildAnimatedLayout(BuildContext context) => null;

  EdgeInsets get childrenPadding => const EdgeInsets.symmetric(horizontal: 24);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final splashPresenter = ref.read(splashBaseContainer.actions);
    final splashState = ref.watch(splashBaseContainer.state);

    Widget? buildAnimatedLayout(
      BuildContext context,
    ) {
      return Expanded(
        child: Stack(fit: StackFit.expand, children: [
          AnimatedPositioned(
            duration: const Duration(milliseconds: 2000),
            curve: Curves.easeInOut,
            top: splashState.animate ? 175 : MediaQuery.of(context).size.height + 600,
            child: appLogo(context),
          ),
          AnimatedPositioned(
            duration: const Duration(milliseconds: 3000),
            curve: Curves.easeInOut,
            bottom: splashState.animate
                ? Platform.isAndroid
                    ? 16
                    : 0
                : -600,
            child: SizedBox(
                width: MediaQuery.of(context).size.width,
                child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: buildFooter(context, ref)!)),
          ),
        ]),
      );
    }

    return MxcPage(
      layout: LayoutType.column,
      useSplashBackground: true,
      childrenPadding: childrenPadding,
      presenter: ref.watch(presenter),
      appBar: buildAppBar(context, ref),
      footer: drawAnimated == true ? null : buildFooter(context, ref),
      children: [
        if (drawAnimated == true)
          buildAnimatedLayout(context)!
        else ...[
          const SizedBox(height: 130),
          appLogo(context),
          const SizedBox(height: Sizes.space4XLarge),
          Expanded(
            child: Column(
              children: getButtons(context, ref),
            ),
          )
        ]
      ],
    );
  }
}
