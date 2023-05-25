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
    Widget? footer,
    Widget? appBar,
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
    bool useFooterPadding = true,
    bool resizeToAvoidBottomInset = true,
    bool useAppLinearBackground = false,
  })  : assert(layout != LayoutType.column2 || footer == null || fixedFooter,
            'layout: column2 and fixedFooter: false isn\'t compatible, pls set fixedFooter: true'),
        super.internal(
          key: key,
          scaffoldKey: scaffoldKey,
          children: children,
          footer: footer,
          appBar: appBar,
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
          useFooterPadding: useFooterPadding,
          resizeToAvoidBottomInset: resizeToAvoidBottomInset,
          useAppLinearBackground: useAppLinearBackground,
        );

  @override
  final bool topSafeArea = false;

  @override
  bool get maintainBottomSafeArea => false;

  @override
  SystemUiOverlayStyle getSystemStyle(
    BuildContext context,
    WidgetRef ref,
    Color? backgroundColor,
  ) {
    return SystemUiOverlayStyle(
      systemNavigationBarColor:
          backgroundColor ?? ColorsTheme.of(context).secondaryBackground,
      systemNavigationBarIconBrightness:
          Theme.of(context).brightness == Brightness.dark
              ? Brightness.light
              : Brightness.dark,
    );
  }

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
  Widget buildAppBar(BuildContext context, WidgetRef ref) => const SizedBox();

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
                  ColorsTheme.of(context).secondaryBackground,
            )
          : Container(
              color: ColorsTheme.of(context).secondaryBackground,
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
                      color: ColorsTheme.of(context).secondaryBackground,
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
              color: ColorsTheme.of(context).secondaryBackground,
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
