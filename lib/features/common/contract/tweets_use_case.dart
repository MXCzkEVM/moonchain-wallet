import 'dart:async';

import 'package:datadashwallet/core/core.dart';
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
    final data = await getDefaultTweetsLocal();
    update(defaultTweets, data);
  }

  Future<DefaultTweets> getDefaultTweetsLocal() async {
    return await _repository.tweetsRepository.getDefaultTweetsLocal();
  }

  Future<DefaultTweets> getDefaultTweets() async {
    return await _repository.tweetsRepository.getDefaultTweets();
  }
}
