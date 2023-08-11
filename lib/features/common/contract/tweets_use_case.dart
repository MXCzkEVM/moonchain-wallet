import 'dart:async';

import 'package:datadashwallet/core/core.dart';
import 'package:mxc_logic/mxc_logic.dart';

class TweetsUseCase extends ReactiveUseCase {
  TweetsUseCase(
    this._repository,
  );

  final Web3Repository _repository;

  Future<DefaultTweets> getDefaultTweets() async {
    return await _repository.tweetsRepository.getDefaultTweets();
  }
}
