import 'package:datadashwallet/common/common.dart';

class Urls {
  static const String mxcMainnetNftMarketPlace = 'https://nft.mxc.com/';
  static const String mxcTestnetNftMarketPlace = 'https://wannsee-nft.mxc.com/';
  static const String mxcStatus = 'https://mxc.instatus.com/';

  static const String dappRoot =
      'https://raw.githubusercontent.com/MXCzkEVM/MEP-1759-DApp-store/main';

  static const String iOSUrl =
      'https://apps.apple.com/us/app/axs-decentralized-wallet/id6460891587';

  static const String emailApp = 'mailto:';

  static const String gateio = 'https://gate.io/';
  static const String okx = 'https://www.okx.com/';
  static const String mainnetL3Bridge = 'https://erc20.mxc.com/';
  static const String testnetL3Bridge = 'https://wannsee-erc20.mxc.com/';

  static String mainnetMns(String name) =>
      'https://mns.mxc.com/$name.mxc/register';
  static String testnetMns(String name) =>
      'https://wannsee-mns.mxc.com/$name.mxc/register';

  static String txExplorer(String hash) {
    return 'tx/$hash';
  }

  static String addressExplorer(String address) {
    return 'address/$address';
  }

  static bool isL3Bridge(String url) {
    return url.contains('erc20.mxc.com') ||
        url.contains('wannsee-erc20.mxc.com');
  }

  static String networkL3Bridge(int chainId) =>
      Config.isMXCMainnet(chainId) ? mainnetL3Bridge : testnetL3Bridge;
}
