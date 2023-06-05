// Generated code, do not modify. Run `build_runner build` to re-generate!
// @dart=2.12
import 'package:ens_dart/src/ens_dart.dart';
import 'package:web3dart/web3dart.dart' as _i1;
import 'dart:typed_data' as _i2;

final _contractAbi = _i1.ContractAbi.fromJson(
    '[{"inputs":[{"internalType":"contract BaseRegistrarImplementation","name":"_base","type":"address"},{"internalType":"contract IPriceOracle","name":"_prices","type":"address"},{"internalType":"uint256","name":"_minCommitmentAge","type":"uint256"},{"internalType":"uint256","name":"_maxCommitmentAge","type":"uint256"},{"internalType":"contract ReverseRegistrar","name":"_reverseRegistrar","type":"address"},{"internalType":"contract INameWrapper","name":"_nameWrapper","type":"address"},{"internalType":"contract ENS","name":"_ens","type":"address"}],"stateMutability":"nonpayable","type":"constructor"},{"inputs":[{"internalType":"bytes32","name":"commitment","type":"bytes32"}],"name":"CommitmentTooNew","type":"error"},{"inputs":[{"internalType":"bytes32","name":"commitment","type":"bytes32"}],"name":"CommitmentTooOld","type":"error"},{"inputs":[{"internalType":"uint256","name":"duration","type":"uint256"}],"name":"DurationTooShort","type":"error"},{"inputs":[],"name":"InsufficientValue","type":"error"},{"inputs":[],"name":"MaxCommitmentAgeTooHigh","type":"error"},{"inputs":[],"name":"MaxCommitmentAgeTooLow","type":"error"},{"inputs":[{"internalType":"string","name":"name","type":"string"}],"name":"NameNotAvailable","type":"error"},{"inputs":[],"name":"ResolverRequiredWhenDataSupplied","type":"error"},{"inputs":[{"internalType":"bytes32","name":"commitment","type":"bytes32"}],"name":"UnexpiredCommitmentExists","type":"error"},{"anonymous":false,"inputs":[{"indexed":false,"internalType":"string","name":"name","type":"string"},{"indexed":true,"internalType":"bytes32","name":"label","type":"bytes32"},{"indexed":true,"internalType":"address","name":"owner","type":"address"},{"indexed":false,"internalType":"uint256","name":"baseCost","type":"uint256"},{"indexed":false,"internalType":"uint256","name":"premium","type":"uint256"},{"indexed":false,"internalType":"uint256","name":"expires","type":"uint256"}],"name":"NameRegistered","type":"event"},{"anonymous":false,"inputs":[{"indexed":false,"internalType":"string","name":"name","type":"string"},{"indexed":true,"internalType":"bytes32","name":"label","type":"bytes32"},{"indexed":false,"internalType":"uint256","name":"cost","type":"uint256"},{"indexed":false,"internalType":"uint256","name":"expires","type":"uint256"}],"name":"NameRenewed","type":"event"},{"anonymous":false,"inputs":[{"indexed":true,"internalType":"address","name":"previousOwner","type":"address"},{"indexed":true,"internalType":"address","name":"newOwner","type":"address"}],"name":"OwnershipTransferred","type":"event"},{"inputs":[],"name":"MIN_REGISTRATION_DURATION","outputs":[{"internalType":"uint256","name":"","type":"uint256"}],"stateMutability":"view","type":"function"},{"inputs":[{"internalType":"int","name":"name","type":"int"}],"name":"available","outputs":[{"internalType":"bool","name":"","type":"bool"}],"stateMutability":"view","type":"function"},{"inputs":[{"internalType":"bytes32","name":"commitment","type":"bytes32"}],"name":"commit","outputs":[],"stateMutability":"nonpayable","type":"function"},{"inputs":[{"internalType":"bytes32","name":"","type":"bytes32"}],"name":"commitments","outputs":[{"internalType":"uint256","name":"","type":"uint256"}],"stateMutability":"view","type":"function"},{"inputs":[{"internalType":"string","name":"name","type":"string"},{"internalType":"address","name":"owner","type":"address"},{"internalType":"uint256","name":"duration","type":"uint256"},{"internalType":"bytes32","name":"secret","type":"bytes32"},{"internalType":"address","name":"resolver","type":"address"},{"internalType":"bytes[]","name":"data","type":"bytes[]"},{"internalType":"bool","name":"reverseRecord","type":"bool"},{"internalType":"uint16","name":"ownerControlledFuses","type":"uint16"}],"name":"makeCommitment","outputs":[{"internalType":"bytes32","name":"","type":"bytes32"}],"stateMutability":"pure","type":"function"},{"inputs":[],"name":"maxCommitmentAge","outputs":[{"internalType":"uint256","name":"","type":"uint256"}],"stateMutability":"view","type":"function"},{"inputs":[],"name":"minCommitmentAge","outputs":[{"internalType":"uint256","name":"","type":"uint256"}],"stateMutability":"view","type":"function"},{"inputs":[],"name":"nameWrapper","outputs":[{"internalType":"contract INameWrapper","name":"","type":"address"}],"stateMutability":"view","type":"function"},{"inputs":[{"internalType":"string","name":"name","type":"string"}],"name":"owner","outputs":[{"internalType":"address","name":"","type":"address"}],"stateMutability":"view","type":"function"},{"inputs":[],"name":"prices","outputs":[{"internalType":"contract IPriceOracle","name":"","type":"address"}],"stateMutability":"view","type":"function"},{"inputs":[{"internalType":"address","name":"_token","type":"address"},{"internalType":"address","name":"_to","type":"address"},{"internalType":"uint256","name":"_amount","type":"uint256"}],"name":"recoverFunds","outputs":[],"stateMutability":"nonpayable","type":"function"},{"inputs":[{"internalType":"string","name":"name","type":"string"},{"internalType":"address","name":"owner","type":"address"},{"internalType":"uint256","name":"duration","type":"uint256"},{"internalType":"bytes32","name":"secret","type":"bytes32"},{"internalType":"address","name":"resolver","type":"address"},{"internalType":"bytes[]","name":"data","type":"bytes[]"},{"internalType":"bool","name":"reverseRecord","type":"bool"},{"internalType":"uint16","name":"ownerControlledFuses","type":"uint16"}],"name":"register","outputs":[],"stateMutability":"payable","type":"function"},{"inputs":[{"internalType":"string","name":"name","type":"string"},{"internalType":"uint256","name":"duration","type":"uint256"}],"name":"renew","outputs":[],"stateMutability":"payable","type":"function"},{"inputs":[],"name":"renounceOwnership","outputs":[],"stateMutability":"nonpayable","type":"function"},{"inputs":[{"internalType":"string","name":"name","type":"string"},{"internalType":"uint256","name":"duration","type":"uint256"}],"name":"rentPrice","outputs":[{"components":[{"internalType":"uint256","name":"base","type":"uint256"},{"internalType":"uint256","name":"premium","type":"uint256"}],"internalType":"struct IPriceOracle.Price","name":"price","type":"tuple"}],"stateMutability":"view","type":"function"},{"inputs":[],"name":"reverseRegistrar","outputs":[{"internalType":"contract ReverseRegistrar","name":"","type":"address"}],"stateMutability":"view","type":"function"},{"inputs":[{"internalType":"bytes4","name":"interfaceID","type":"bytes4"}],"name":"supportsInterface","outputs":[{"internalType":"bool","name":"","type":"bool"}],"stateMutability":"pure","type":"function"},{"inputs":[{"internalType":"address","name":"newOwner","type":"address"}],"name":"transferOwnership","outputs":[],"stateMutability":"nonpayable","type":"function"},{"inputs":[{"internalType":"string","name":"name","type":"string"}],"name":"valid","outputs":[{"internalType":"bool","name":"","type":"bool"}],"stateMutability":"pure","type":"function"},{"inputs":[],"name":"withdraw","outputs":[],"stateMutability":"nonpayable","type":"function"}]',
    'Ens');

class Ens extends _i1.GeneratedContract {
  Ens(
      {_i1.EthereumAddress? address,
      required _i1.Web3Client client,
      int? chainId})
      : super(
          _i1.DeployedContract(
            _contractAbi,
            address ?? ENS_RESOLVER,
          ),
          client,
          chainId,
        );

  String? _ensName;
  String? get ensName => _ensName;
  Ens withName(String? _name) {
    _ensName = _name;
    return this;
  }

  EnsTextRecord? _textRecord;
  EnsTextRecord? get textRecord => _textRecord;
  void setEnsTextRecord(EnsTextRecord? _) {
    _textRecord = _;
  }

  Ens reverseEns(_i1.EthereumAddress addr) => Ens(
        address: addr,
        client: client,
      );

  _i1.EthereumAddress? _ensAddress;
  _i1.EthereumAddress? get ensAddress => _ensAddress;
  Ens withAddress(Object? _) {
    if (_.runtimeType == _i1.EthereumAddress) {
      _ensAddress = _ as _i1.EthereumAddress;
    } else {
      _ensAddress = _i1.EthereumAddress.fromHex('${_ ?? ''}');
    }
    return this;
  }

  /// The optional [atBlock] parameter can be used to view historical data. When
  /// set, the function will be evaluated in the specified block. By default, the
  /// latest on-chain block will be used.
  Future<ABI> abi(_i2.Uint8List node, BigInt contentTypes,
      {_i1.BlockNum? atBlock}) async {
    final function = self.abi.functions[1];
    assert(checkSignature(function, '2203ab56'));
    final params = [node, contentTypes];
    final response = await read(function, params, atBlock);
    return ABI(response);
  }

  /// The optional [atBlock] parameter can be used to view historical data. When
  /// set, the function will be evaluated in the specified block. By default, the
  /// latest on-chain block will be used.
  Future<_i1.EthereumAddress> addr(_i2.Uint8List node,
      {_i1.BlockNum? atBlock}) async {
    final function = self.abi.functions[2];
    assert(checkSignature(function, '3b3b57de'));
    final params = [node];
    final response = await read(function, params, atBlock);
    return (response[0] as _i1.EthereumAddress);
  }

   Future<_i1.EthereumAddress> address(String param,
      {_i1.BlockNum? atBlock}) async {
    final function = self.abi.functions[9];
    final response = await readOfString(function, param, atBlock);
    return (response[0] as _i1.EthereumAddress);
  }

  /// The optional [atBlock] parameter can be used to view historical data. When
  /// set, the function will be evaluated in the specified block. By default, the
  /// latest on-chain block will be used.
  Future<_i2.Uint8List> addr$2(_i2.Uint8List node, BigInt coinType,
      {_i1.BlockNum? atBlock}) async {
    final function = self.abi.functions[3];
    assert(checkSignature(function, 'f1cb7e06'));
    final params = [node, coinType];
    final response = await read(function, params, atBlock);
    return (response[0] as _i2.Uint8List);
  }

  /// The optional [atBlock] parameter can be used to view historical data. When
  /// set, the function will be evaluated in the specified block. By default, the
  /// latest on-chain block will be used.
  Future<bool> authorisations(_i2.Uint8List $param5,
      _i1.EthereumAddress $param6, _i1.EthereumAddress $param7,
      {_i1.BlockNum? atBlock}) async {
    final function = self.abi.functions[4];
    assert(checkSignature(function, 'f86bc879'));
    final params = [$param5, $param6, $param7];
    final response = await read(function, params, atBlock);
    return (response[0] as bool);
  }

  /// The optional [transaction] parameter can be used to override parameters
  /// like the gas price, nonce and max gas. The `data` and `to` fields will be
  /// set by the contract.
  Future<String> clearDNSZone(_i2.Uint8List node,
      {required _i1.Credentials credentials,
      _i1.Transaction? transaction}) async {
    final function = self.abi.functions[5];
    assert(checkSignature(function, 'ad5780af'));
    final params = [node];
    return write(credentials, transaction, function, params);
  }

  /// The optional [atBlock] parameter can be used to view historical data. When
  /// set, the function will be evaluated in the specified block. By default, the
  /// latest on-chain block will be used.
  Future<_i2.Uint8List> contenthash(_i2.Uint8List node,
      {_i1.BlockNum? atBlock}) async {
    final function = self.abi.functions[6];
    assert(checkSignature(function, 'bc1c58d1'));
    final params = [node];
    final response = await read(function, params, atBlock);
    return (response[0] as _i2.Uint8List);
  }

  /// The optional [atBlock] parameter can be used to view historical data. When
  /// set, the function will be evaluated in the specified block. By default, the
  /// latest on-chain block will be used.
  Future<_i2.Uint8List> dnsRecord(
      _i2.Uint8List node, _i2.Uint8List name, BigInt resource,
      {_i1.BlockNum? atBlock}) async {
    final function = self.abi.functions[7];
    assert(checkSignature(function, 'a8fa5682'));
    final params = [node, name, resource];
    final response = await read(function, params, atBlock);
    return (response[0] as _i2.Uint8List);
  }

  /// The optional [atBlock] parameter can be used to view historical data. When
  /// set, the function will be evaluated in the specified block. By default, the
  /// latest on-chain block will be used.
  Future<bool> hasDNSRecords(_i2.Uint8List node, _i2.Uint8List name,
      {_i1.BlockNum? atBlock}) async {
    final function = self.abi.functions[8];
    assert(checkSignature(function, '4cbf6ba4'));
    final params = [node, name];
    final response = await read(function, params, atBlock);
    return (response[0] as bool);
  }

  /// The optional [atBlock] parameter can be used to view historical data. When
  /// set, the function will be evaluated in the specified block. By default, the
  /// latest on-chain block will be used.
  Future<_i1.EthereumAddress> interfaceImplementer(
      _i2.Uint8List node, _i2.Uint8List interfaceID,
      {_i1.BlockNum? atBlock}) async {
    final function = self.abi.functions[9];
    assert(checkSignature(function, '124a319c'));
    final params = [node, interfaceID];
    final response = await read(function, params, atBlock);
    return (response[0] as _i1.EthereumAddress);
  }

  /// The optional [atBlock] parameter can be used to view historical data. When
  /// set, the function will be evaluated in the specified block. By default, the
  /// latest on-chain block will be used.
  Future<String> name(_i2.Uint8List node, {_i1.BlockNum? atBlock}) async {
    final function = self.abi.functions[10];
    assert(checkSignature(function, '691f3431'));
    final params = [node];
    final response = await read(function, params, atBlock);
    return (response[0] as String);
  }

  /// The optional [atBlock] parameter can be used to view historical data. When
  /// set, the function will be evaluated in the specified block. By default, the
  /// latest on-chain block will be used.
  Future<Pubkey> pubkey(_i2.Uint8List node, {_i1.BlockNum? atBlock}) async {
    final function = self.abi.functions[11];
    assert(checkSignature(function, 'c8690233'));
    final params = [node];
    final response = await read(function, params, atBlock);
    return Pubkey(response);
  }

  /// The optional [transaction] parameter can be used to override parameters
  /// like the gas price, nonce and max gas. The `data` and `to` fields will be
  /// set by the contract.
  Future<String> setABI(
      _i2.Uint8List node, BigInt contentType, _i2.Uint8List data,
      {required _i1.Credentials credentials,
      _i1.Transaction? transaction}) async {
    final function = self.abi.functions[12];
    assert(checkSignature(function, '623195b0'));
    final params = [node, contentType, data];
    return write(credentials, transaction, function, params);
  }

  /// The optional [transaction] parameter can be used to override parameters
  /// like the gas price, nonce and max gas. The `data` and `to` fields will be
  /// set by the contract.
  Future<String> setAddr(_i2.Uint8List node, BigInt coinType, _i2.Uint8List a,
      {required _i1.Credentials credentials,
      _i1.Transaction? transaction}) async {
    final function = self.abi.functions[13];
    assert(checkSignature(function, '8b95dd71'));
    final params = [node, coinType, a];
    return write(credentials, transaction, function, params);
  }

  /// The optional [transaction] parameter can be used to override parameters
  /// like the gas price, nonce and max gas. The `data` and `to` fields will be
  /// set by the contract.
  Future<String> setAddr$2(_i2.Uint8List node, _i1.EthereumAddress a,
      {required _i1.Credentials credentials,
      _i1.Transaction? transaction}) async {
    final function = self.abi.functions[14];
    assert(checkSignature(function, 'd5fa2b00'));
    final params = [node, a];
    return write(credentials, transaction, function, params);
  }

  /// The optional [transaction] parameter can be used to override parameters
  /// like the gas price, nonce and max gas. The `data` and `to` fields will be
  /// set by the contract.
  Future<String> setAuthorisation(
      _i2.Uint8List node, _i1.EthereumAddress target, bool isAuthorised,
      {required _i1.Credentials credentials,
      _i1.Transaction? transaction}) async {
    final function = self.abi.functions[15];
    assert(checkSignature(function, '3e9ce794'));
    final params = [node, target, isAuthorised];
    return write(credentials, transaction, function, params);
  }

  /// The optional [transaction] parameter can be used to override parameters
  /// like the gas price, nonce and max gas. The `data` and `to` fields will be
  /// set by the contract.
  Future<String> setContenthash(_i2.Uint8List node, _i2.Uint8List hash,
      {required _i1.Credentials credentials,
      _i1.Transaction? transaction}) async {
    final function = self.abi.functions[16];
    assert(checkSignature(function, '304e6ade'));
    final params = [node, hash];
    return write(credentials, transaction, function, params);
  }

  /// The optional [transaction] parameter can be used to override parameters
  /// like the gas price, nonce and max gas. The `data` and `to` fields will be
  /// set by the contract.
  Future<String> setDNSRecords(_i2.Uint8List node, _i2.Uint8List data,
      {required _i1.Credentials credentials,
      _i1.Transaction? transaction}) async {
    final function = self.abi.functions[17];
    assert(checkSignature(function, '0af179d7'));
    final params = [node, data];
    return write(credentials, transaction, function, params);
  }

  /// The optional [transaction] parameter can be used to override parameters
  /// like the gas price, nonce and max gas. The `data` and `to` fields will be
  /// set by the contract.
  Future<String> setInterface(_i2.Uint8List node, _i2.Uint8List interfaceID,
      _i1.EthereumAddress implementer,
      {required _i1.Credentials credentials,
      _i1.Transaction? transaction}) async {
    final function = self.abi.functions[18];
    assert(checkSignature(function, 'e59d895d'));
    final params = [node, interfaceID, implementer];
    return write(credentials, transaction, function, params);
  }

  /// The optional [transaction] parameter can be used to override parameters
  /// like the gas price, nonce and max gas. The `data` and `to` fields will be
  /// set by the contract.
  Future<String> setName(_i2.Uint8List node, String name,
      {required _i1.Credentials credentials,
      _i1.Transaction? transaction}) async {
    final function = self.abi.functions[19];
    assert(checkSignature(function, '77372213'));
    final params = [node, name];
    return write(credentials, transaction, function, params);
  }

  /// The optional [transaction] parameter can be used to override parameters
  /// like the gas price, nonce and max gas. The `data` and `to` fields will be
  /// set by the contract.
  Future<String> setPubkey(_i2.Uint8List node, _i2.Uint8List x, _i2.Uint8List y,
      {required _i1.Credentials credentials,
      _i1.Transaction? transaction}) async {
    final function = self.abi.functions[20];
    assert(checkSignature(function, '29cd62ea'));
    final params = [node, x, y];
    return write(credentials, transaction, function, params);
  }

  /// The optional [transaction] parameter can be used to override parameters
  /// like the gas price, nonce and max gas. The `data` and `to` fields will be
  /// set by the contract.
  Future<String> setText(_i2.Uint8List node, String key, String value,
      {required _i1.Credentials credentials,
      _i1.Transaction? transaction}) async {
    final function = self.abi.functions[21];
    assert(checkSignature(function, '10f13a8c'));
    final params = [node, key, value];
    return write(credentials, transaction, function, params);
  }

  /// The optional [atBlock] parameter can be used to view historical data. When
  /// set, the function will be evaluated in the specified block. By default, the
  /// latest on-chain block will be used.
  Future<bool> supportsInterface(_i2.Uint8List interfaceID,
      {_i1.BlockNum? atBlock}) async {
    final function = self.abi.functions[22];
    assert(checkSignature(function, '01ffc9a7'));
    final params = [interfaceID];
    final response = await read(function, params, atBlock);
    return (response[0] as bool);
  }

  /// The optional [atBlock] parameter can be used to view historical data. When
  /// set, the function will be evaluated in the specified block. By default, the
  /// latest on-chain block will be used.
  Future<String> text(_i2.Uint8List node, String key,
      {_i1.BlockNum? atBlock}) async {
    final function = self.abi.functions[23];
    assert(checkSignature(function, '59d1d43c'));
    final params = [node, key];
    final response = await read(function, params, atBlock);
    return (response[0] as String);
  }

  /// Returns a live stream of all ABIChanged events emitted by this contract.
  Stream<ABIChanged> aBIChangedEvents(
      {_i1.BlockNum? fromBlock, _i1.BlockNum? toBlock}) {
    final event = self.event('ABIChanged');
    final filter = _i1.FilterOptions.events(
        contract: self, event: event, fromBlock: fromBlock, toBlock: toBlock);
    return client.events(filter).map((_i1.FilterEvent result) {
      final decoded = event.decodeResults(result.topics!, result.data!);
      return ABIChanged(decoded);
    });
  }

  /// Returns a live stream of all AddrChanged events emitted by this contract.
  Stream<AddrChanged> addrChangedEvents(
      {_i1.BlockNum? fromBlock, _i1.BlockNum? toBlock}) {
    final event = self.event('AddrChanged');
    final filter = _i1.FilterOptions.events(
        contract: self, event: event, fromBlock: fromBlock, toBlock: toBlock);
    return client.events(filter).map((_i1.FilterEvent result) {
      final decoded = event.decodeResults(result.topics!, result.data!);
      return AddrChanged(decoded);
    });
  }

  /// Returns a live stream of all AddressChanged events emitted by this contract.
  Stream<AddressChanged> addressChangedEvents(
      {_i1.BlockNum? fromBlock, _i1.BlockNum? toBlock}) {
    final event = self.event('AddressChanged');
    final filter = _i1.FilterOptions.events(
        contract: self, event: event, fromBlock: fromBlock, toBlock: toBlock);
    return client.events(filter).map((_i1.FilterEvent result) {
      final decoded = event.decodeResults(result.topics!, result.data!);
      return AddressChanged(decoded);
    });
  }

  /// Returns a live stream of all AuthorisationChanged events emitted by this contract.
  Stream<AuthorisationChanged> authorisationChangedEvents(
      {_i1.BlockNum? fromBlock, _i1.BlockNum? toBlock}) {
    final event = self.event('AuthorisationChanged');
    final filter = _i1.FilterOptions.events(
        contract: self, event: event, fromBlock: fromBlock, toBlock: toBlock);
    return client.events(filter).map((_i1.FilterEvent result) {
      final decoded = event.decodeResults(result.topics!, result.data!);
      return AuthorisationChanged(decoded);
    });
  }

  /// Returns a live stream of all ContenthashChanged events emitted by this contract.
  Stream<ContenthashChanged> contenthashChangedEvents(
      {_i1.BlockNum? fromBlock, _i1.BlockNum? toBlock}) {
    final event = self.event('ContenthashChanged');
    final filter = _i1.FilterOptions.events(
        contract: self, event: event, fromBlock: fromBlock, toBlock: toBlock);
    return client.events(filter).map((_i1.FilterEvent result) {
      final decoded = event.decodeResults(result.topics!, result.data!);
      return ContenthashChanged(decoded);
    });
  }

  /// Returns a live stream of all DNSRecordChanged events emitted by this contract.
  Stream<DNSRecordChanged> dNSRecordChangedEvents(
      {_i1.BlockNum? fromBlock, _i1.BlockNum? toBlock}) {
    final event = self.event('DNSRecordChanged');
    final filter = _i1.FilterOptions.events(
        contract: self, event: event, fromBlock: fromBlock, toBlock: toBlock);
    return client.events(filter).map((_i1.FilterEvent result) {
      final decoded = event.decodeResults(result.topics!, result.data!);
      return DNSRecordChanged(decoded);
    });
  }

  /// Returns a live stream of all DNSRecordDeleted events emitted by this contract.
  Stream<DNSRecordDeleted> dNSRecordDeletedEvents(
      {_i1.BlockNum? fromBlock, _i1.BlockNum? toBlock}) {
    final event = self.event('DNSRecordDeleted');
    final filter = _i1.FilterOptions.events(
        contract: self, event: event, fromBlock: fromBlock, toBlock: toBlock);
    return client.events(filter).map((_i1.FilterEvent result) {
      final decoded = event.decodeResults(result.topics!, result.data!);
      return DNSRecordDeleted(decoded);
    });
  }

  /// Returns a live stream of all DNSZoneCleared events emitted by this contract.
  Stream<DNSZoneCleared> dNSZoneClearedEvents(
      {_i1.BlockNum? fromBlock, _i1.BlockNum? toBlock}) {
    final event = self.event('DNSZoneCleared');
    final filter = _i1.FilterOptions.events(
        contract: self, event: event, fromBlock: fromBlock, toBlock: toBlock);
    return client.events(filter).map((_i1.FilterEvent result) {
      final decoded = event.decodeResults(result.topics!, result.data!);
      return DNSZoneCleared(decoded);
    });
  }

  /// Returns a live stream of all InterfaceChanged events emitted by this contract.
  Stream<InterfaceChanged> interfaceChangedEvents(
      {_i1.BlockNum? fromBlock, _i1.BlockNum? toBlock}) {
    final event = self.event('InterfaceChanged');
    final filter = _i1.FilterOptions.events(
        contract: self, event: event, fromBlock: fromBlock, toBlock: toBlock);
    return client.events(filter).map((_i1.FilterEvent result) {
      final decoded = event.decodeResults(result.topics!, result.data!);
      return InterfaceChanged(decoded);
    });
  }

  /// Returns a live stream of all NameChanged events emitted by this contract.
  Stream<NameChanged> nameChangedEvents(
      {_i1.BlockNum? fromBlock, _i1.BlockNum? toBlock}) {
    final event = self.event('NameChanged');
    final filter = _i1.FilterOptions.events(
        contract: self, event: event, fromBlock: fromBlock, toBlock: toBlock);
    return client.events(filter).map((_i1.FilterEvent result) {
      final decoded = event.decodeResults(result.topics!, result.data!);
      return NameChanged(decoded);
    });
  }

  /// Returns a live stream of all PubkeyChanged events emitted by this contract.
  Stream<PubkeyChanged> pubkeyChangedEvents(
      {_i1.BlockNum? fromBlock, _i1.BlockNum? toBlock}) {
    final event = self.event('PubkeyChanged');
    final filter = _i1.FilterOptions.events(
        contract: self, event: event, fromBlock: fromBlock, toBlock: toBlock);
    return client.events(filter).map((_i1.FilterEvent result) {
      final decoded = event.decodeResults(result.topics!, result.data!);
      return PubkeyChanged(decoded);
    });
  }

  /// Returns a live stream of all TextChanged events emitted by this contract.
  Stream<TextChanged> textChangedEvents(
      {_i1.BlockNum? fromBlock, _i1.BlockNum? toBlock}) {
    final event = self.event('TextChanged');
    final filter = _i1.FilterOptions.events(
        contract: self, event: event, fromBlock: fromBlock, toBlock: toBlock);
    return client.events(filter).map((_i1.FilterEvent result) {
      final decoded = event.decodeResults(result.topics!, result.data!);
      return TextChanged(decoded);
    });
  }
}

class ABI {
  ABI(List<dynamic> response)
      : var1 = (response[0] as BigInt),
        var2 = (response[1] as _i2.Uint8List);

  final BigInt var1;

  final _i2.Uint8List var2;
}

class Pubkey {
  Pubkey(List<dynamic> response)
      : x = (response[0] as _i2.Uint8List),
        y = (response[1] as _i2.Uint8List);

  final _i2.Uint8List x;

  final _i2.Uint8List y;
}

class ABIChanged {
  ABIChanged(List<dynamic> response)
      : node = (response[0] as _i2.Uint8List),
        contentType = (response[1] as BigInt);

  final _i2.Uint8List node;

  final BigInt contentType;
}

class AddrChanged {
  AddrChanged(List<dynamic> response)
      : node = (response[0] as _i2.Uint8List),
        a = (response[1] as _i1.EthereumAddress);

  final _i2.Uint8List node;

  final _i1.EthereumAddress a;
}

class AddressChanged {
  AddressChanged(List<dynamic> response)
      : node = (response[0] as _i2.Uint8List),
        coinType = (response[1] as BigInt),
        newAddress = (response[2] as _i2.Uint8List);

  final _i2.Uint8List node;

  final BigInt coinType;

  final _i2.Uint8List newAddress;
}

class AuthorisationChanged {
  AuthorisationChanged(List<dynamic> response)
      : node = (response[0] as _i2.Uint8List),
        owner = (response[1] as _i1.EthereumAddress),
        target = (response[2] as _i1.EthereumAddress),
        isAuthorised = (response[3] as bool);

  final _i2.Uint8List node;

  final _i1.EthereumAddress owner;

  final _i1.EthereumAddress target;

  final bool isAuthorised;
}

class ContenthashChanged {
  ContenthashChanged(List<dynamic> response)
      : node = (response[0] as _i2.Uint8List),
        hash = (response[1] as _i2.Uint8List);

  final _i2.Uint8List node;

  final _i2.Uint8List hash;
}

class DNSRecordChanged {
  DNSRecordChanged(List<dynamic> response)
      : node = (response[0] as _i2.Uint8List),
        name = (response[1] as _i2.Uint8List),
        resource = (response[2] as BigInt),
        record = (response[3] as _i2.Uint8List);

  final _i2.Uint8List node;

  final _i2.Uint8List name;

  final BigInt resource;

  final _i2.Uint8List record;
}

class DNSRecordDeleted {
  DNSRecordDeleted(List<dynamic> response)
      : node = (response[0] as _i2.Uint8List),
        name = (response[1] as _i2.Uint8List),
        resource = (response[2] as BigInt);

  final _i2.Uint8List node;

  final _i2.Uint8List name;

  final BigInt resource;
}

class DNSZoneCleared {
  DNSZoneCleared(List<dynamic> response)
      : node = (response[0] as _i2.Uint8List);

  final _i2.Uint8List node;
}

class InterfaceChanged {
  InterfaceChanged(List<dynamic> response)
      : node = (response[0] as _i2.Uint8List),
        interfaceID = (response[1] as _i2.Uint8List),
        implementer = (response[2] as _i1.EthereumAddress);

  final _i2.Uint8List node;

  final _i2.Uint8List interfaceID;

  final _i1.EthereumAddress implementer;
}

class NameChanged {
  NameChanged(List<dynamic> response)
      : node = (response[0] as _i2.Uint8List),
        name = (response[1] as String);

  final _i2.Uint8List node;

  final String name;
}

class PubkeyChanged {
  PubkeyChanged(List<dynamic> response)
      : node = (response[0] as _i2.Uint8List),
        x = (response[1] as _i2.Uint8List),
        y = (response[2] as _i2.Uint8List);

  final _i2.Uint8List node;

  final _i2.Uint8List x;

  final _i2.Uint8List y;
}

class TextChanged {
  TextChanged(List<dynamic> response)
      : node = (response[0] as _i2.Uint8List),
        indexedKey = (response[1] as String),
        key = (response[2] as String);

  final _i2.Uint8List node;

  final String indexedKey;

  final String key;
}
