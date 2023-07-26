import 'package:clipboard/clipboard.dart';
import 'package:datadashwallet/common/utils/utils.dart';
import 'package:datadashwallet/core/core.dart';
import 'package:fl_chart/fl_chart.dart';
import 'dart:convert';
import 'package:mxc_logic/mxc_logic.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'settings_page_state.dart';

final settingsContainer = PresenterContainer<SettingsPresenter, SettingsState>(
    () => SettingsPresenter());

class SettingsPresenter extends CompletePresenter<SettingsState> {
  SettingsPresenter() : super(SettingsState());

  late final _accountUserCase = ref.read(accountUseCaseProvider);
  late final _contractUseCase = ref.read(contractUseCaseProvider);

  @override
  void initState() {
    super.initState();
    getAppVersion();

    listen(_accountUserCase.walletAddress, (value) {
      if (value != null) {
        notify(() => state.walletAddress = value);
      }
    });

    listen(_contractUseCase.name, (value) {
      if (value != null) {
        notify(() => state.name = value);
      }
    });

    _accountUserCase.refreshWallet();
  }

  void copyToClipboard(String text) async {
    FlutterClipboard.copy(text).then((value) => null);
  }

  void getAppVersion() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();

    String version = packageInfo.version;
    String buildNumber = packageInfo.buildNumber;

    notify(() => state.appVersion = ' $version ($buildNumber)');
  }
}
