import 'package:datadashwallet/core/core.dart';
import 'package:datadashwallet/features/portfolio/presentation/nfts/entities/nft.dart';
import 'package:flutter/material.dart';
import 'package:mxc_ui/mxc_ui.dart';

import 'add_nft_state.dart';

final addNFTPageContainer =
    PresenterContainer<AddNFTPresenter, AddNFTState>(() => AddNFTPresenter());

class AddNFTPresenter extends CompletePresenter<AddNFTState> {
  AddNFTPresenter() : super(AddNFTState());

  late final _nFTsUseCase = ref.read(nFTsUseCaseProvider);
  late final TextEditingController addressController = TextEditingController();
  late final TextEditingController idController = TextEditingController();

  @override
  void initState() {
    super.initState();

    addressController.addListener(_onValidChange);
    idController.addListener(_onValidChange);
  }

  @override
  Future<void> dispose() async {
    addressController.removeListener(_onValidChange);
    idController.removeListener(_onValidChange);

    super.dispose();
  }

  void _onValidChange() {
    final result =
        addressController.text.isNotEmpty && idController.text.isNotEmpty;
    notify(() => state.valid = result);
  }

  Future<void> onSave() async {
    final address = addressController.text;
    final id = idController.text;

    loading = true;

    try {
      _nFTsUseCase.addItem(NFT(
        address: address,
        collectionID: id,
      ));
      BottomFlowDialog.of(context!).close();
    } catch (error, stackTrace) {
      addError(error, stackTrace);
    } finally {
      loading = false;
    }
  }
}
