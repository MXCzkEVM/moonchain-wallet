import 'package:clipboard/clipboard.dart';
import 'package:datadashwallet/core/core.dart';
import 'package:flutter/material.dart';
import 'chain_configuration_state.dart';

final chainConfigurationContainer =
    PresenterContainer<ChainConfigurationPresenter, ChainConfigurationState>(
        () => ChainConfigurationPresenter());

class ChainConfigurationPresenter
    extends CompletePresenter<ChainConfigurationState> {
  ChainConfigurationPresenter() : super(ChainConfigurationState());

  late final _accountUserCase = ref.read(accountUseCaseProvider);
  late final _contractUseCase = ref.read(contractUseCaseProvider);

  final TextEditingController gasLimitController = TextEditingController();

  @override
  void initState() {
    super.initState();

    // listen(_accountUserCase.walletAddress, (value) {
    //   if (value != null) {
    //     notify(() => state.walletAddress = value);
    //   }
    // });

    // listen(_contractUseCase.name, (value) {
    //   if (value != null) {
    //     // notify(() => state.name = value);
    //   }
    // });

    _accountUserCase.refreshWallet();
  }

  void copyToClipboard(String text) async {
    FlutterClipboard.copy(text).then((value) => null);
  }
}
