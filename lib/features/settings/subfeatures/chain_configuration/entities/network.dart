class Network {
  const Network(
      this.logo,
      this.web3RpcHttpUrl,
      this.web3RpcWebsocketUrl,
      this.web3WebSocketUrl,
      this.symbol,
      this.explorerUrl,
      this.enabled,
      this.label,
      this.chainId);

  final String logo;
  final String web3RpcHttpUrl;
  final String web3RpcWebsocketUrl;
  final String web3WebSocketUrl;
  final String symbol;
  final String explorerUrl;
  final bool enabled;
  final String label;
  final int chainId;

  static List<Network> fixedNetworks() {
    return [
      const Network(
          'assets/svg/networks/wannsee.svg',
          'https://wannsee-rpc.mxc.com',
          'wss://wannsee-rpc.mxc.com',
          'wss://wannsee-explorer-v1.mxc.com/socket/v2/websocket?vsn=2.0.0',
          'MXC',
          'https://wannsee-explorer.mxc.com',
          true,
          'MXC Wannsee Testnet',
          5167003),
      const Network(
          'assets/svg/networks/wannsee.svg',
          'https://rpc.mxc.com',
          'wss://rpc.mxc.com',
          'wss://wannsee-explorer-v1.mxc.com/socket/v2/websocket?vsn=2.0.0',
          'MXC',
          'https://explorer.mxc.com/',
          false,
          'MXC zkEVM Mainnet',
          18686),
      const Network('assets/svg/networks/ethereum.svg', '', '', '', 'Eth',
          'https://etherscan.io/', false, 'Ethereum Mainnet', 1),
      const Network('assets/svg/networks/arbitrum.svg', '', '', '', 'Eth',
          'https://arbiscan.io/', false, 'Arbitrum One', 42161),
      const Network(
          'assets/svg/networks/arbitrum.svg',
          'https://rpc.mxc.com',
          'https://rpc.mxc.com',
          '',
          'AGOR',
          'https://goerli-rollup-explorer.arbitrum.io/',
          false,
          'Arbitrum Goerli',
          421613)
    ];
  }
}
