import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' hide RefreshCallback;
import 'package:flutter/services.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:mxc_ui/mxc_ui.dart';
import 'package:datadashwallet/core/core.dart';

import 'layout.dart';

class MxcPageRegular extends MxcPage {
  const MxcPageRegular({
    Key? key,
    Key? scaffoldKey,
    required List<Widget> children,
    EdgeInsets? childrenPadding,
    Widget? footer,
    Widget? appBar,
    Widget? bottomNavigationBar,
    bool useContentPadding = true,
    Widget? drawer,
    LayoutType layout = LayoutType.scrollable,
    RefreshCallback? onRefresh,
    Presenter? presenter,
    CrossAxisAlignment crossAxisAlignment = CrossAxisAlignment.center,
    ScrollController? scrollController,
    bool fixedFooter = false,
    Widget? floatingActionButton,
    Color? backgroundColor,
    Gradient? backgroundGradient,
    bool useFooterPadding = true,
    bool resizeToAvoidBottomInset = true,
    bool useSplashBackground = false,
    bool useAppBar = false,
  }) : super.internal(
          key: key,
          scaffoldKey: scaffoldKey,
          children: children,
          childrenPadding: childrenPadding,
          footer: footer,
          appBar: appBar,
          bottomNavigationBar: bottomNavigationBar,
          useContentPadding: useContentPadding,
          drawer: drawer,
          layout: layout,
          onRefresh: onRefresh,
          presenter: presenter,
          crossAxisAlignment: crossAxisAlignment,
          scrollController: scrollController,
          fixedFooter: fixedFooter,
          floatingActionButton: floatingActionButton,
          backgroundColor: backgroundColor,
          backgroundGradient: backgroundGradient,
          useFooterPadding: useFooterPadding,
          resizeToAvoidBottomInset: resizeToAvoidBottomInset,
          useSplashBackground: useSplashBackground,
        );

  @override
  final bool topSafeArea = true;

  @override
  Widget buildAppBar(BuildContext context, WidgetRef ref) =>
      appBar ?? const SizedBox();

  @override
  Widget? buildBottomNavigation(BuildContext context, WidgetRef ref) =>
      bottomNavigationBar;

  @override
  Widget buildScrollableContent(BuildContext context, WidgetRef ref) {
    return MxcScrollableContent(
      scrollController: scrollController,
      useSlivers: true,
      footer: footer == null
          ? Container(
              color: backgroundColor,
            )
          : Container(
              color: backgroundColor,
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: useFooterPadding
                    ? MxcScrollableContent.defaultFooterPadding(fixedFooter)
                    : EdgeInsets.zero,
                child: footer,
              ),
            ),
      footerPadding:
          fixedFooter ? EdgeInsets.zero : const EdgeInsets.only(bottom: 16),
      usePadding: false,
      fixedFooter: fixedFooter,
      children: [
        if (onRefresh != null) ...[
          CupertinoSliverRefreshControl(
            onRefresh: onRefresh,
          ),
        ],
        if (appBar != null)
          const SliverPadding(padding: EdgeInsets.only(top: 16)),
        childrenSliver,
        if (footer == null)
          const SliverPadding(padding: EdgeInsets.only(top: 32)),
      ],
    );
  }

  @override
  Widget buildColumnContent(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: crossAxisAlignment,
      children: [
        ...children,
        if (footer != null)
          Padding(
            padding: useFooterPadding
                ? const EdgeInsets.only(top: 5, bottom: 16)
                : EdgeInsets.zero,
            child: footer,
          ),
      ],
    );
  }
}
