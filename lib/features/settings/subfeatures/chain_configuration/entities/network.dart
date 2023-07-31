enum NetworkType { testnet, mainnet }

class Network {
  const Network({
    required this.logo,
    required this.web3RpcHttpUrl,
    required this.web3RpcWebsocketUrl,
    required this.web3WebSocketUrl,
    required this.symbol,
    required this.explorerUrl,
    required this.enabled,
    required this.label,
    required this.chainId,
    required this.isAdded,
    required this.networkType,
    this.gasLimit,
  });

  final String logo;
  final String web3RpcHttpUrl;
  final String web3RpcWebsocketUrl;
  final String web3WebSocketUrl;
  final String symbol;
  final String explorerUrl;
  final bool enabled;
  final String label;
  final int chainId;
  final int? gasLimit;
  final bool isAdded;
  final NetworkType networkType;

  Network copyWith(
      {String? logo,
      String? web3RpcHttpUrl,
      String? web3RpcWebsocketUrl,
      String? web3WebSocketUrl,
      String? symbol,
      String? explorerUrl,
      bool? enabled,
      String? label,
      int? chainId,
      int? gasLimit,
      bool? isAdded,
      NetworkType? networkType}) {
    return Network(
        logo: logo ?? this.logo,
        web3RpcHttpUrl: web3RpcHttpUrl ?? this.web3RpcHttpUrl,
        web3RpcWebsocketUrl: web3RpcWebsocketUrl ?? this.web3RpcWebsocketUrl,
        web3WebSocketUrl: web3WebSocketUrl ?? this.web3WebSocketUrl,
        symbol: symbol ?? this.symbol,
        explorerUrl: explorerUrl ?? this.explorerUrl,
        enabled: enabled ?? this.enabled,
        label: label ?? this.label,
        chainId: chainId ?? this.chainId,
        gasLimit: gasLimit ?? this.gasLimit,
        isAdded: isAdded ?? this.isAdded,
        networkType: networkType ?? this.networkType);
  }

  // This data will be initialized for the first time
  static List<Network> fixedNetworks() {
    return [
      const Network(
          logo: 'assets/svg/networks/wannsee.svg',
          web3RpcHttpUrl: 'https://wannsee-rpc.mxc.com',
          web3RpcWebsocketUrl: 'wss://wannsee-rpc.mxc.com',
          web3WebSocketUrl:
              'wss://wannsee-explorer-v1.mxc.com/socket/v2/websocket?vsn=2.0.0',
          symbol: 'MXC',
          explorerUrl: 'https://wannsee-explorer.mxc.com',
          enabled: true,
          label: 'MXC Wannsee Testnet',
          chainId: 5167003,
          gasLimit: null,
          isAdded: true,
          networkType: NetworkType.testnet),
      const Network(
          logo: 'assets/svg/networks/wannsee.svg',
          web3RpcHttpUrl: 'https://rpc.mxc.com',
          web3RpcWebsocketUrl: 'wss://rpc.mxc.com',
          web3WebSocketUrl:
              'wss://wannsee-explorer-v1.mxc.com/socket/v2/websocket?vsn=2.0.0',
          symbol: 'MXC',
          explorerUrl: 'https://explorer.mxc.com/',
          enabled: false,
          label: 'MXC zkEVM Mainnet',
          chainId: 18686,
          gasLimit: null,
          isAdded: false,
          networkType: NetworkType.mainnet),
      const Network(
          logo: 'assets/svg/networks/ethereum.svg',
          web3RpcHttpUrl: '',
          web3RpcWebsocketUrl: '',
          web3WebSocketUrl: '',
          symbol: 'Eth',
          explorerUrl: 'https://etherscan.io/',
          enabled: false,
          label: 'Ethereum Mainnet',
          chainId: 1,
          gasLimit: null,
          isAdded: false,
          networkType: NetworkType.mainnet),
      const Network(
          logo: 'assets/svg/networks/arbitrum.svg',
          web3RpcHttpUrl: '',
          web3RpcWebsocketUrl: '',
          web3WebSocketUrl: '',
          symbol: 'Eth',
          explorerUrl: 'https://arbiscan.io/',
          enabled: false,
          label: 'Arbitrum One',
          chainId: 42161,
          gasLimit: null,
          isAdded: false,
          networkType: NetworkType.mainnet),
      const Network(
          logo: 'assets/svg/networks/arbitrum.svg',
          web3RpcHttpUrl: 'https://rpc.mxc.com',
          web3RpcWebsocketUrl: 'https://rpc.mxc.com',
          web3WebSocketUrl: '',
          symbol: 'AGOR',
          explorerUrl: 'https://goerli-rollup-explorer.arbitrum.io/',
          enabled: false,
          label: 'Arbitrum Goerli',
          chainId: 42161,
          gasLimit: null,
          isAdded: false,
          networkType: NetworkType.testnet)
    ];
  }
}
