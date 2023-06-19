import 'package:datadashwallet/features/home/apps/apps.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'apps_tab_presenter.dart';
import 'apps_tab_state.dart';

class AppsTab extends HookConsumerWidget {
  const AppsTab({Key? key}) : super(key: key);

  @override
  ProviderBase<AppsTabPresenter> get presenter => appsTabPageContainer.actions;

  @override
  ProviderBase<AppsTabPageState> get state => appsTabPageContainer.state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Expanded(
      child: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child: Flex(
                direction: Axis.horizontal,
                children: [
                  AppCardLayout.vertical(
                    child: DAppCard(
                      name: 'MXC Swap',
                      description: 'diversify_your_portfolio',
                      image: 'assets/svg/apps/mxc_swap.svg',
                      direction: CardAxis.vertical,
                      size: CardSize.large,
                      url: 'https://wannsee-swap.mxc.com',
                      nameColor: const [
                        Color(0xFF68B6F6),
                        Color(0xFF9EF76B),
                      ],
                      backgroundGradient: const LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: <Color>[
                          Color(0xFF1B3544),
                          Color(0xFF355B35),
                        ],
                        tileMode: TileMode.mirror,
                      ),
                    ),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: SizedBox(
                      height: 247,
                      child: Flex(
                        direction: Axis.vertical,
                        children: [
                          AppCardLayout.horizotal(
                            child: DAppCard(
                              name: 'Bridge',
                              description: '& Faucet',
                              image: 'assets/images/apps/bridge.png',
                              direction: CardAxis.horizontal,
                              size: CardSize.medium,
                              contentAlgin: CardContentAlgin.leftBottom,
                              url: 'https://wannsee-bridge.mxc.com',
                              nameColor: const [
                                Color(0xFFB3F864),
                                Color(0xFFE8944B),
                              ],
                              imageHeight: 80,
                              imagePositionbottom: 0,
                              imagePositionRight: 0,
                              // backgroundGradient: const LinearGradient(
                              //   begin: Alignment.topCenter,
                              //   end: Alignment.bottomCenter,
                              //   colors: <Color>[
                              //     Color(0xFFE8944B),
                              //     Color(0xFFA9755E),
                              //   ],
                              //   tileMode: TileMode.mirror,
                              // ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          AppCardLayout.horizotal(
                            child: DAppCard(
                              name: 'Stablecoin',
                              description: 'world_un_depeggable',
                              image: '',
                              direction: CardAxis.horizontal,
                              size: CardSize.medium,
                              url: 'https://wannsee-xsd.mxc.com',
                              nameColor: const [
                                Color(0xFF87C460),
                                Color(0xFFEDDE5C),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child: Flex(
                direction: Axis.horizontal,
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 247,
                      child: Flex(
                        direction: Axis.vertical,
                        children: [
                          AppCardLayout.horizotal(
                            child: DAppCard(
                              name: 'NFT',
                              description: 'digitalize_your_assets',
                              image: '',
                              direction: CardAxis.horizontal,
                              size: CardSize.medium,
                              url: 'https://wannsee-nft.mxc.com',
                              nameColor: const [
                                Color(0xFF87C460),
                                Color(0xFFEDDE5C),
                              ],
                            ),
                          ),
                          const SizedBox(height: 20),
                          AppCardLayout.horizotal(
                            child: DAppCard(
                              name: 'ENS',
                              description: 'own_your_domain',
                              image: '',
                              direction: CardAxis.horizontal,
                              size: CardSize.medium,
                              url: 'https://wannsee-mns.mxc.com',
                              nameColor: const [
                                Color(0xFF44A7EA),
                                Color(0xFF3DA41D),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 20),
                  AppCardLayout.vertical(
                    child: DAppCard(
                      name: 'ISO Launchpad',
                      description: 'accelerating_iot',
                      image: 'assets/images/apps/spacecraft.png',
                      direction: CardAxis.vertical,
                      size: CardSize.large,
                      nameColor: const [
                        Color(0xFF20FFFF),
                        Color(0xFF4A2E60),
                      ],
                      backgroundGradient: const LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: <Color>[
                          Color(0xFF8D023F),
                          Color(0xFF09379E),
                        ],
                        tileMode: TileMode.mirror,
                      ),
                      imageHeight: 120,
                      imagePositionbottom: 0,
                      imagePositionRight: 0,
                      imagePositionLeft: 0,
                    ),
                  ),
                ],
              ),
            ),
            Flex(
              direction: Axis.horizontal,
              children: [
                AppCardLayout.horizotal(
                  child: DAppCard(
                    name: 'Explorer',
                    description: 'visualize_blockchain',
                    image: 'assets/images/apps/screen.png',
                    direction: CardAxis.horizontal,
                    size: CardSize.large,
                    contentAlgin: CardContentAlgin.center,
                    url: 'https://wannsee-explorer.mxc.com',
                    nameColor: const [
                      Color(0xFFF5D459),
                      Color(0xFFE95A2F),
                    ],
                    imageHeight: 60,
                    imagePositionbottom: 0,
                    imagePositionLeft: 30,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
