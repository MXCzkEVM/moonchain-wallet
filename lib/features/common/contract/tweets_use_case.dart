import 'dart:async';

import 'package:moonchain_wallet/core/core.dart';
import 'package:mxc_logic/mxc_logic.dart';

class TweetsUseCase extends ReactiveUseCase {
  TweetsUseCase(
    this._repository,
  ) {
    initTweetsList();
  }

  final Web3Repository _repository;
  late final ValueStream<DefaultTweets?> defaultTweets = reactive(null);

  void initTweetsList() async {
    DefaultTweets data = await getDefaultTweetsLocal();
    update(defaultTweets, data);
    data = await getDefaultTweets();
    update(defaultTweets, data);
  }

  Future<DefaultTweets> getDefaultTweetsLocal() async {
    return await _repository.tweetsRepository.getDefaultTweetsLocal();
  }

  Future<DefaultTweets> getDefaultTweets() async {
    return await _repository.tweetsRepository.getDefaultTweets();
  }
}
