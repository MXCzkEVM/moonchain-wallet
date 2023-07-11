import 'package:datadashwallet/core/core.dart';
import 'package:datadashwallet/features/common/common.dart';
import 'package:flutter/material.dart';
import 'package:mxc_ui/mxc_ui.dart';

import 'choose_crypto_state.dart';

final addTokenPageContainer =
    PresenterContainer<ChooseCryptoPresenter, ChooseCryptoState>(
        () => ChooseCryptoPresenter());

class ChooseCryptoPresenter extends CompletePresenter<ChooseCryptoState> {
  ChooseCryptoPresenter() : super(ChooseCryptoState());

  late final ContractUseCase _contractTabUseCase =
      ref.read(contractUseCaseProvider);
  late final TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  @override
  Future<void> dispose() async {
    super.dispose();
  }
}
