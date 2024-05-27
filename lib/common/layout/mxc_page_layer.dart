import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' hide RefreshCallback;
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:mxc_ui/mxc_ui.dart';
import 'package:sliver_tools/sliver_tools.dart';
import 'package:datadashwallet/core/core.dart';

import 'layout.dart';

class MxcPageLayer extends MxcPage {
  const MxcPageLayer({
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
  })  : assert(layout != LayoutType.column2 || footer == null || fixedFooter,
            'layout: column2 and fixedFooter: false isn\'t compatible, pls set fixedFooter: true'),
        super.internal(
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
  final bool topSafeArea = false;

  @override
  bool get maintainBottomSafeArea => false;

  @override
  Color resolveBackgroundColor(BuildContext context) {
    if (backgroundColor != null) {
      return backgroundColor!;
    }
    if (BottomFlowDialog.maybeOf(context) != null) {
      return ColorsTheme.of(context).primaryBackground;
    }
    return ColorsTheme.of(context).primaryBackground;
  }

  @override
  Widget buildAppBar(BuildContext context, WidgetRef ref) =>
      appBar ?? const SizedBox();

  @override
  Widget? buildBottomNavigation(BuildContext context, WidgetRef ref) =>
      bottomNavigationBar;

  @override
  Widget buildScrollableContent(BuildContext context, WidgetRef ref) {
    var fixedFooter = this.fixedFooter;
    if (layout == LayoutType.column2 && footer == null) {
      fixedFooter = true;
    }

    final scrollController = this.scrollController ??
        useScrollController(
          initialScrollOffset:
              BottomFlowDialog.maybeOf(context)?.overscrollValue.value ?? 0,
        );

    useEffect(
      () {
        final dialog = BottomFlowDialog.maybeOf(context);
        if (dialog == null) {
          return null;
        }

        final key = dialog.assignScrollReporter();

        void onScrollChangeListener() => dialog.reportScrollChange(
              key,
              scrollController.offset,
            );

        void onOverscrollChangeListener(double offset) {
          if (!dialog.shouldReactOnScrollChanges(key)) {
            return;
          }
          if (scrollController.offset == offset) {
            return;
          }
          if (scrollController.offset > initialBottomFlowDialogOffset + 15) {
            return;
          }
          if (scrollController.offset != offset) {
            scrollController.jumpTo(offset);
          }
        }

        scrollController.addListener(onScrollChangeListener);
        final subscription =
            dialog.overscrollValue.listen(onOverscrollChangeListener);

        return () {
          scrollController.removeListener(onScrollChangeListener);
          subscription.cancel();
          dialog.unassignScrollReporter(key);
        };
      },
      [scrollController, BottomFlowDialog.maybeOf(context)],
    );

    return MxcScrollableContent(
      scrollController: scrollController,
      useSlivers: true,
      footer: footer == null
          ? Container(
              color: backgroundColor ??
                  ColorsTheme.of(context).layerSheetBackground,
            )
          : Container(
              color: ColorsTheme.of(context).layerSheetBackground,
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: (useFooterPadding
                        ? MxcScrollableContent.defaultFooterPadding(fixedFooter)
                        : EdgeInsets.zero)
                    .copyWith(
                  bottom: MediaQueryData.fromWindow(window).padding.bottom +
                      (useFooterPadding
                          ? MxcScrollableContent.defaultFooterPadding(
                                  fixedFooter)
                              .bottom
                          : EdgeInsets.zero.bottom),
                ),
                child: footer,
              ),
            ),
      footerPadding: EdgeInsets.zero,
      fixedFooter: fixedFooter,
      usePadding: false,
      childrenBuilder: (ctx, cnstr) => [
        if (onRefresh != null) ...[
          CupertinoSliverRefreshControl(
            onRefresh: onRefresh,
            builder: (
              ctx,
              refreshState,
              pulledExtent,
              refreshTriggerPullDistance,
              refreshIndicatorExtent,
            ) {
              return Padding(
                padding:
                    const EdgeInsets.only(top: initialBottomFlowDialogOffset),
                child: CupertinoSliverRefreshControl.buildRefreshIndicator(
                  ctx,
                  refreshState,
                  pulledExtent,
                  refreshTriggerPullDistance,
                  refreshIndicatorExtent,
                ),
              );
            },
          ),
        ],
        SliverPadding(
          padding: EdgeInsets.only(
            top: MediaQuery.of(context).viewPadding.top +
                initialBottomFlowDialogOffset,
          ),
          sliver: SliverStack(
            children: [
              AnimatedBuilder(
                animation: scrollController,
                builder: (ctx, w) => SliverPositioned.fill(
                  child: ClipRRect(
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(
                        BottomFlowDialog.maybeOf(context)
                                ?.expectedBorderRadius ??
                            bottomFlowDialogRoundedCornersRadius,
                      ),
                      topRight: Radius.circular(
                        BottomFlowDialog.maybeOf(context)
                                ?.expectedBorderRadius ??
                            bottomFlowDialogRoundedCornersRadius,
                      ),
                    ),
                    child: ColoredBox(
                      color: ColorsTheme.of(context).layerSheetBackground,
                    ),
                  ),
                ),
              ),
              MultiSliver(
                children: [
                  if (appBar != null)
                    SliverToBoxAdapter(
                      child: Column(
                        children: [
                          appBar!,
                          const SizedBox(height: 16),
                        ],
                      ),
                    ),
                  SliverLayoutBuilder(
                    builder: (ctx, sliverCnstr) => buildChildrenAsSliver(
                      layout == LayoutType.column2
                          ? BoxConstraints(
                              maxHeight: cnstr.maxHeight -
                                  sliverCnstr.precedingScrollExtent -
                                  (footer == null ? 32 : 0),
                              maxWidth: cnstr.maxWidth,
                            )
                          : null,
                    ),
                  ),
                  if (footer == null && layout != LayoutType.column2)
                    const SliverPadding(padding: EdgeInsets.only(top: 32))
                  else if (fixedFooter)
                    SliverFillRemaining(
                      hasScrollBody: false,
                      fillOverscroll: true,
                      child: Container(height: 1),
                    ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget buildColumnContent(BuildContext context, WidgetRef ref) {
    useEffect(
      () {
        final dialog = BottomFlowDialog.maybeOf(context);
        if (dialog == null) {
          return null;
        }

        final key = dialog.assignScrollReporter();
        dialog.reportScrollChange(key, 0);
        // no scroll is supported on MxcPage with layoutType column, so we resetting scroll offset

        return () {
          dialog.unassignScrollReporter(key);
        };
      },
      [BottomFlowDialog.maybeOf(context)],
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          height: MediaQuery.of(context).viewPadding.top +
              initialBottomFlowDialogOffset,
        ),
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(bottomFlowDialogRoundedCornersRadius),
                topRight: Radius.circular(bottomFlowDialogRoundedCornersRadius),
              ),
              color: ColorsTheme.of(context).layerSheetBackground,
            ),
            child: Column(
              crossAxisAlignment: crossAxisAlignment,
              children: [
                if (appBar != null) appBar!,
                const SizedBox(height: 16),
                if (useContentPadding)
                  Expanded(
                    child: Padding(
                      padding: contentPadding,
                      child: Column(
                        children: children,
                      ),
                    ),
                  )
                else
                  ...children,
                if (footer != null)
                  Padding(
                    padding: EdgeInsets.only(
                      top: 5,
                      bottom: useFooterPadding ? 20 : 0,
                    ),
                    child: footer,
                  ),
              ],
            ),
          ),
        )
      ],
    );
  }
}
