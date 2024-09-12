import 'package:moonchain_wallet/core/core.dart';
import 'package:flutter/material.dart';
import 'package:mxc_ui/mxc_ui.dart';
import 'add_nft_state.dart';

final addNftPageContainer =
    PresenterContainer<AddNftPresenter, AddNftState>(() => AddNftPresenter());

class AddNftPresenter extends CompletePresenter<AddNftState> {
  AddNftPresenter() : super(AddNftState());

  late final _nftContractUseCase = ref.read(nftContractUseCaseProvider);
  late final _nftsUseCase = ref.read(nftsUseCaseProvider);
  late final _accountUseCase = ref.read(accountUseCaseProvider);
  late final TextEditingController addressController = TextEditingController();
  late final TextEditingController tokeIdController = TextEditingController();

  @override
  void initState() {
    super.initState();

    listen(
      _accountUseCase.account,
      (value) {
        notify(() => state.account = value);
      },
    );

    addressController.addListener(_onValidChange);
    tokeIdController.addListener(_onValidChange);
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
          await _nftContractUseCase.getOwerOf(address: address, tokeId: tokeId);
      final account = state.account!.address;

      if (owner != account) {
        addError(translate('nft_not_match'));
        return;
      }

      final nft = await _nftContractUseCase.getNft(
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
