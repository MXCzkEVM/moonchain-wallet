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
              if (Theme.of(context).brightness == Brightness.dark) {
                RegExp regex = RegExp(r'<.*?>');
                final match = regex.firstMatch(e)!.group(0);
                int index = match!.length - 1;
                String newString =
                    '${match.substring(0, index)} data-theme="dark"  data-width="400"${match.substring(index)}';
                e = e.replaceFirst(regex, newString);
              }
              return Container(
                margin: EdgeInsetsDirectional.only(
                    start: MediaQuery.of(context).size.width > 600 ? 16 : 8),
                width: 320,
                height: 620,
                child: Theme(
                  data: MxcTheme.of(context).toThemeData().copyWith(
                        visualDensity: VisualDensity.adaptivePlatformDensity,
                      ),
                  child: SocialEmbed(
                    socialMediaObj: TwitterEmbedData(
                      embedHtml: e,
                    ),
                  ),
                ),
              );
            },
          )
        ],
      ),
    );
  }
}
