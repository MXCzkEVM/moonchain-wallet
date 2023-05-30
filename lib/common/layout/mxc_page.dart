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

const contentPadding = EdgeInsets.symmetric(horizontal: 16);

abstract class MxcPage extends HookConsumerWidget {
  const MxcPage.internal({
    Key? key,
    this.scaffoldKey,
    required this.children,
    this.footer,
    this.appBar,
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
    this.useFooterPadding = true,
    this.resizeToAvoidBottomInset = true,
    this.useAppLinearBackground = false,
  })  : assert(scrollController == null || layout != LayoutType.column),
        super(key: key);

  const factory MxcPage({
    Key? key,
    Key? scaffoldKey,
    required List<Widget> children,
    Widget? footer,
    Widget? appBar,
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
    bool useAppLinearBackground,
  }) = MxcPageRegular;

  const factory MxcPage.layer({
    Key? key,
    Key? scaffoldKey,
    required List<Widget> children,
    Widget? footer,
    Widget? appBar,
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
    bool useAppLinearBackground,
  }) = MxcPageLayer;

  final Key? scaffoldKey;

  final List<Widget> children;
  final Widget? footer;
  final Widget? appBar;
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
  final bool resizeToAvoidBottomInset;

  final bool useAppLinearBackground;

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

  @Deprecated('use [buildChildrenAsSliver]')
  Widget get childrenSliver => buildChildrenAsSliver(null);

  SystemUiOverlayStyle getSystemStyle(
    BuildContext context,
    WidgetRef ref,
    Color? backgroundColor,
  );

  Widget buildAppBar(BuildContext context, WidgetRef ref);

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
    if (backgroundColor != null) {
      return backgroundColor!;
    }
    return ColorsTheme.of(context).primaryBackground;
  }

  Widget appLinearBackground({
    Widget? child,
    bool visiable = true,
  }) {
    if (visiable) {
      return Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: <Color>[
              Color(0xff8D023F),
              Color(0xff09379E),
            ],
            tileMode: TileMode.mirror,
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
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: getSystemStyle(context, ref, backgroundColor),
      child: Scaffold(
        backgroundColor: resolveBackgroundColor(context),
        drawer: drawer,
        key: scaffoldKey,
        resizeToAvoidBottomInset: false,
        floatingActionButton: floatingActionButton,
        body: PresenterHooks(
          presenter: presenter,
          child: appLinearBackground(
            visiable: useAppLinearBackground,
            child: SafeArea(
              bottom: maintainBottomSafeArea,
              top: topSafeArea,
              child: Column(
                children: [
                  buildAppBar(context, ref),
                  Expanded(child: content(context, ref)),
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
    );
  }
}
