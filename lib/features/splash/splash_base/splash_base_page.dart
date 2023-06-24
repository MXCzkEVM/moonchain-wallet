import 'package:datadashwallet/common/common.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:lottie/lottie.dart';
import 'package:mxc_ui/mxc_ui.dart';

import 'splash_base_presenter.dart';
import 'splash_base_state.dart';

abstract class SplashBasePage extends HookConsumerWidget {
  const SplashBasePage({Key? key}) : super(key: key);

  List<Widget> setButtons(BuildContext context, WidgetRef ref);

  ProviderBase<SplashBasePresenter> get presenter;

  ProviderBase<SplashBaseState> get state;

  bool get drawAnimated => false;

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
    final splashPresenter = ref.read(splashBaseContainer.actions);
    final splashState = ref.watch(splashBaseContainer.state);
    Widget appLogo(BuildContext context) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Image(
            image: ImagesTheme.of(context).datadash,
          ),
          Text(
            'DataDash',
            style: FontTheme.of(context).h4.white().copyWith(
                  fontWeight: FontWeight.w500,
                ),
          ),
          Text(
            'WALLET',
            style: FontTheme.of(context).h5.white(),
          ),
        ],
      );
    }

    Widget drawAnimatedLayer() {
      return Expanded(
          child: Stack(
        fit: StackFit.expand,
        children: [
          AnimatedPositioned(
            duration: const Duration(milliseconds: 1500),
            curve: Curves.easeInOut,
            top: splashState.showLogo ? 50 : -200,
            child: SizedBox(
                width: MediaQuery.of(context).size.width,
                child: Center(child: appLogo(context))),
          ),
          AnimatedPositioned(
            duration: const Duration(milliseconds: 1500),
            curve: Curves.easeInOut,
            bottom: splashState.showLogo ? 50 : -200,
            child: SizedBox(
              width: MediaQuery.of(context).size.width,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 72),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: getButtons(context, ref),
                ),
              ),
            ),
          ),
        ],
      ));
    }

    List<Widget> drawLayer() {
      return [
        Expanded(
          child: AnimatedPositioned(
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeInOut,
            top: splashState.showLogo ? 50 : -100,
            child: appLogo(context),
          ),
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
      ];
    }

    return MxcPage(
      layout: LayoutType.column,
      useSplashBackground: true,
      presenter: ref.read(presenter),
      children: [if (drawAnimated) drawAnimatedLayer() else ...drawLayer()],
    );
  }
}
