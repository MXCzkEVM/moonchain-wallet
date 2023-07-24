import 'package:datadashwallet/core/core.dart';
import 'package:flutter/material.dart';
import 'package:mxc_logic/mxc_logic.dart';
import 'package:mxc_ui/mxc_ui.dart';
import 'package:web3dart/web3dart.dart';
import 'add_nft_state.dart';

final addNFTPageContainer =
    PresenterContainer<AddNFTPresenter, AddNFTState>(() => AddNFTPresenter());

class AddNFTPresenter extends CompletePresenter<AddNFTState> {
  AddNFTPresenter() : super(AddNFTState());

  late final _nFTsUseCase = ref.read(nFTsUseCaseProvider);
  late final _contractUseCase = ref.read(contractUseCaseProvider);
  late final _accountUserCase = ref.read(accountUseCaseProvider);
  late final TextEditingController addressController = TextEditingController();
  late final TextEditingController idController = TextEditingController();
  EthereumAddress? walletAddress;

  @override
  void initState() {
    super.initState();

    addressController.addListener(_onValidChange);
    idController.addListener(_onValidChange);

    listen(_accountUserCase.walletAddress, (value) {
      if (value != null) {
        walletAddress = EthereumAddress.fromHex(value);
      }
    });
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
      final tokenMetaData = await getTokenInfo();

      if (tokenMetaData != null) {
        _nFTsUseCase.addItem(NFT(
            address: address,
            tokenId: id,
            image: tokenMetaData.image!,
            name: tokenMetaData.name!));
        BottomFlowDialog.of(context!).close();
      }
    } catch (error, stackTrace) {
      addError(error, stackTrace);
    } finally {
      loading = false;
    }
  }

  Future<WannseeTokenMetaData?> getTokenInfo() async {
    final collectionAddress = EthereumAddress.fromHex(addressController.text);
    final tokenId = int.parse(idController.text);

    if (walletAddress != null) {
      final isCurrentWalletOwner = await _contractUseCase.checkTokenOwnership(
          collectionAddress, tokenId, walletAddress!);

      if (isCurrentWalletOwner != null && isCurrentWalletOwner == true) {
        // we have ownership response & It's owned by current wallet

        return await _contractUseCase.getTokenInfo(
            collectionAddress, tokenId, walletAddress!);
      } else {
        ScaffoldMessenger.of(context!).showSnackBar(const SnackBar(
          content: Text('NFT does not belong to this user.'),
        ));
        return null;
      }
    } else {
      return null;
    }
  }
}
