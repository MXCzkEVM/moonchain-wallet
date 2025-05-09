import 'package:clipboard/clipboard.dart';
import 'package:moonchain_wallet/core/core.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:package_info_plus/package_info_plus.dart';
import '../../../common/common.dart';
import 'settings_page_state.dart';

final settingsContainer = PresenterContainer<SettingsPresenter, SettingsState>(
    () => SettingsPresenter());

class SettingsPresenter extends CompletePresenter<SettingsState> {
  SettingsPresenter() : super(SettingsState());
  late final _accountUserCase = ref.read(accountUseCaseProvider);
  late final blueberryRingBackgroundNotificationsUseCase =
      ref.read(blueberryRingBackgroundNotificationsUseCaseProvider);
  late final contextLessTranslationUseCase =
      ref.read(contextLessTranslationUseCaseProvider);
  late final blueberryRingUseCase = ref.read(blueberryRingUseCaseProvider);
  late final bluetoothUseCase = ref.read(bluetoothUseCaseProvider);

  @override
  void initState() {
    super.initState();
    getAppVersion();

    listen(_accountUserCase.account, (value) {
      if (value != null) {
        notify(() => state.account = value);
      }
    });

    listen(_accountUserCase.accounts, (value) {
      notify(() => state.accounts = value);
    });
  }

  void copyToClipboard(String text) async {
    FlutterClipboard.copy(text).then((value) => null);

    showSnackBar(
        context: context!, content: FlutterI18n.translate(context!, 'copied'));
  }

  void getAppVersion() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();

    String version = packageInfo.version;
    String buildNumber = packageInfo.buildNumber;

    notify(() => state.appVersion = ' $version ($buildNumber)');
  }

  void scan() async {
    // final connectedDevicesList = bluetoothUseCase.getConnectedDevices();
    // print(connectedDevicesList);
    // await blueberryRingUseCase.getBlueberryRingsNearby(context!);
    // print(blueberryRingUseCase.selectedBlueberryRing.valueOrNull);
    
    // final ring = blueberryRingUseCase.selectedBlueberryRing.valueOrNull;
    // final uuids = ring!.advertisementData.serviceUuids;
    // final cstate = await ring!.device.connectionState.last;
    // await ring.device.connect();
    // final cnstate = await ring.device.connectionState.last;
    // await blueberryRingUseCase.connectToBlueberryRing();
    // blueberryRingUseCase.connectToBlueberryRing();
  }
}
