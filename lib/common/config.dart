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
  static const String mxcAddressSepolia =
      '0x52f72a3c94a6ffca3f8caf769e14015fd040b0cd';
  static const String mxcAddressEthereum =
      '0x5Ca381bBfb58f0092df149bD3D243b08B9a8386e';
  static const List<String> reloadDapp = [
    "https://erc20.mxc.com",
    "https://wannsee-erc20.mxc.com"
  ];

  static String mainnetMns(String name) =>
      'https://mns.mxc.com/$name.mxc/register';
  static String testnetMns(String name) =>
      'https://wannsee-mns.mxc.com/$name.mxc/register';

  // Numbers fixed decimals
  static int decimalShowFixed = 3;
  static int decimalWriteFixed = 8;

  static bool isMxcChains(int chainId) {
    return chainId == mxcMainnetChainId || chainId == mxcTestnetChainId;
  }

  static bool isEthereumMainnet(int chainId) {
    return chainId == ethereumMainnetChainId;
  }

  static bool isL3Bridge(String url) {
    return url.contains('erc20.mxc.com') ||
        url.contains('wannsee-erc20.mxc.com');
  }

  static String txExplorer(String hash) {
    return 'tx/$hash';
  }

  static String addressExplorer(String address) {
    return 'address/$address';
  }
}
