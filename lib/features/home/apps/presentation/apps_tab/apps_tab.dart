import 'package:datadashwallet/core/core.dart';
import 'package:datadashwallet/features/home/apps/apps.dart';
import 'package:datadashwallet/features/home/apps/entities/dapp.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:mxc_ui/mxc_ui.dart';

import '../widgets/bookmark_icon.dart';
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
      child: PageView(
        // itemBuilder: (context, index) {},
        children: [
          GestureDetector(
            onLongPress: () => Navigator.of(context).push(
              route.featureDialog(
                const EditApps(),
              ),
            ),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  GestureDetector(
                    onTap: () => openAppPage(context,
                        DAppCard(name: 'name', description: 'description')),
                    child: const Image(
                      image: AssetImage('assets/images/apps/bridge.png'),
                    ),
                  ),
                  const SizedBox(height: 32),
                  GestureDetector(
                    onTap: () => openAppPage(context,
                        DAppCard(name: 'name', description: 'description')),
                    child: const Image(
                      image: AssetImage('assets/images/apps/stable_coin.png'),
                    ),
                  ),
                  const SizedBox(height: 32),
                  Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () => openAppPage(
                              context,
                              DAppCard(
                                name: 'MNS',
                                description: 'Own your .MXC domain',
                                url: 'https://wannsee-mns.mxc.com',
                              )),
                          child: const Image(
                            image: AssetImage('assets/images/apps/mns.png'),
                          ),
                        ),
                      ),
                      const SizedBox(width: 32),
                      Expanded(
                        child: GestureDetector(
                          onTap: () {},
                          child: const Image(
                            image: AssetImage('assets/images/apps/nft.png'),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                  // GridView.count(
                  //   crossAxisCount: 4,
                  //   childAspectRatio: 1.0,
                  //   physics: const NeverScrollableScrollPhysics(),
                  //   shrinkWrap: true,
                  //   children: DApp.fixedBookmarks()
                  //       .map((item) => BookmarkIcon(
                  //             title: item.name,
                  //             url: item.url,
                  //           ))
                  //       .toList(),
                  // ),
                ],
              ),
            ),
          ),
          GridView.count(
            crossAxisCount: 4,
            childAspectRatio: 1.0,
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            children: DApp.fixedBookmarks()
                .map((item) => BookmarkIcon(
                      title: item.name,
                      url: item.url,
                    ))
                .toList(),
          ),
        ],
      ),
    );
  }
}
