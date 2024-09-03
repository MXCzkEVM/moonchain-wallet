// Generated code, do not modify. Run `build_runner build` to re-generate!
// @dart=2.12
// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:web3dart/web3dart.dart' as _i1;

final _contractAbi = _i1.ContractAbi.fromJson(
  '[{"anonymous":false,"inputs":[{"indexed":true,"internalType":"string","name":"id","type":"string"},{"indexed":true,"internalType":"string","name":"store","type":"string"},{"indexed":false,"internalType":"string","name":"key","type":"string"},{"indexed":false,"internalType":"string","name":"value","type":"string"}],"name":"StorageUpdated","type":"event"},{"inputs":[{"internalType":"string","name":"store","type":"string"},{"internalType":"string","name":"key","type":"string"}],"name":"getItem","outputs":[{"internalType":"string","name":"","type":"string"}],"stateMutability":"view","type":"function"},{"inputs":[{"internalType":"string","name":"store","type":"string"},{"internalType":"string[]","name":"keys","type":"string[]"}],"name":"getStorage","outputs":[{"internalType":"string[]","name":"","type":"string[]"},{"internalType":"string[]","name":"","type":"string[]"}],"stateMutability":"view","type":"function"},{"inputs":[{"internalType":"string","name":"store","type":"string"},{"internalType":"string","name":"key","type":"string"},{"internalType":"string","name":"value","type":"string"}],"name":"setItem","outputs":[],"stateMutability":"nonpayable","type":"function"},{"inputs":[{"internalType":"string","name":"store","type":"string"},{"internalType":"string[][]","name":"pairs","type":"string[][]"}],"name":"setStorage","outputs":[],"stateMutability":"nonpayable","type":"function"}]',
  'Storage',
);

class Storage extends _i1.GeneratedContract {
  Storage({
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
  Future<String> getItem(
    String store,
    String key, {
    _i1.BlockNum? atBlock,
  }) async {
    final function = self.abi.functions[0];
    assert(checkSignature(function, 'c9b2b671'));
    final params = [
      store,
      key,
    ];
    final response = await read(
      function,
      params,
      atBlock,
    );
    return (response[0] as String);
  }

  /// The optional [atBlock] parameter can be used to view historical data. When
  /// set, the function will be evaluated in the specified block. By default, the
  /// latest on-chain block will be used.
  Future<GetStorage> getStorage(
    String store,
    List<String> keys, {
    _i1.BlockNum? atBlock,
  }) async {
    final function = self.abi.functions[1];
    assert(checkSignature(function, '503c1937'));
    final params = [
      store,
      keys,
    ];
    final response = await read(
      function,
      params,
      atBlock,
    );
    return GetStorage(response);
  }

  /// The optional [transaction] parameter can be used to override parameters
  /// like the gas price, nonce and max gas. The `data` and `to` fields will be
  /// set by the contract.
  Future<String> setItem(
    String store,
    String key,
    String value, {
    required _i1.Credentials credentials,
    _i1.Transaction? transaction,
  }) async {
    final function = self.abi.functions[2];
    assert(checkSignature(function, 'ca9b84ad'));
    final params = [
      store,
      key,
      value,
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
  Future<String> setStorage(
    String store,
    List<List<String>> pairs, {
    required _i1.Credentials credentials,
    _i1.Transaction? transaction,
  }) async {
    final function = self.abi.functions[3];
    assert(checkSignature(function, '5e434f40'));
    final params = [
      store,
      pairs,
    ];
    return write(
      credentials,
      transaction,
      function,
      params,
    );
  }

  /// Returns a live stream of all StorageUpdated events emitted by this contract.
  Stream<StorageUpdated> storageUpdatedEvents({
    _i1.BlockNum? fromBlock,
    _i1.BlockNum? toBlock,
  }) {
    final event = self.event('StorageUpdated');
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
      return StorageUpdated(
        decoded,
        result,
      );
    });
  }
}

class GetStorage {
  GetStorage(List<dynamic> response)
      : var1 = (response[0] as List<dynamic>).cast<String>(),
        var2 = (response[1] as List<dynamic>).cast<String>();

  final List<String> var1;

  final List<String> var2;
}

class StorageUpdated {
  StorageUpdated(
    List<dynamic> response,
    this.event,
  )   : id = (response[0] as String),
        store = (response[1] as String),
        key = (response[2] as String),
        value = (response[3] as String);

  final String id;

  final String store;

  final String key;

  final String value;

  final _i1.FilterEvent event;
}
