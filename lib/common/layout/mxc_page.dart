import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' hide RefreshCallback;
import 'package:flutter/services.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:mxc_ui/mxc_ui.dart';
import 'package:sliver_tools/sliver_tools.dart';
import 'package:datadashwallet/common/common.dart';
import 'package:datadashwallet/core/core.dart';

import 'mxc_page_regular.dart';
import 'mxc_page_layer.dart';

const contentPadding = EdgeInsets.symmetric(horizontal: Sizes.spaceXLarge);

abstract class MxcPage extends HookConsumerWidget {
  const MxcPage.internal({
    Key? key,
    this.scaffoldKey,
    required this.children,
    this.footer,
    this.appBar,
    this.bottomNavigationBar,
    this.childrenPadding,
    this.useContentPadding = true,
    this.drawer,
    this.layout = LayoutType.scrollable,
    this.onRefresh,
    this.presenter,
    this.crossAxisAlignment = CrossAxisAlignment.center,
    this.scrollController,
    this.fixedFooter = false,
    this.floatingActionButton,
    this.backgroundColor,
    this.backgroundGradient,
    this.useFooterPadding = true,
    this.resizeToAvoidBottomInset = true,
    this.useSplashBackground = false,
  })  : assert(scrollController == null || layout != LayoutType.column),
        super(key: key);

  const factory MxcPage({
    Key? key,
    Key? scaffoldKey,
    required List<Widget> children,
    EdgeInsets? childrenPadding,
    Widget? footer,
    Widget? appBar,
    Widget? bottomNavigationBar,
    bool useContentPadding,
    Widget? drawer,
    LayoutType layout,
    RefreshCallback? onRefresh,
    Presenter? presenter,
    CrossAxisAlignment crossAxisAlignment,
    ScrollController? scrollController,
    bool fixedFooter,
    Widget? floatingActionButton,
    Color? backgroundColor,
    Gradient? backgroundGradient,
    bool useFooterPadding,
    bool resizeToAvoidBottomInset,
    bool useSplashBackground,
    bool useAppBar,
  }) = MxcPageRegular;

  const factory MxcPage.layer({
    Key? key,
    Key? scaffoldKey,
    required List<Widget> children,
    EdgeInsets? childrenPadding,
    Widget? footer,
    Widget? appBar,
    Widget? bottomNavigationBar,
    bool useContentPadding,
    Widget? drawer,
    LayoutType layout,
    RefreshCallback? onRefresh,
    Presenter? presenter,
    CrossAxisAlignment crossAxisAlignment,
    ScrollController? scrollController,
    bool fixedFooter,
    Widget? floatingActionButton,
    Color? backgroundColor,
    bool useFooterPadding,
    bool resizeToAvoidBottomInset,
    bool useSplashBackground,
  }) = MxcPageLayer;

  final Key? scaffoldKey;

  final List<Widget> children;
  final EdgeInsets? childrenPadding;
  final Widget? footer;
  final Widget? appBar;
  final Widget? bottomNavigationBar;
  final Widget? drawer;
  final bool useContentPadding;
  final bool useFooterPadding;
  final Presenter? presenter;

  final LayoutType layout;
  final Future<void> Function()? onRefresh;
  final CrossAxisAlignment crossAxisAlignment;
  final ScrollController? scrollController;
  final bool fixedFooter;
  final Widget? floatingActionButton;
  final Color? backgroundColor;
  final Gradient? backgroundGradient;
  final bool resizeToAvoidBottomInset;

  final bool useSplashBackground;

  Widget buildChildrenAsSliver(BoxConstraints? constraints) {
    Widget sliver;
    if (layout == LayoutType.slivers) {
      sliver = MultiSliver(children: children);
    } else if (layout == LayoutType.scrollable) {
      sliver = SliverToBoxAdapter(
        child: Column(
          crossAxisAlignment: crossAxisAlignment,
          children: children,
        ),
      );
    } else if (layout == LayoutType.column2) {
      sliver = SliverToBoxAdapter(
        child: ConstrainedBox(
          constraints: constraints ?? const BoxConstraints(),
          child: Column(
            crossAxisAlignment: crossAxisAlignment,
            children: children,
          ),
        ),
      );
    } else {
      throw UnimplementedError();
    }

    return SliverPadding(
      padding: useContentPadding ? contentPadding : EdgeInsets.zero,
      sliver: sliver,
    );
  }

  Widget get childrenSliver => buildChildrenAsSliver(null);

  Widget buildAppBar(BuildContext context, WidgetRef ref);

  Widget? buildBottomNavigation(BuildContext context, WidgetRef ref);

  Widget buildColumnContent(BuildContext context, WidgetRef ref);

  Widget buildScrollableContent(BuildContext context, WidgetRef ref);

  Widget content(BuildContext context, WidgetRef ref) {
    switch (layout) {
      case LayoutType.scrollable:
      case LayoutType.slivers:
        return buildScrollableContent(context, ref);
      case LayoutType.column:
        return buildColumnContent(context, ref);
      case LayoutType.column2:
        return this is MxcPageLayer
            ? buildScrollableContent(context, ref)
            : buildColumnContent(context, ref);
    }
  }

  bool get topSafeArea;

  bool get placeBottomInsetFiller => resizeToAvoidBottomInset;

  bool get maintainBottomSafeArea => true;

  Color resolveBackgroundColor(BuildContext context) {
    if (backgroundGradient != null) {
      return Colors.transparent;
    }
    if (backgroundColor != null) {
      return backgroundColor!;
    }
    return ColorsTheme.of(context).screenBackground;
  }

  Widget splashLinearBackground({
    Widget? child,
    bool visiable = true,
  }) {
    if (visiable) {
      return Container(
        decoration: const BoxDecoration(
          gradient: SweepGradient(
            colors: <Color>[
              Color(0xFF0F46F4),
              Color(0xFF082FAF),
            ],
            tileMode: TileMode.clamp,
            transform: GradientRotation(2.5),
          ),
        ),
        child: child,
      );
    } else {
      return Container(child: child);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

    return AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle(
          systemNavigationBarColor: Colors.transparent,
          systemNavigationBarDividerColor: Colors.transparent,
          systemNavigationBarContrastEnforced: false,
          statusBarColor: Colors.transparent,
          systemStatusBarContrastEnforced: false,
          statusBarBrightness: Theme.of(context).brightness == Brightness.dark
              ? Brightness.dark
              : Brightness.light,
          statusBarIconBrightness:
              Theme.of(context).brightness == Brightness.dark
                  ? Brightness.light
                  : Brightness.dark,
          systemNavigationBarIconBrightness:
              Theme.of(context).brightness == Brightness.dark
                  ? Brightness.dark
                  : Brightness.light,
        ),
        child: Container(
          decoration: BoxDecoration(
            gradient: backgroundGradient,
          ),
          child: Scaffold(
            backgroundColor: resolveBackgroundColor(context),
            extendBodyBehindAppBar: false,
            drawer: drawer,
            key: scaffoldKey,
            resizeToAvoidBottomInset: false,
            floatingActionButton: floatingActionButton,
            bottomNavigationBar: buildBottomNavigation(context, ref),
            floatingActionButtonLocation:
                FloatingActionButtonLocation.miniCenterFloat,
            body: PresenterHooks(
              presenter: presenter,
              child: splashLinearBackground(
                visiable: useSplashBackground,
                child: SafeArea(
                  bottom: maintainBottomSafeArea,
                  top: topSafeArea,
                  child: Column(
                    children: [
                      buildAppBar(context, ref),
                      Expanded(
                          child: Padding(
                        padding: childrenPadding ?? EdgeInsets.zero,
                        child: content(context, ref),
                      )),
                      if (placeBottomInsetFiller)
                        AnimatedSize(
                          curve: Curves.easeOutQuad,
                          duration: const Duration(milliseconds: 275),
                          child: SizedBox(
                            height: MediaQuery.of(context).viewInsets.bottom,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ));
  }
}
