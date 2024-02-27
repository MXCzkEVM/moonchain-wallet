// Generated code, do not modify. Run `build_runner build` to re-generate!
// @dart=2.12
// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:web3dart/web3dart.dart' as _i1;
import 'dart:typed_data' as _i2;

final _contractAbi = _i1.ContractAbi.fromJson(
  '[{"inputs":[],"name":"AlreadyClaim","type":"error"},{"inputs":[{"internalType":"uint256","name":"_size","type":"uint256"},{"internalType":"uint256","name":"_start","type":"uint256"},{"internalType":"uint256","name":"_end","type":"uint256"}],"name":"InvalidCodeAtRange","type":"error"},{"inputs":[],"name":"InvalidEpochNumber","type":"error"},{"inputs":[],"name":"InvalidLength","type":"error"},{"inputs":[],"name":"InvalidOrder","type":"error"},{"inputs":[],"name":"InvalidProof","type":"error"},{"inputs":[],"name":"InvalidSignature","type":"error"},{"inputs":[],"name":"InvalidTokenOwnership","type":"error"},{"inputs":[],"name":"RewardExpired","type":"error"},{"inputs":[],"name":"SensorBalanceRequired","type":"error"},{"inputs":[],"name":"TokenExceeds","type":"error"},{"inputs":[],"name":"TokenExist","type":"error"},{"inputs":[],"name":"TokenNotFound","type":"error"},{"inputs":[],"name":"TransferFailed","type":"error"},{"inputs":[],"name":"WriteError","type":"error"},{"anonymous":false,"inputs":[{"indexed":true,"internalType":"address","name":"miner","type":"address"},{"indexed":false,"internalType":"uint256[]","name":"epochIds","type":"uint256[]"},{"components":[{"internalType":"address[]","name":"token","type":"address[]"},{"internalType":"uint256[]","name":"amount","type":"uint256[]"}],"indexed":false,"internalType":"struct MEP2542.RewardInfo[]","name":"rewardInfos","type":"tuple[]"}],"name":"BulkClaimedReward","type":"event"},{"anonymous":false,"inputs":[{"indexed":true,"internalType":"address","name":"miner","type":"address"},{"indexed":true,"internalType":"uint256","name":"epochNumber","type":"uint256"},{"components":[{"internalType":"address[]","name":"token","type":"address[]"},{"internalType":"uint256[]","name":"amount","type":"uint256[]"}],"indexed":false,"internalType":"struct MEP2542.RewardInfo","name":"rewardInfo","type":"tuple"}],"name":"ClaimedReward","type":"event"},{"anonymous":false,"inputs":[{"indexed":true,"internalType":"address","name":"controller","type":"address"},{"indexed":false,"internalType":"bool","name":"enabled","type":"bool"}],"name":"ControllerChanged","type":"event"},{"anonymous":false,"inputs":[{"indexed":false,"internalType":"uint8","name":"version","type":"uint8"}],"name":"Initialized","type":"event"},{"anonymous":false,"inputs":[{"indexed":true,"internalType":"address","name":"previousOwner","type":"address"},{"indexed":true,"internalType":"address","name":"newOwner","type":"address"}],"name":"OwnershipTransferred","type":"event"},{"anonymous":false,"inputs":[{"indexed":true,"internalType":"uint256","name":"epochNumber","type":"uint256"},{"indexed":true,"internalType":"bytes32","name":"rewardMerkleRoot","type":"bytes32"},{"indexed":false,"internalType":"address","name":"onlineStatusPointer","type":"address"}],"name":"ReleaseEpoch","type":"event"},{"inputs":[],"name":"CLAIM_PERMIT_TYPEHASH","outputs":[{"internalType":"bytes32","name":"","type":"bytes32"}],"stateMutability":"pure","type":"function"},{"inputs":[],"name":"DOMAIN_SEPARATOR","outputs":[{"internalType":"bytes32","name":"","type":"bytes32"}],"stateMutability":"view","type":"function"},{"inputs":[],"name":"ERC6551AccountImplAddr","outputs":[{"internalType":"address","name":"","type":"address"}],"stateMutability":"view","type":"function"},{"inputs":[],"name":"ERC6551Registry","outputs":[{"internalType":"contract IERC6551Registry","name":"","type":"address"}],"stateMutability":"view","type":"function"},{"inputs":[],"name":"MEP1004Token_","outputs":[{"internalType":"contract MEP1004Token","name":"","type":"address"}],"stateMutability":"view","type":"function"},{"inputs":[],"name":"PERMIT_TYPEHASH","outputs":[{"internalType":"bytes32","name":"","type":"bytes32"}],"stateMutability":"pure","type":"function"},{"inputs":[],"name":"__Controllable_init","outputs":[],"stateMutability":"nonpayable","type":"function"},{"inputs":[{"internalType":"address","name":"token","type":"address"},{"internalType":"address","name":"permitOwner","type":"address"},{"internalType":"uint256","name":"amountPerEpoch","type":"uint256"}],"name":"addRewardToken","outputs":[],"stateMutability":"nonpayable","type":"function"},{"inputs":[{"internalType":"uint256","name":"MEP1004TokenId","type":"uint256"},{"internalType":"address","name":"to","type":"address"},{"components":[{"internalType":"bytes32[]","name":"proofs","type":"bytes32[]"}],"internalType":"struct MEP2542.ProofArray[]","name":"proofs","type":"tuple[]"},{"internalType":"uint256[]","name":"epochIds","type":"uint256[]"},{"components":[{"internalType":"address[]","name":"token","type":"address[]"},{"internalType":"uint256[]","name":"amount","type":"uint256[]"}],"internalType":"struct MEP2542.RewardInfo[]","name":"rewards","type":"tuple[]"}],"name":"claimRewards","outputs":[],"stateMutability":"nonpayable","type":"function"},{"inputs":[{"internalType":"uint256","name":"MEP1004TokenId","type":"uint256"},{"internalType":"address","name":"to","type":"address"},{"internalType":"uint256[]","name":"epochIds","type":"uint256[]"},{"components":[{"internalType":"address[]","name":"token","type":"address[]"},{"internalType":"uint256[]","name":"amount","type":"uint256[]"}],"internalType":"struct MEP2542.RewardInfo[]","name":"rewards","type":"tuple[]"},{"internalType":"bytes","name":"signature","type":"bytes"}],"name":"claimRewardsVerified","outputs":[],"stateMutability":"nonpayable","type":"function"},{"inputs":[],"name":"claimVerifier","outputs":[{"internalType":"address","name":"","type":"address"}],"stateMutability":"view","type":"function"},{"inputs":[{"internalType":"address","name":"","type":"address"}],"name":"controllers","outputs":[{"internalType":"bool","name":"","type":"bool"}],"stateMutability":"view","type":"function"},{"inputs":[],"name":"currentEpoch","outputs":[{"internalType":"uint256","name":"","type":"uint256"}],"stateMutability":"view","type":"function"},{"inputs":[],"name":"epochExpiredTime","outputs":[{"internalType":"uint256","name":"","type":"uint256"}],"stateMutability":"view","type":"function"},{"inputs":[{"internalType":"uint256","name":"","type":"uint256"}],"name":"epochReleaseTime","outputs":[{"internalType":"uint256","name":"","type":"uint256"}],"stateMutability":"view","type":"function"},{"inputs":[{"internalType":"uint256","name":"MEP1004TokenId","type":"uint256"},{"internalType":"uint256[]","name":"epochNumbers","type":"uint256[]"}],"name":"getMinerClaimedEpochs","outputs":[{"internalType":"bool[]","name":"","type":"bool[]"}],"stateMutability":"view","type":"function"},{"inputs":[{"internalType":"uint256","name":"epochNumber","type":"uint256"},{"internalType":"uint256","name":"MEP1004TokenId","type":"uint256"}],"name":"getMinerOnlineStatus","outputs":[{"internalType":"bool","name":"","type":"bool"}],"stateMutability":"view","type":"function"},{"inputs":[{"internalType":"uint256","name":"MEP1004TokenId","type":"uint256"},{"internalType":"uint256[]","name":"epochIds","type":"uint256[]"},{"components":[{"internalType":"address[]","name":"token","type":"address[]"},{"internalType":"uint256[]","name":"amount","type":"uint256[]"}],"internalType":"struct MEP2542.RewardInfo[]","name":"rewards","type":"tuple[]"}],"name":"getRewardHash","outputs":[{"internalType":"bytes32","name":"","type":"bytes32"}],"stateMutability":"view","type":"function"},{"inputs":[],"name":"getRewardTokenInfo","outputs":[{"components":[{"internalType":"address","name":"token","type":"address"},{"internalType":"address","name":"permitOwner","type":"address"},{"internalType":"uint256","name":"amountPerEpoch","type":"uint256"}],"internalType":"struct MEP2542.RewardTokenInfo[]","name":"","type":"tuple[]"}],"stateMutability":"view","type":"function"},{"inputs":[{"internalType":"address","name":"account","type":"address"}],"name":"getUserSelectedToken","outputs":[{"internalType":"address[]","name":"","type":"address[]"}],"stateMutability":"view","type":"function"},{"inputs":[{"internalType":"address","name":"_treasury","type":"address"},{"internalType":"address","name":"_ERC6551Registry","type":"address"},{"internalType":"address","name":"_ERC6551AccountImplAddr","type":"address"},{"internalType":"address","name":"_MEP1004Addr","type":"address"},{"internalType":"address","name":"_sensorToken","type":"address"},{"internalType":"uint256","name":"_epochExpiredTime","type":"uint256"},{"internalType":"uint256","name":"_maxSelectToken","type":"uint256"}],"name":"initialize","outputs":[],"stateMutability":"nonpayable","type":"function"},{"inputs":[],"name":"maxSelectToken","outputs":[{"internalType":"uint256","name":"","type":"uint256"}],"stateMutability":"view","type":"function"},{"inputs":[],"name":"owner","outputs":[{"internalType":"address","name":"","type":"address"}],"stateMutability":"view","type":"function"},{"inputs":[{"internalType":"uint256","name":"epochNumber","type":"uint256"},{"internalType":"bytes32","name":"rewardMerkleRoot","type":"bytes32"},{"internalType":"bytes","name":"statusBitMap","type":"bytes"}],"name":"releaseEpoch","outputs":[],"stateMutability":"nonpayable","type":"function"},{"inputs":[{"internalType":"address","name":"token","type":"address"}],"name":"removeRewardToken","outputs":[],"stateMutability":"nonpayable","type":"function"},{"inputs":[],"name":"renounceOwnership","outputs":[],"stateMutability":"nonpayable","type":"function"},{"inputs":[{"internalType":"uint256","name":"","type":"uint256"}],"name":"rewardMerkleRoots","outputs":[{"internalType":"bytes32","name":"","type":"bytes32"}],"stateMutability":"view","type":"function"},{"inputs":[{"internalType":"uint256","name":"","type":"uint256"}],"name":"rewardTokens","outputs":[{"internalType":"address","name":"token","type":"address"},{"internalType":"address","name":"permitOwner","type":"address"},{"internalType":"uint256","name":"amountPerEpoch","type":"uint256"}],"stateMutability":"view","type":"function"},{"inputs":[{"internalType":"address[]","name":"tokens","type":"address[]"},{"internalType":"bytes[]","name":"signatures","type":"bytes[]"}],"name":"selectToken","outputs":[],"stateMutability":"nonpayable","type":"function"},{"inputs":[],"name":"sensorToken","outputs":[{"internalType":"contract SensorToken","name":"","type":"address"}],"stateMutability":"view","type":"function"},{"inputs":[{"internalType":"address","name":"_verifier","type":"address"}],"name":"setClaimVerifier","outputs":[],"stateMutability":"nonpayable","type":"function"},{"inputs":[{"internalType":"address","name":"controller","type":"address"},{"internalType":"bool","name":"enabled","type":"bool"}],"name":"setController","outputs":[],"stateMutability":"nonpayable","type":"function"},{"inputs":[{"internalType":"uint256","name":"_epochExpiredTime","type":"uint256"}],"name":"setEpochExpiredTime","outputs":[],"stateMutability":"nonpayable","type":"function"},{"inputs":[{"internalType":"uint256","name":"_maxSelectToken","type":"uint256"}],"name":"setMaxSelectToken","outputs":[],"stateMutability":"nonpayable","type":"function"},{"inputs":[{"internalType":"address","name":"token","type":"address"},{"internalType":"address","name":"permitOwner","type":"address"},{"internalType":"uint256","name":"amountPerEpoch","type":"uint256"}],"name":"setRewardToken","outputs":[],"stateMutability":"nonpayable","type":"function"},{"inputs":[{"internalType":"address","name":"newOwner","type":"address"}],"name":"transferOwnership","outputs":[],"stateMutability":"nonpayable","type":"function"},{"inputs":[],"name":"treasury","outputs":[{"internalType":"address","name":"","type":"address"}],"stateMutability":"view","type":"function"},{"inputs":[{"internalType":"uint256","name":"MEP1004TokenId","type":"uint256"},{"components":[{"internalType":"bytes32[]","name":"proofs","type":"bytes32[]"}],"internalType":"struct MEP2542.ProofArray[]","name":"proofs","type":"tuple[]"},{"internalType":"uint256[]","name":"epochIds","type":"uint256[]"},{"components":[{"internalType":"address[]","name":"token","type":"address[]"},{"internalType":"uint256[]","name":"amount","type":"uint256[]"}],"internalType":"struct MEP2542.RewardInfo[]","name":"rewards","type":"tuple[]"}],"name":"verifyMerkleProof","outputs":[{"internalType":"bool","name":"","type":"bool"}],"stateMutability":"view","type":"function"}]',
  'MEP2542',
);

class MEP2542 extends _i1.GeneratedContract {
  MEP2542({
    required _i1.EthereumAddress address,
    required _i1.Web3Client client,
    int? chainId,
  }) : super(
          _i1.DeployedContract(
            _contractAbi,
            address,
          ),
          client,
          chainId,
        );

  /// The optional [atBlock] parameter can be used to view historical data. When
  /// set, the function will be evaluated in the specified block. By default, the
  /// latest on-chain block will be used.
  Future<_i2.Uint8List> CLAIM_PERMIT_TYPEHASH({_i1.BlockNum? atBlock}) async {
    final function = self.abi.functions[0];
    assert(checkSignature(function, 'ef612d06'));
    final params = [];
    final response = await read(
      function,
      params,
      atBlock,
    );
    return (response[0] as _i2.Uint8List);
  }

  /// The optional [atBlock] parameter can be used to view historical data. When
  /// set, the function will be evaluated in the specified block. By default, the
  /// latest on-chain block will be used.
  Future<_i2.Uint8List> DOMAIN_SEPARATOR({_i1.BlockNum? atBlock}) async {
    final function = self.abi.functions[1];
    assert(checkSignature(function, '3644e515'));
    final params = [];
    final response = await read(
      function,
      params,
      atBlock,
    );
    return (response[0] as _i2.Uint8List);
  }

  /// The optional [atBlock] parameter can be used to view historical data. When
  /// set, the function will be evaluated in the specified block. By default, the
  /// latest on-chain block will be used.
  Future<_i1.EthereumAddress> ERC6551AccountImplAddr(
      {_i1.BlockNum? atBlock}) async {
    final function = self.abi.functions[2];
    assert(checkSignature(function, '4b90136c'));
    final params = [];
    final response = await read(
      function,
      params,
      atBlock,
    );
    return (response[0] as _i1.EthereumAddress);
  }

  /// The optional [atBlock] parameter can be used to view historical data. When
  /// set, the function will be evaluated in the specified block. By default, the
  /// latest on-chain block will be used.
  Future<_i1.EthereumAddress> ERC6551Registry({_i1.BlockNum? atBlock}) async {
    final function = self.abi.functions[3];
    assert(checkSignature(function, 'adbcef11'));
    final params = [];
    final response = await read(
      function,
      params,
      atBlock,
    );
    return (response[0] as _i1.EthereumAddress);
  }

  /// The optional [atBlock] parameter can be used to view historical data. When
  /// set, the function will be evaluated in the specified block. By default, the
  /// latest on-chain block will be used.
  Future<_i1.EthereumAddress> MEP1004Token_({_i1.BlockNum? atBlock}) async {
    final function = self.abi.functions[4];
    assert(checkSignature(function, '048dc9e7'));
    final params = [];
    final response = await read(
      function,
      params,
      atBlock,
    );
    return (response[0] as _i1.EthereumAddress);
  }

  /// The optional [atBlock] parameter can be used to view historical data. When
  /// set, the function will be evaluated in the specified block. By default, the
  /// latest on-chain block will be used.
  Future<_i2.Uint8List> PERMIT_TYPEHASH({_i1.BlockNum? atBlock}) async {
    final function = self.abi.functions[5];
    assert(checkSignature(function, '30adf81f'));
    final params = [];
    final response = await read(
      function,
      params,
      atBlock,
    );
    return (response[0] as _i2.Uint8List);
  }

  /// The optional [transaction] parameter can be used to override parameters
  /// like the gas price, nonce and max gas. The `data` and `to` fields will be
  /// set by the contract.
  Future<String> __Controllable_init({
    required _i1.Credentials credentials,
    _i1.Transaction? transaction,
  }) async {
    final function = self.abi.functions[6];
    assert(checkSignature(function, '5d79343d'));
    final params = [];
    return write(
      credentials,
      transaction,
      function,
      params,
    );
  }

  /// The optional [transaction] parameter can be used to override parameters
  /// like the gas price, nonce and max gas. The `data` and `to` fields will be
  /// set by the contract.
  Future<String> addRewardToken(
    _i1.EthereumAddress token,
    _i1.EthereumAddress permitOwner,
    BigInt amountPerEpoch, {
    required _i1.Credentials credentials,
    _i1.Transaction? transaction,
  }) async {
    final function = self.abi.functions[7];
    assert(checkSignature(function, '0e56dddb'));
    final params = [
      token,
      permitOwner,
      amountPerEpoch,
    ];
    return write(
      credentials,
      transaction,
      function,
      params,
    );
  }

  /// The optional [transaction] parameter can be used to override parameters
  /// like the gas price, nonce and max gas. The `data` and `to` fields will be
  /// set by the contract.
  Future<String> claimRewards(
    BigInt MEP1004TokenId,
    _i1.EthereumAddress to,
    List<dynamic> proofs,
    List<BigInt> epochIds,
    List<dynamic> rewards, {
    required _i1.Credentials credentials,
    _i1.Transaction? transaction,
  }) async {
    final function = self.abi.functions[8];
    assert(checkSignature(function, '89c64b7d'));
    final params = [
      MEP1004TokenId,
      to,
      proofs,
      epochIds,
      rewards,
    ];
    return write(
      credentials,
      transaction,
      function,
      params,
    );
  }

  /// The optional [transaction] parameter can be used to override parameters
  /// like the gas price, nonce and max gas. The `data` and `to` fields will be
  /// set by the contract.
  Future<String> claimRewardsVerified(
    BigInt MEP1004TokenId,
    _i1.EthereumAddress to,
    List<BigInt> epochIds,
    List<dynamic> rewards,
    _i2.Uint8List signature, {
    required _i1.Credentials credentials,
    _i1.Transaction? transaction,
  }) async {
    final function = self.abi.functions[9];
    assert(checkSignature(function, 'b31046cd'));
    final params = [
      MEP1004TokenId,
      to,
      epochIds,
      rewards,
      signature,
    ];
    return write(
      credentials,
      transaction,
      function,
      params,
    );
  }

  /// The optional [atBlock] parameter can be used to view historical data. When
  /// set, the function will be evaluated in the specified block. By default, the
  /// latest on-chain block will be used.
  Future<_i1.EthereumAddress> claimVerifier({_i1.BlockNum? atBlock}) async {
    final function = self.abi.functions[10];
    assert(checkSignature(function, 'a93539d0'));
    final params = [];
    final response = await read(
      function,
      params,
      atBlock,
    );
    return (response[0] as _i1.EthereumAddress);
  }

  /// The optional [atBlock] parameter can be used to view historical data. When
  /// set, the function will be evaluated in the specified block. By default, the
  /// latest on-chain block will be used.
  Future<bool> controllers(
    _i1.EthereumAddress $param13, {
    _i1.BlockNum? atBlock,
  }) async {
    final function = self.abi.functions[11];
    assert(checkSignature(function, 'da8c229e'));
    final params = [$param13];
    final response = await read(
      function,
      params,
      atBlock,
    );
    return (response[0] as bool);
  }

  /// The optional [atBlock] parameter can be used to view historical data. When
  /// set, the function will be evaluated in the specified block. By default, the
  /// latest on-chain block will be used.
  Future<BigInt> currentEpoch({_i1.BlockNum? atBlock}) async {
    final function = self.abi.functions[12];
    assert(checkSignature(function, '76671808'));
    final params = [];
    final response = await read(
      function,
      params,
      atBlock,
    );
    return (response[0] as BigInt);
  }

  /// The optional [atBlock] parameter can be used to view historical data. When
  /// set, the function will be evaluated in the specified block. By default, the
  /// latest on-chain block will be used.
  Future<BigInt> epochExpiredTime({_i1.BlockNum? atBlock}) async {
    final function = self.abi.functions[13];
    assert(checkSignature(function, 'f0645620'));
    final params = [];
    final response = await read(
      function,
      params,
      atBlock,
    );
    return (response[0] as BigInt);
  }

  /// The optional [atBlock] parameter can be used to view historical data. When
  /// set, the function will be evaluated in the specified block. By default, the
  /// latest on-chain block will be used.
  Future<BigInt> epochReleaseTime(
    BigInt $param14, {
    _i1.BlockNum? atBlock,
  }) async {
    final function = self.abi.functions[14];
    assert(checkSignature(function, '977391a9'));
    final params = [$param14];
    final response = await read(
      function,
      params,
      atBlock,
    );
    return (response[0] as BigInt);
  }

  /// The optional [atBlock] parameter can be used to view historical data. When
  /// set, the function will be evaluated in the specified block. By default, the
  /// latest on-chain block will be used.
  Future<List<bool>> getMinerClaimedEpochs(
    BigInt MEP1004TokenId,
    List<BigInt> epochNumbers, {
    _i1.BlockNum? atBlock,
  }) async {
    final function = self.abi.functions[15];
    assert(checkSignature(function, 'aa4553b9'));
    final params = [
      MEP1004TokenId,
      epochNumbers,
    ];
    final response = await read(
      function,
      params,
      atBlock,
    );
    return (response[0] as List<dynamic>).cast<bool>();
  }

  /// The optional [atBlock] parameter can be used to view historical data. When
  /// set, the function will be evaluated in the specified block. By default, the
  /// latest on-chain block will be used.
  Future<bool> getMinerOnlineStatus(
    BigInt epochNumber,
    BigInt MEP1004TokenId, {
    _i1.BlockNum? atBlock,
  }) async {
    final function = self.abi.functions[16];
    assert(checkSignature(function, 'f7bdde4d'));
    final params = [
      epochNumber,
      MEP1004TokenId,
    ];
    final response = await read(
      function,
      params,
      atBlock,
    );
    return (response[0] as bool);
  }

  /// The optional [atBlock] parameter can be used to view historical data. When
  /// set, the function will be evaluated in the specified block. By default, the
  /// latest on-chain block will be used.
  Future<_i2.Uint8List> getRewardHash(
    BigInt MEP1004TokenId,
    List<BigInt> epochIds,
    List<dynamic> rewards, {
    _i1.BlockNum? atBlock,
  }) async {
    final function = self.abi.functions[17];
    assert(checkSignature(function, 'a61c742b'));
    final params = [
      MEP1004TokenId,
      epochIds,
      rewards,
    ];
    final response = await read(
      function,
      params,
      atBlock,
    );
    return (response[0] as _i2.Uint8List);
  }

  /// The optional [atBlock] parameter can be used to view historical data. When
  /// set, the function will be evaluated in the specified block. By default, the
  /// latest on-chain block will be used.
  Future<List<dynamic>> getRewardTokenInfo({_i1.BlockNum? atBlock}) async {
    final function = self.abi.functions[18];
    assert(checkSignature(function, '647428b9'));
    final params = [];
    final response = await read(
      function,
      params,
      atBlock,
    );
    return (response[0] as List<dynamic>).cast<dynamic>();
  }

  /// The optional [atBlock] parameter can be used to view historical data. When
  /// set, the function will be evaluated in the specified block. By default, the
  /// latest on-chain block will be used.
  Future<List<_i1.EthereumAddress>> getUserSelectedToken(
    _i1.EthereumAddress account, {
    _i1.BlockNum? atBlock,
  }) async {
    final function = self.abi.functions[19];
    assert(checkSignature(function, '54a61599'));
    final params = [account];
    final response = await read(
      function,
      params,
      atBlock,
    );
    return (response[0] as List<dynamic>).cast<_i1.EthereumAddress>();
  }

  /// The optional [transaction] parameter can be used to override parameters
  /// like the gas price, nonce and max gas. The `data` and `to` fields will be
  /// set by the contract.
  Future<String> initialize(
    _i1.EthereumAddress _treasury,
    _i1.EthereumAddress _ERC6551Registry,
    _i1.EthereumAddress _ERC6551AccountImplAddr,
    _i1.EthereumAddress _MEP1004Addr,
    _i1.EthereumAddress _sensorToken,
    BigInt _epochExpiredTime,
    BigInt _maxSelectToken, {
    required _i1.Credentials credentials,
    _i1.Transaction? transaction,
  }) async {
    final function = self.abi.functions[20];
    assert(checkSignature(function, 'b33f9527'));
    final params = [
      _treasury,
      _ERC6551Registry,
      _ERC6551AccountImplAddr,
      _MEP1004Addr,
      _sensorToken,
      _epochExpiredTime,
      _maxSelectToken,
    ];
    return write(
      credentials,
      transaction,
      function,
      params,
    );
  }

  /// The optional [atBlock] parameter can be used to view historical data. When
  /// set, the function will be evaluated in the specified block. By default, the
  /// latest on-chain block will be used.
  Future<BigInt> maxSelectToken({_i1.BlockNum? atBlock}) async {
    final function = self.abi.functions[21];
    assert(checkSignature(function, 'b9dbcb02'));
    final params = [];
    final response = await read(
      function,
      params,
      atBlock,
    );
    return (response[0] as BigInt);
  }

  /// The optional [atBlock] parameter can be used to view historical data. When
  /// set, the function will be evaluated in the specified block. By default, the
  /// latest on-chain block will be used.
  Future<_i1.EthereumAddress> owner({_i1.BlockNum? atBlock}) async {
    final function = self.abi.functions[22];
    assert(checkSignature(function, '8da5cb5b'));
    final params = [];
    final response = await read(
      function,
      params,
      atBlock,
    );
    return (response[0] as _i1.EthereumAddress);
  }

  /// The optional [transaction] parameter can be used to override parameters
  /// like the gas price, nonce and max gas. The `data` and `to` fields will be
  /// set by the contract.
  Future<String> releaseEpoch(
    BigInt epochNumber,
    _i2.Uint8List rewardMerkleRoot,
    _i2.Uint8List statusBitMap, {
    required _i1.Credentials credentials,
    _i1.Transaction? transaction,
  }) async {
    final function = self.abi.functions[23];
    assert(checkSignature(function, 'b780a70b'));
    final params = [
      epochNumber,
      rewardMerkleRoot,
      statusBitMap,
    ];
    return write(
      credentials,
      transaction,
      function,
      params,
    );
  }

  /// The optional [transaction] parameter can be used to override parameters
  /// like the gas price, nonce and max gas. The `data` and `to` fields will be
  /// set by the contract.
  Future<String> removeRewardToken(
    _i1.EthereumAddress token, {
    required _i1.Credentials credentials,
    _i1.Transaction? transaction,
  }) async {
    final function = self.abi.functions[24];
    assert(checkSignature(function, '3d509c97'));
    final params = [token];
    return write(
      credentials,
      transaction,
      function,
      params,
    );
  }

  /// The optional [transaction] parameter can be used to override parameters
  /// like the gas price, nonce and max gas. The `data` and `to` fields will be
  /// set by the contract.
  Future<String> renounceOwnership({
    required _i1.Credentials credentials,
    _i1.Transaction? transaction,
  }) async {
    final function = self.abi.functions[25];
    assert(checkSignature(function, '715018a6'));
    final params = [];
    return write(
      credentials,
      transaction,
      function,
      params,
    );
  }

  /// The optional [atBlock] parameter can be used to view historical data. When
  /// set, the function will be evaluated in the specified block. By default, the
  /// latest on-chain block will be used.
  Future<_i2.Uint8List> rewardMerkleRoots(
    BigInt $param34, {
    _i1.BlockNum? atBlock,
  }) async {
    final function = self.abi.functions[26];
    assert(checkSignature(function, '43fef2f8'));
    final params = [$param34];
    final response = await read(
      function,
      params,
      atBlock,
    );
    return (response[0] as _i2.Uint8List);
  }

  /// The optional [atBlock] parameter can be used to view historical data. When
  /// set, the function will be evaluated in the specified block. By default, the
  /// latest on-chain block will be used.
  Future<RewardTokens> rewardTokens(
    BigInt $param35, {
    _i1.BlockNum? atBlock,
  }) async {
    final function = self.abi.functions[27];
    assert(checkSignature(function, '7bb7bed1'));
    final params = [$param35];
    final response = await read(
      function,
      params,
      atBlock,
    );
    return RewardTokens(response);
  }

  /// The optional [transaction] parameter can be used to override parameters
  /// like the gas price, nonce and max gas. The `data` and `to` fields will be
  /// set by the contract.
  Future<String> selectToken(
    List<_i1.EthereumAddress> tokens,
    List<_i2.Uint8List> signatures, {
    required _i1.Credentials credentials,
    _i1.Transaction? transaction,
  }) async {
    final function = self.abi.functions[28];
    assert(checkSignature(function, '2fbde9ba'));
    final params = [
      tokens,
      signatures,
    ];
    return write(
      credentials,
      transaction,
      function,
      params,
    );
  }

  /// The optional [atBlock] parameter can be used to view historical data. When
  /// set, the function will be evaluated in the specified block. By default, the
  /// latest on-chain block will be used.
  Future<_i1.EthereumAddress> sensorToken({_i1.BlockNum? atBlock}) async {
    final function = self.abi.functions[29];
    assert(checkSignature(function, '680d65fa'));
    final params = [];
    final response = await read(
      function,
      params,
      atBlock,
    );
    return (response[0] as _i1.EthereumAddress);
  }

  /// The optional [transaction] parameter can be used to override parameters
  /// like the gas price, nonce and max gas. The `data` and `to` fields will be
  /// set by the contract.
  Future<String> setClaimVerifier(
    _i1.EthereumAddress _verifier, {
    required _i1.Credentials credentials,
    _i1.Transaction? transaction,
  }) async {
    final function = self.abi.functions[30];
    assert(checkSignature(function, '38eb8425'));
    final params = [_verifier];
    return write(
      credentials,
      transaction,
      function,
      params,
    );
  }

  /// The optional [transaction] parameter can be used to override parameters
  /// like the gas price, nonce and max gas. The `data` and `to` fields will be
  /// set by the contract.
  Future<String> setController(
    _i1.EthereumAddress controller,
    bool enabled, {
    required _i1.Credentials credentials,
    _i1.Transaction? transaction,
  }) async {
    final function = self.abi.functions[31];
    assert(checkSignature(function, 'e0dba60f'));
    final params = [
      controller,
      enabled,
    ];
    return write(
      credentials,
      transaction,
      function,
      params,
    );
  }

  /// The optional [transaction] parameter can be used to override parameters
  /// like the gas price, nonce and max gas. The `data` and `to` fields will be
  /// set by the contract.
  Future<String> setEpochExpiredTime(
    BigInt _epochExpiredTime, {
    required _i1.Credentials credentials,
    _i1.Transaction? transaction,
  }) async {
    final function = self.abi.functions[32];
    assert(checkSignature(function, '6d31a27f'));
    final params = [_epochExpiredTime];
    return write(
      credentials,
      transaction,
      function,
      params,
    );
  }

  /// The optional [transaction] parameter can be used to override parameters
  /// like the gas price, nonce and max gas. The `data` and `to` fields will be
  /// set by the contract.
  Future<String> setMaxSelectToken(
    BigInt _maxSelectToken, {
    required _i1.Credentials credentials,
    _i1.Transaction? transaction,
  }) async {
    final function = self.abi.functions[33];
    assert(checkSignature(function, '6d4b9712'));
    final params = [_maxSelectToken];
    return write(
      credentials,
      transaction,
      function,
      params,
    );
  }

  /// The optional [transaction] parameter can be used to override parameters
  /// like the gas price, nonce and max gas. The `data` and `to` fields will be
  /// set by the contract.
  Future<String> setRewardToken(
    _i1.EthereumAddress token,
    _i1.EthereumAddress permitOwner,
    BigInt amountPerEpoch, {
    required _i1.Credentials credentials,
    _i1.Transaction? transaction,
  }) async {
    final function = self.abi.functions[34];
    assert(checkSignature(function, '2e35e36f'));
    final params = [
      token,
      permitOwner,
      amountPerEpoch,
    ];
    return write(
      credentials,
      transaction,
      function,
      params,
    );
  }

  /// The optional [transaction] parameter can be used to override parameters
  /// like the gas price, nonce and max gas. The `data` and `to` fields will be
  /// set by the contract.
  Future<String> transferOwnership(
    _i1.EthereumAddress newOwner, {
    required _i1.Credentials credentials,
    _i1.Transaction? transaction,
  }) async {
    final function = self.abi.functions[35];
    assert(checkSignature(function, 'f2fde38b'));
    final params = [newOwner];
    return write(
      credentials,
      transaction,
      function,
      params,
    );
  }

  /// The optional [atBlock] parameter can be used to view historical data. When
  /// set, the function will be evaluated in the specified block. By default, the
  /// latest on-chain block will be used.
  Future<_i1.EthereumAddress> treasury({_i1.BlockNum? atBlock}) async {
    final function = self.abi.functions[36];
    assert(checkSignature(function, '61d027b3'));
    final params = [];
    final response = await read(
      function,
      params,
      atBlock,
    );
    return (response[0] as _i1.EthereumAddress);
  }

  /// The optional [atBlock] parameter can be used to view historical data. When
  /// set, the function will be evaluated in the specified block. By default, the
  /// latest on-chain block will be used.
  Future<bool> verifyMerkleProof(
    BigInt MEP1004TokenId,
    List<dynamic> proofs,
    List<BigInt> epochIds,
    List<dynamic> rewards, {
    _i1.BlockNum? atBlock,
  }) async {
    final function = self.abi.functions[37];
    assert(checkSignature(function, '6a3780c4'));
    final params = [
      MEP1004TokenId,
      proofs,
      epochIds,
      rewards,
    ];
    final response = await read(
      function,
      params,
      atBlock,
    );
    return (response[0] as bool);
  }

  /// Returns a live stream of all BulkClaimedReward events emitted by this contract.
  Stream<BulkClaimedReward> bulkClaimedRewardEvents({
    _i1.BlockNum? fromBlock,
    _i1.BlockNum? toBlock,
  }) {
    final event = self.event('BulkClaimedReward');
    final filter = _i1.FilterOptions.events(
      contract: self,
      event: event,
      fromBlock: fromBlock,
      toBlock: toBlock,
    );
    return client.events(filter).map((_i1.FilterEvent result) {
      final decoded = event.decodeResults(
        result.topics!,
        result.data!,
      );
      return BulkClaimedReward(
        decoded,
        result,
      );
    });
  }

  /// Returns a live stream of all ClaimedReward events emitted by this contract.
  Stream<ClaimedReward> claimedRewardEvents({
    _i1.BlockNum? fromBlock,
    _i1.BlockNum? toBlock,
  }) {
    final event = self.event('ClaimedReward');
    final filter = _i1.FilterOptions.events(
      contract: self,
      event: event,
      fromBlock: fromBlock,
      toBlock: toBlock,
    );
    return client.events(filter).map((_i1.FilterEvent result) {
      final decoded = event.decodeResults(
        result.topics!,
        result.data!,
      );
      return ClaimedReward(
        decoded,
        result,
      );
    });
  }

  /// Returns a live stream of all ControllerChanged events emitted by this contract.
  Stream<ControllerChanged> controllerChangedEvents({
    _i1.BlockNum? fromBlock,
    _i1.BlockNum? toBlock,
  }) {
    final event = self.event('ControllerChanged');
    final filter = _i1.FilterOptions.events(
      contract: self,
      event: event,
      fromBlock: fromBlock,
      toBlock: toBlock,
    );
    return client.events(filter).map((_i1.FilterEvent result) {
      final decoded = event.decodeResults(
        result.topics!,
        result.data!,
      );
      return ControllerChanged(
        decoded,
        result,
      );
    });
  }

  /// Returns a live stream of all Initialized events emitted by this contract.
  Stream<Initialized> initializedEvents({
    _i1.BlockNum? fromBlock,
    _i1.BlockNum? toBlock,
  }) {
    final event = self.event('Initialized');
    final filter = _i1.FilterOptions.events(
      contract: self,
      event: event,
      fromBlock: fromBlock,
      toBlock: toBlock,
    );
    return client.events(filter).map((_i1.FilterEvent result) {
      final decoded = event.decodeResults(
        result.topics!,
        result.data!,
      );
      return Initialized(
        decoded,
        result,
      );
    });
  }

  /// Returns a live stream of all OwnershipTransferred events emitted by this contract.
  Stream<OwnershipTransferred> ownershipTransferredEvents({
    _i1.BlockNum? fromBlock,
    _i1.BlockNum? toBlock,
  }) {
    final event = self.event('OwnershipTransferred');
    final filter = _i1.FilterOptions.events(
      contract: self,
      event: event,
      fromBlock: fromBlock,
      toBlock: toBlock,
    );
    return client.events(filter).map((_i1.FilterEvent result) {
      final decoded = event.decodeResults(
        result.topics!,
        result.data!,
      );
      return OwnershipTransferred(
        decoded,
        result,
      );
    });
  }

  /// Returns a live stream of all ReleaseEpoch events emitted by this contract.
  Stream<ReleaseEpoch> releaseEpochEvents({
    _i1.BlockNum? fromBlock,
    _i1.BlockNum? toBlock,
  }) {
    final event = self.event('ReleaseEpoch');
    final filter = _i1.FilterOptions.events(
      contract: self,
      event: event,
      fromBlock: fromBlock,
      toBlock: toBlock,
    );
    return client.events(filter).map((_i1.FilterEvent result) {
      final decoded = event.decodeResults(
        result.topics!,
        result.data!,
      );
      return ReleaseEpoch(
        decoded,
        result,
      );
    });
  }
}

class RewardTokens {
  RewardTokens(List<dynamic> response)
      : token = (response[0] as _i1.EthereumAddress),
        permitOwner = (response[1] as _i1.EthereumAddress),
        amountPerEpoch = (response[2] as BigInt);

  final _i1.EthereumAddress token;

  final _i1.EthereumAddress permitOwner;

  final BigInt amountPerEpoch;
}

class BulkClaimedReward {
  BulkClaimedReward(
    List<dynamic> response,
    this.event,
  )   : miner = (response[0] as _i1.EthereumAddress),
        epochIds = (response[1] as List<dynamic>).cast<BigInt>(),
        rewardInfos = (response[2] as List<dynamic>).cast<dynamic>();

  final _i1.EthereumAddress miner;

  final List<BigInt> epochIds;

  final List<dynamic> rewardInfos;

  final _i1.FilterEvent event;
}

class ClaimedReward {
  ClaimedReward(
    List<dynamic> response,
    this.event,
  )   : miner = (response[0] as _i1.EthereumAddress),
        epochNumber = (response[1] as BigInt),
        rewardInfo = (response[2] as dynamic);

  final _i1.EthereumAddress miner;

  final BigInt epochNumber;

  final dynamic rewardInfo;

  final _i1.FilterEvent event;
}

class ControllerChanged {
  ControllerChanged(
    List<dynamic> response,
    this.event,
  )   : controller = (response[0] as _i1.EthereumAddress),
        enabled = (response[1] as bool);

  final _i1.EthereumAddress controller;

  final bool enabled;

  final _i1.FilterEvent event;
}

class Initialized {
  Initialized(
    List<dynamic> response,
    this.event,
  ) : version = (response[0] as BigInt);

  final BigInt version;

  final _i1.FilterEvent event;
}

class OwnershipTransferred {
  OwnershipTransferred(
    List<dynamic> response,
    this.event,
  )   : previousOwner = (response[0] as _i1.EthereumAddress),
        newOwner = (response[1] as _i1.EthereumAddress);

  final _i1.EthereumAddress previousOwner;

  final _i1.EthereumAddress newOwner;

  final _i1.FilterEvent event;
}

class ReleaseEpoch {
  ReleaseEpoch(
    List<dynamic> response,
    this.event,
  )   : epochNumber = (response[0] as BigInt),
        rewardMerkleRoot = (response[1] as _i2.Uint8List),
        onlineStatusPointer = (response[2] as _i1.EthereumAddress);

  final BigInt epochNumber;

  final _i2.Uint8List rewardMerkleRoot;

  final _i1.EthereumAddress onlineStatusPointer;

  final _i1.FilterEvent event;
}
