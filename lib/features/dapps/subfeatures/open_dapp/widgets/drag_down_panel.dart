import 'package:moonchain_wallet/features/settings/subfeatures/chain_configuration/widgets/chain_logo_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:mxc_logic/mxc_logic.dart';
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
    final url = state.currentUrl?.host ?? '';
    final isSecure = state.isSecure;

    state.animationController = useAnimationController();

    return AnimatedBuilder(
      animation: state.animationController!,
      child: child,
      builder: (context, child) {
        return Column(
          children: [
            state.animationController!.value == 0
                ? Container()
                : Container(
                    height:
                        maxPanelHeight * state.animationController!.value / 1.5,
                    width: double.infinity,
                    padding: const EdgeInsetsDirectional.only(
                        start: Sizes.spaceSmall,
                        end: Sizes.space2XSmall,
                        top: Sizes.spaceSmall,
                        bottom: Sizes.spaceSmall),
                    decoration: BoxDecoration(
                      color: ColorsTheme.of(context).primaryBackground,
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                                color: ColorsTheme.of(context).screenBackground,
                                borderRadius: const BorderRadius.all(
                                  Radius.circular(10),
                                ),
                                border: Border.all(
                                  color:
                                      ColorsTheme.of(context).screenBackground,
                                )),
                            child: Stack(
                              fit: StackFit.passthrough,
                              children: [
                                Positioned.fill(
                                  child: Row(
                                    children: [
                                      Row(
                                        children: [
                                          IconButton(
                                              key: const Key('closedAppButton'),
                                              onPressed: () {
                                                presenter.closedApp();
                                              },
                                              icon: const Icon(
                                                Icons.close_rounded,
                                                size: 24,
                                              )),
                                          InkWell(
                                              onTap: presenter
                                                  .showNetworkDetailsBottomSheet,
                                              child:
                                                  ChainLogoWidget(logo: logo)),
                                        ],
                                      ),
                                      Expanded(
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            const SizedBox(
                                              width: Sizes.space2XSmall,
                                            ),
                                            isSecure
                                                ? Icon(
                                                    Icons.lock_rounded,
                                                    color:
                                                        ColorsTheme.of(context)
                                                            .textPrimary,
                                                    size: 16,
                                                  )
                                                : Icon(
                                                    Icons.warning,
                                                    color:
                                                        ColorsTheme.of(context)
                                                            .mainRed,
                                                    size: 16,
                                                  ),
                                            const SizedBox(
                                              width: Sizes.space2XSmall,
                                            ),
                                            Expanded(
                                              child: InkWell(
                                                onTap: () =>
                                                    presenter.copyUrl(),
                                                child: Text(
                                                  url.replaceAll(
                                                      Config.breakingHyphen,
                                                      Config.nonBreakingHyphen),
                                                  style: FontTheme.of(context)
                                                      .body1
                                                      .primary()
                                                      .copyWith(
                                                          fontWeight:
                                                              FontWeight.w500),
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                              ),
                                            )
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
            Expanded(
              child: child!,
            )
          ],
        );
      },
    );
  }
}
