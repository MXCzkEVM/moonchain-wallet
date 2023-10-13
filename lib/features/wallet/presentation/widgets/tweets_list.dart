import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../wallet_page_presenter.dart';
import 'tweet_widget.dart';

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
              return Tweet(
                tweetId: e,
                isDark: (Theme.of(context).brightness == Brightness.dark),
                height: state.maxTweetViewHeight,
                checkMaxHeight: presenter.checkMaxTweetHeight,
              );
            },
          )
        ],
      ),
    );
  }
}
