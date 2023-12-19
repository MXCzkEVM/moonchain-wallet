import 'package:datadashwallet/features/settings/subfeatures/chain_configuration/widgets/chain_logo_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:mxc_ui/mxc_ui.dart';

import '../open_dapp_presenter.dart';

class DragDownPanel extends HookConsumerWidget {
  const DragDownPanel({
    super.key,
    required this.child,
  });

  final Widget child;

  final double maxPanelHeight = 100.0;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final presenter = ref.read(openDAppPageContainer.actions);
    final state = ref.watch(openDAppPageContainer.state);

    final logo = state.network!.logo;
    final name = state.network!.label ?? state.network!.web3RpcHttpUrl;
    final url = state.currentUrl;
    final isSecure = state.isSecure;

    state.animationController = useAnimationController();

    return AnimatedBuilder(
      animation: state.animationController!,
      child: child,
      builder: (context, child) {
        return Stack(
          clipBehavior: Clip.hardEdge,
          children: [
            Container(
              height: maxPanelHeight * state.animationController!.value / 1.5,
              width: double.infinity,
              padding: const EdgeInsets.symmetric(
                  horizontal: Sizes.spaceSmall, vertical: Sizes.spaceSmall),
              color: ColorsTheme.of(context).primaryBackground,
              child: Row(
                children: [
                  SizedBox(
                    width: 64,
                    height: double.infinity,
                    child: Column(
                      children: [
                        ChainLogoWidget(logo: logo),
                        Expanded(
                          child: Text(
                            name,
                            style: FontTheme.of(context).caption2.primary(),
                            // overflow: TextOverflow.ellipsis,
                            softWrap: false,
                          ),
                        )
                      ],
                    ),
                  ),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: Sizes.space2XSmall,
                          vertical: Sizes.space3XSmall),
                      decoration: BoxDecoration(
                          color: ColorsTheme.of(context).screenBackground,
                          borderRadius: const BorderRadius.all(
                            Radius.circular(10),
                          ),
                          border: Border.all(
                            color: ColorsTheme.of(context).screenBackground,
                          )),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                isSecure
                                    ? Icon(
                                        Icons.lock_rounded,
                                        color:
                                            ColorsTheme.of(context).textPrimary,
                                        size: 16,
                                      )
                                    : Icon(
                                        Icons.lock_open,
                                        color: ColorsTheme.of(context).mainRed,
                                        size: 16,
                                      ),
                                const SizedBox(
                                  width: Sizes.spaceXSmall,
                                ),
                                Text(
                                  url?.host ?? '',
                                  style: FontTheme.of(context)
                                      .body1
                                      .primary()
                                      .copyWith(fontWeight: FontWeight.w800),
                                  overflow: TextOverflow.ellipsis,
                                )
                              ],
                            ),
                          ),
                          IconButton(
                              key: const Key('closedAppButton'),
                              onPressed: () {
                                presenter.closedApp();
                              },
                              icon: const Icon(
                                Icons.close_rounded,
                                size: 24,
                              ))
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Transform.translate(
              offset: Offset(
                  0.0, maxPanelHeight * state.animationController!.value / 1.5),
              child: child,
            ),
          ],
        );
      },
    );
  }
}
