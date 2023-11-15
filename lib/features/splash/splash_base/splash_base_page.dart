import 'dart:io';

import 'package:datadashwallet/common/common.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
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
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Image(
          image: ImagesTheme.of(context).axsWithTitle,
        ),
      ],
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
          Positioned(top: 40, child: appLogo(context)),
          FutureBuilder(
            future: Future.delayed(const Duration(seconds: 4)),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                // Return an empty container while waiting for the delay
                return AnimatedPositioned(
                  duration: const Duration(milliseconds: 4000),
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
                );
              } else {
                return AnimatedPositioned(
                  duration: const Duration(milliseconds: 4000),
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
                );
              }
            },
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
          const SizedBox(height: 40),
          appLogo(context),
          const SizedBox(height: 48),
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
