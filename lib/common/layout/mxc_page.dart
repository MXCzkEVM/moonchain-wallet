import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' hide RefreshCallback;
import 'package:flutter/services.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:mxc_ui/mxc_ui.dart';
import 'package:sliver_tools/sliver_tools.dart';
import 'package:datadashwallet/common/common.dart';
import 'package:datadashwallet/core/core.dart';

import '../../features/home/home.dart';
import 'mxc_page_regular.dart';
import 'mxc_page_layer.dart';
import 'edit_mode_status_bar.dart';

const contentPadding = EdgeInsets.symmetric(horizontal: 16);

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
    this.useFooterPadding = true,
    this.resizeToAvoidBottomInset = true,
    this.useSplashBackground = false,
    this.isEditMode = false,
    this.onAdd,
    this.onDone,
    this.useAppBar = false
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
    bool useFooterPadding,
    bool resizeToAvoidBottomInset,
    bool useSplashBackground,
    bool isEditMode,
    VoidCallback? onAdd,
    VoidCallback? onDone,
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
    bool useAppBar,
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
  final bool resizeToAvoidBottomInset;

  final bool useSplashBackground;

  final bool isEditMode;
  final VoidCallback? onAdd;
  final VoidCallback? onDone;
  final bool useAppBar;
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

  SystemUiOverlayStyle getSystemStyle(
    BuildContext context,
    WidgetRef ref,
    Color? backgroundColor,
  );

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
    if (backgroundColor != null) {
      return backgroundColor!;
    }
    return ColorsTheme.of(context).primaryBackground;
  }

  Widget splashLinearBackground({
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
              Color(0xFF8D023F),
              Color(0xFF09379E),
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
    // SystemChrome.setEnabledSystemUIMode(
    //   SystemUiMode.manual,
    //   overlays: isEditMode
    //       ? []
    //       : [
    //           SystemUiOverlay.top,
    //         ],
    // );
    final presenter = ref.read(homeContainer.actions);
    final state = ref.watch(homeContainer.state);
    
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: getSystemStyle(context, ref, backgroundColor),
      child: Scaffold(
        backgroundColor: resolveBackgroundColor(context),
        extendBodyBehindAppBar: false,
        drawer: drawer,
        key: scaffoldKey,
        resizeToAvoidBottomInset: false,
        floatingActionButton: floatingActionButton,
        bottomNavigationBar: buildBottomNavigation(context, ref),
        appBar: state.isEditMode
            ? null
            : useAppBar ? AppBar(
                elevation: 0.0,
                leading: MxcCircleButton.icon(
                  key: const Key("burgerMenuButton"),
                  icon: Icons.menu_rounded,
                  shadowRadius: 0,
                  onTap: () {},
                  iconSize: 30,
                  color: ColorsTheme.of(context).primaryText,
                  iconFillColor: Colors.transparent,
                ),
                shadowColor: Colors.transparent,
                centerTitle: true,
                actions: [
                  Padding(
                    padding: const EdgeInsetsDirectional.only(end: 16),
                    child: MxcCircleButton.icon(
                      key: const Key("appsButton"),
                      icon: MXCIcons.apps_1,
                      shadowRadius: 30,
                      onTap: () {
                        Navigator.of(context).push(
                          route(
                            const AppsTab(),
                          ),
                        );
                      },
                      iconSize: 30,
                      color: ColorsTheme.of(context).primaryText,
                      iconFillColor:
                          ColorsTheme.of(context).secondaryBackground,
                    ),
                  ),
                ],
                title: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10,),
                          decoration: BoxDecoration(
                            color: ColorsTheme.of(context).white.withOpacity(0.16),
                            borderRadius: const BorderRadius.all(Radius.circular(30)),
                            
                          ),
                          child: Row(
                            children: [
                              MXCDropDown<String>(
                                itemList: const ["MXC zkEVM", "Testnet"],
                                onChanged: (String? newValue) {},
                                selectedItem: "MXC zkEVM",
                                icon: const Padding(
                                  padding: EdgeInsetsDirectional.only(start: 10),
                                ),
                              ),
                              Container(
                                height: 8,
                                width: 8,
                                decoration: BoxDecoration(
                                    color: ColorsTheme.of(context)
                                        .systemStatusActive,
                                    shape: BoxShape.circle),
                              ),
                              const SizedBox(width: 6),
                              Text(FlutterI18n.translate(context, 'online'),
                                  style: FontTheme.of(context)
                                      .h7()
                                      .copyWith(fontWeight: FontWeight.w500)),
                            ],
                          ),
                        ),
                        MXCDropDown<String>(
                          itemList: [
                            state.walletAddress != null
                                ? Formatter.formatWalletAddress(
                                    state.walletAddress!.hex)
                                : "",
                          ],
                          onChanged: (String? newValue) {},
                          selectedItem: state.walletAddress != null
                              ? Formatter.formatWalletAddress(
                                  state.walletAddress!.hex)
                              : "",
                          textStyle: FontTheme.of(context).h7().copyWith(
                              fontSize: 16, fontWeight: FontWeight.w400),
                          icon: Padding(
                            padding: const EdgeInsetsDirectional.only(start: 0),
                            child: Icon(
                              Icons.arrow_drop_down_rounded,
                              size: 32,
                              color: ColorsTheme.of(context).purpleMain,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                backgroundColor: ColorsTheme.of(context).secondaryBackground,
              ) : null,
        body: PresenterHooks(
          presenter: presenter,
          child: splashLinearBackground(
            visiable: useSplashBackground,
            child: SafeArea(
              bottom: maintainBottomSafeArea,
              top: topSafeArea,
              child: Column(
                children: [
                  if (isEditMode)
                    EditAppsModeStatusBar(
                      onAdd: onAdd,
                      onDone: onDone,
                    ),
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
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
