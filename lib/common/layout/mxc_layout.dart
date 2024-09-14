import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:moonchain_wallet/common/common.dart';
import 'package:moonchain_wallet/core/core.dart';

typedef ChildrenBuilder = List<Widget> Function(
    BuildContext context, BoxConstraints constraints);

class MxcScrollableContent extends StatelessWidget {
  MxcScrollableContent({
    Key? key,
    List<Widget>? children,
    ChildrenBuilder? childrenBuilder,
    this.footer,
    this.usePadding = true,
    this.useSlivers = false,
    this.physics = const BouncingScrollPhysics(),
    this.scrollController,
    EdgeInsets? footerPadding,
    this.fixedFooter = false,
    this.handleBottomSafeArea = true,
  })  : footerPadding = footerPadding ?? defaultFooterPadding(fixedFooter),
        childrenBuilder = childrenBuilder ?? ((ctx, _) => children!),
        super(key: key);

  final ChildrenBuilder childrenBuilder;

  final Widget? footer;
  final bool usePadding;
  final bool useSlivers;
  final ScrollPhysics physics;
  final ScrollController? scrollController;
  final EdgeInsets footerPadding;
  final bool fixedFooter;
  final bool handleBottomSafeArea;

  static EdgeInsets defaultFooterPadding(bool fixedFooter) {
    if (fixedFooter) return const EdgeInsets.only(bottom: 20);
    return const EdgeInsets.only(top: 40, bottom: 20);
  }

  Widget _footer() => Container(
        alignment: Alignment.bottomCenter,
        child: SizedBox(
          width: double.infinity,
          child: footer,
        ),
      );

  Widget _sliverFooter() {
    return SliverFillRemaining(
      hasScrollBody: false,
      fillOverscroll: true,
      child: SizedBox(
        height: double.infinity,
        child: _footer(),
      ),
    );
  }

  Widget withFloatingFooter() {
    return LayoutBuilder(
      builder: (ctx, cnstr) => CustomScrollView(
        controller: scrollController,
        slivers: [
          if (useSlivers)
            ...childrenBuilder(ctx, cnstr)
          else
            SliverList(
              delegate: SliverChildListDelegate(childrenBuilder(ctx, cnstr)),
            ),
          if (footer != null) _sliverFooter(),
        ],
      ),
    );
  }

  Widget withFixedFooter() {
    return Column(
      children: [
        Expanded(
          child: LayoutBuilder(
            builder: (ctx, cnstr) => CustomScrollView(
              controller: scrollController,
              slivers: [
                if (useSlivers)
                  ...childrenBuilder(ctx, cnstr)
                else
                  SliverList(
                    delegate:
                        SliverChildListDelegate(childrenBuilder(ctx, cnstr)),
                  ),
                const SliverPadding(padding: EdgeInsets.only(top: 32)),
              ],
            ),
          ),
        ),
        if (footer != null) _footer(),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: usePadding
          ? const EdgeInsets.symmetric(horizontal: 16)
          : EdgeInsets.zero,
      child: fixedFooter ? withFixedFooter() : withFloatingFooter(),
    );
  }
}

const mxcPageButtonPadding = EdgeInsets.symmetric(horizontal: 20);

enum LayoutType { scrollable, column2, slivers, column }

class PresenterHooks extends StatelessWidget {
  const PresenterHooks({
    Key? key,
    required Presenter? presenter,
    required this.child,
  })  : error = presenter is ErrorPresenter ? presenter : null,
        loading = presenter is LoadingPresenter ? presenter : null,
        message = presenter is MessagePresenter ? presenter : null,
        context = presenter is ContextPresenter ? presenter : null,
        super(key: key);
  final LoadingPresenter? loading;
  final ErrorPresenter? error;
  final MessagePresenter? message;
  final ContextPresenter? context;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Flat(
      builders: [
        if (loading != null)
          (child) => MxcLoadingHook(loadings: loading!.loadings, child: child),
        if (error != null)
          (child) => MxcErrorHook(errors: error!.errors, child: child),
        if (message != null)
          (child) => MxcSuccessHook(messages: message!.messages, child: child),
        if (this.context != null)
          (child) => MxcContextHook(bridge: this.context!.bridge, child: child),
      ],
      child: child,
    );
  }
}

class KeyboardHandler extends StatelessWidget {
  const KeyboardHandler({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AnimatedSize(
      curve: Curves.easeOutQuad,
      duration: const Duration(milliseconds: 275),
      child: SizedBox(
        height: MediaQuery.of(context).viewInsets.bottom,
      ),
    );
  }
}
