class Config {
  static const int mxcMainnetChainId = 18686;
  static const int mxcTestnetChainId = 5167003;
  static const int ethereumMainnetChainId = 1;
  static const int ethDecimals = 18;
  static const String mxcSymbol = 'MXC';
  static const String mxcName = 'MXC Token';
  static const String mxcLogoUri = 'assets/svg/networks/mxc.svg';
  static const String zeroAddress =
      '0x0000000000000000000000000000000000000000';
  static const List<String> reloadDapp = [
    "https://erc20.mxc.com",
    "https://wannsee-erc20.mxc.com"
  ];

  static String mainnetMns(String name) =>
      'https://mns.mxc.com/$name.mxc/register';
  static String testnetMns(String name) =>
      'https://wannsee-mns.mxc.com/$name.mxc/register';

  // Numbers fixed decimals
  static int decimalFixed = 3;

  static bool isMxcChains(int chainId) {
    return chainId == mxcMainnetChainId || chainId == mxcTestnetChainId;
  }

  static bool isEthereumMainnet(int chainId) {
    return chainId == ethereumMainnetChainId;
  }
}
