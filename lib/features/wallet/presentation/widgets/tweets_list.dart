import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:mxc_ui/mxc_ui.dart';
import 'package:social_embed_webview/platforms/twitter.dart';
import 'package:social_embed_webview/social_embed_webview.dart';

import '../wallet_page_presenter.dart';

class TweetsList extends HookConsumerWidget {
  const TweetsList({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final presenter = ref.read(walletContainer.actions);
    final state = ref.watch(walletContainer.state);

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          ...state.embeddedTweets.map(
            (e) {
              return Container(
                margin: const EdgeInsetsDirectional.only(start: 10),
                width: 320,
                height: 620,
                child: Theme(
                  data: MxcTheme.of(context).toThemeData().copyWith(
                        visualDensity: VisualDensity.adaptivePlatformDensity,
                      ),
                  child: SocialEmbed(
                      socialMediaObj: TwitterEmbedData(embedHtml: e.html)),
                ),
              );
            },
          )
        ],
      ),
    );
  }
}
