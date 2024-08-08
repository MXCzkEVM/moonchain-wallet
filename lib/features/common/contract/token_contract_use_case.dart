import 'dart:async';
import 'package:datadashwallet/core/core.dart';
import 'package:datadashwallet/features/common/common.dart';
import 'package:datadashwallet/features/settings/subfeatures/chain_configuration/domain/chain_configuration_use_case.dart';
import 'package:flutter/services.dart';
import 'package:mxc_logic/mxc_logic.dart';
import 'package:web3dart/web3dart.dart';

extension Unique<E, T> on List<E> {
  void unique([T Function(E element)? id, bool inPlace = true]) {
    final ids = <dynamic>{};
    var list = inPlace ? this : List<E>.from(this);
    list.retainWhere((x) => ids.add(id != null ? id(x) : x as T));
  }
}

class TokenContractUseCase extends ReactiveUseCase {
  TokenContractUseCase(
    this._repository,
    this._chainConfigurationUseCase,
    this._accountUseCase,
    this._functionUseCase,
  ) {
    initListeners();
  }

  void initListeners() {
    _accountUseCase.account.listen((v) {
      account = v;
    });

    _chainConfigurationUseCase.selectedNetwork.listen((v) {
      if (v != null) {
        _functionUseCase.mxcChainsAndEthereumFuncWrapper(
            () => loadLocalTokenList(v.chainId));
      }
    });
  }

  void loadLocalTokenList(int chainId) async {
    final stringData = await MXCFileHelpers.getTokenList(chainId);
    DefaultTokens data =
        DefaultTokens.fromJson(stringData).changeAssetsRemoteToLocal();
    getDefaultTokens(account!.address, defaultTokens: data);
  }

  final Web3Repository _repository;
  final ChainConfigurationUseCase _chainConfigurationUseCase;
  final AccountUseCase _accountUseCase;
  final FunctionUseCase _functionUseCase;

  Account? account;

  late final ValueStream<bool> online = reactive(false);

  late final ValueStream<List<Token>> tokensList = reactive([]);

  List<Token> customTokenList = [];

  late final ValueStream<String?> name = reactive();

  late final ValueStream<double> totalBalanceInXsd = reactive(0.0);

  Future<String> getWalletNativeTokenBalance(String address) async {
    final balance = await _repository.tokenContract.getEthBalance(address);
    return MXCFormatter.convertWeiToEth(
        balance.getInWei.toString(), Config.ethDecimals);
  }

  Future<EtherAmount> getEthBalance(String from) async {
    return await _repository.tokenContract.getEthBalance(from);
  }

  Future<WannseeTransactionsModel?> getTransactionsByAddress(
      String address) async {
    return _repository.tokenContract.getTransactionsByAddress(address);
  }

  Future<WannseeTransactionModel?> getTransactionByHash(String hash) async {
    return _repository.tokenContract.getTransactionByHash(hash);
  }

  Future<WannseeTokenTransfersModel?> getTokenTransfersByAddress(
      String address) async {
    return _repository.tokenContract
        .getTokenTransfersByAddress(address, TokenType.erc_20);
  }

  Future<List<Token>> getDefaultTokens(String walletAddress,
      {DefaultTokens? defaultTokens}) async {
    final result =
        defaultTokens ?? await _repository.tokenContract.getDefaultTokens();
    tokensList.value.clear();
    tokensList.value.addAll(customTokenList);

    final cNetwork = _repository.tokenContract.getCurrentNetwork();

    final chainNativeToken = Token(
        logoUri: result?.logoUri ?? cNetwork.logo,
        symbol: cNetwork.symbol,
        name: '${cNetwork.symbol} Token',
        decimals: Config.ethDecimals);

    // Avoiding multiple native token from being added
    if (tokensList.value.indexWhere((element) => element.address == null) ==
        -1) {
      tokensList.value.add(chainNativeToken);
    }

    if (result != null) {
      if (result.tokens != null) {
        tokensList.value.addAll(result.tokens!);
        tokensList.value.unique((token) => token.symbol);
      }
    }

    update(tokensList, tokensList.value);
    result?.tokens?.add(chainNativeToken);
    return result?.tokens ?? tokensList.value;
  }

  Future<Token?> getToken(String address) async =>
      await _repository.tokenContract.getToken(address);

  Future<String> getName(String address) async {
    final result = await _repository.tokenContract.getName(address);
    update(name, result);
    return result;
  }

  Future<String> getAddress(String? name) async =>
      await _repository.tokenContract.getAddress(name);

  Future<void> checkConnectionToNetwork() async {
    final result = await _repository.tokenContract.checkConnectionToNetwork();

    update(online, result);
  }

  Future<void> getTokensBalance(
    List<Token>? tokenList,
    String walletAddress,
    bool shouldGetPrice,
  ) async {
    late List<Token> result;
    if (tokenList != null) {
      // Check if tokenList and enwList values are the same
      await _repository.tokenContract
          .getTokensBalance(tokenList, walletAddress);
      updateTokensList(tokenList);
    } else {
      result = await _repository.tokenContract
          .getTokensBalance(tokensList.value, walletAddress);
      update(tokensList, result);
    }

    if (shouldGetPrice) {
      getTokensPrice(tokenList);
    } else {
      resetTokenPrice();
    }
  }

  void updateTokensList(
    List<Token> tokenList,
  ) {
    for (int i = 0; i < tokensList.value.length; i++) {
      final index = tokenList.indexWhere((element) {
        final result = element.address == tokensList.value[i].address;
        return result;
      });
      if (index != -1) {
        final newListItem = tokenList[index];
        if (newListItem.address == tokensList.value[i].address) {
          tokensList.value[i] = newListItem;
        }
      }
    }
    update(tokensList, tokensList.value);
  }

  void resetTokenPrice() {
    final List<Token> newList = <Token>[];
    for (Token token in tokensList.value) {
      newList.add(token.copyWith(balancePrice: 0.0));
    }
    update(tokensList, newList);
    calculateTotalBalanceInXsd();
  }

  Future<void> getTokensPrice(
    List<Token>? tokenList,
  ) async {
    if (tokenList != null) {
      await _repository.pricingRepository.getTokensPrice(tokenList);
      updateTokensList(tokenList);
    } else {
      final result =
          await _repository.pricingRepository.getTokensPrice(tokensList.value);
      update(tokensList, result);
    }
    calculateTotalBalanceInXsd();
  }

  void addCustomTokens(
      List<Token> customTokens, String walletAddress, bool shouldGetPrice) {
    tokensList.value.addAll(customTokens);
    tokensList.value.unique((token) => token.address);
    customTokenList = customTokens;
    update(tokensList, tokensList.value);

    if (customTokenList.isNotEmpty) {
      getTokensBalance(
        customTokens,
        walletAddress,
        shouldGetPrice,
      );
    }
  }

  Future<EtherAmount> getGasPrice() async =>
      await _repository.tokenContract.getGasPrice();

  Future<TransactionGasEstimation> estimateGasFeeForCoinTransfer({
    required String from,
    required String to,
    EtherAmount? gasPrice,
    required EtherAmount value,
  }) async =>
      await _repository.tokenContract.estimateGasFeeForCoinTransfer(
          from: from, to: to, gasPrice: gasPrice, value: value);

  Future<TransactionGasEstimation> estimateGasFeeForContractCall({
    required String from,
    required String to,
    required Uint8List data,
    EtherAmount? gasPrice,
    BigInt? amountOfGas,
    EtherAmount? value,
  }) async =>
      await _repository.tokenContract.estimateGasFeeForContractCall(
          from: from, to: to, data: data, value: value);

  Future<TransactionModel> sendTransaction({
    required String privateKey,
    required String to,
    String? from,
    required EtherAmount amount,
    TransactionGasEstimation? estimatedGasFee,
    Uint8List? data,
    String? tokenAddress,
    Token? token,
    int? nonce,
  }) async =>
      await _repository.tokenContract.sendTransaction(
          privateKey: privateKey,
          to: to,
          from: from,
          amount: amount,
          estimatedGasFee: estimatedGasFee,
          data: data,
          tokenAddress: tokenAddress,
          token: token,
          nonce: nonce);

  Uint8List getTokenTransferData(
      String tokenHash, EthereumAddress toAddress, BigInt amount) {
    return _repository.tokenContract
        .getTokenTransferData(tokenHash, toAddress, amount);
  }

  String signPersonalMessage({required String privateKey, required String message}) {
    return _repository.tokenContract
        .signPersonalMessage(privateKey: privateKey, message: message);
  }


  String signMessage({required String privateKey, required String message}) {
    return _repository.tokenContract
        .signMessage(privateKey: privateKey, message: message);
  }

  String signTypedMessage({required String privateKey, required String data}) {
    return _repository.tokenContract
        .signTypedMessage(privateKey: privateKey, data: data);
  }

  Future<int> getChainId(String rpcUrl) async {
    return await _repository.tokenContract.getChainId(rpcUrl);
  }

  void calculateTotalBalanceInXsd() {
    double totalPrice = 0.0;
    for (int i = 0; i < tokensList.value.length; i++) {
      final token = tokensList.value[i];
      totalPrice += token.balancePrice!;
    }
    update(totalBalanceInXsd, totalPrice);
  }

  StreamSubscription<TransactionReceipt?> spyOnTransaction(String hash) {
    return _repository.tokenContract.spyTransaction(hash);
  }

  Future<int> getEpochDetails(int chainId) async {
    return await _repository.tokenContract.getEpochDetails(chainId);
  }

  Future<int> getAddressNonce(EthereumAddress address,
      {BlockNum? atBlock}) async {
    return await _repository.tokenContract
        .getAddressNonce(address, atBlock: atBlock);
  }
}
