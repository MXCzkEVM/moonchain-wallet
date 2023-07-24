import 'package:datadashwallet/core/core.dart';
import 'package:flutter/material.dart';
import 'package:mxc_logic/mxc_logic.dart';
import 'package:mxc_ui/mxc_ui.dart';
import 'package:web3dart/web3dart.dart';
import 'add_nft_state.dart';

final addNFTPageContainer =
    PresenterContainer<AddNftPresenter, AddNftState>(() => AddNftPresenter());

class AddNftPresenter extends CompletePresenter<AddNftState> {
  AddNftPresenter() : super(AddNftState());

  late final _contractUseCase = ref.read(contractUseCaseProvider);
  late final _nftsUseCase = ref.read(nftsUseCaseProvider);
  late final _accountUseCase = ref.read(accountUseCaseProvider);
  late final TextEditingController addressController = TextEditingController();
  late final TextEditingController tokeIdController = TextEditingController();
  EthereumAddress? walletAddress;

  @override
  void initState() {
    super.initState();

    addressController.addListener(_onValidChange);
    tokeIdController.addListener(_onValidChange);

    listen(_accountUseCase.walletAddress, (value) {
      if (value != null) {
        walletAddress = EthereumAddress.fromHex(value);
      }
    });
  }

  @override
  Future<void> dispose() async {
    addressController.removeListener(_onValidChange);
    tokeIdController.removeListener(_onValidChange);

    super.dispose();
  }

  void _onValidChange() {
    final result =
        addressController.text.isNotEmpty && tokeIdController.text.isNotEmpty;
    notify(() => state.valid = result);
  }

  Future<void> onSave() async {
    final address = addressController.text;
    final tokeId = int.parse(tokeIdController.text);

    loading = true;

    try {
      final owner =
          await _contractUseCase.getOwerOfNft(address: address, tokeId: tokeId);
      final account = _accountUseCase.getWalletAddress();

      if (owner != account) {
        addError(translate('nft_not_match'));
        return;
      }

      final nft = await _contractUseCase.getNft(
        address: address,
        tokeId: tokeId,
      );

      _nftsUseCase.addItem(nft);
      BottomFlowDialog.of(context!).close();
    } catch (error, stackTrace) {
      addError(error, stackTrace);
    } finally {
      loading = false;
    }
  }


}
