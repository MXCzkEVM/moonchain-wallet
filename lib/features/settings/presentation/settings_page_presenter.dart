import 'package:clipboard/clipboard.dart';
import 'package:flutter/services.dart';
import 'package:moonchain_wallet/core/core.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:package_info_plus/package_info_plus.dart';
import '../../../common/common.dart';
import 'settings_page_state.dart';

// import 'package:usb_serial_communication/usb_serial_communication.dart' as UsbSerialCommunication;
// import 'package:usb_serial_communication/models/device_info.dart' as UsbSerialCommunicationDeviceInfo;

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

  bool stateUsbStreamInit = false;

  void scan() async {
    // final _usbPlugin = UsbPlugin();

    // addMessage('Starting USB detection operation.');

    // try {
    //   print('Trying with USBSerial package...');
    //   List<UsbSerial.UsbDevice> devices =
    //       await UsbSerial.UsbSerial.listDevices();
    //   print('Connected devices : $devices');

    //   // print('Trying with QuickUSB package...');
    //   // await Future.delayed(Duration(seconds: 3), ()async {
    //   //   List<UsbDevice> devices = await UsbSerial.listDevices();
    //   //   print('Connected devices : $devices');
    //   // });

    //   print('Trying with SmartUSB package...');
    //   await SmartUsb.SmartUsb.init();
    //   print('SmartUsb.getDeviceList();.');
    //   var deviceList = await SmartUsb.SmartUsb.getDeviceList();
    //   await SmartUsb.SmartUsb.exit();
    //   print(
    //       'Connected deviceList : ${deviceList.map((e) => e.toString()).toList()}');

    //   print('Trying with LibusbAndroidHelper package...');
    //   List<LibusbAndroidHelper.UsbDevice>? libDevices =
    //       await LibusbAndroidHelper.LibusbAndroidHelper.listDevices();
    //   print(
    //       'Connected libDevices : ${libDevices?.map((e) => e.toString()).toList()}');

    //   // print('Trying with LibusbAndroidHelper package...');
    //   // final usbCommunication = UsbSerialCommunication.UsbSerialCommunication();
    //   // final comDevices = await usbCommunication.getAvailableDevices();
    //   // print(
    //   //     'Connected comDevices : ${comDevices?.map((e) => e.toString()).toList()}');

    //   addMessage('Done initializing USB plugin.');

    // } catch (e) {
    //   addMessage('Error initializing USB plugin: $e');
    //   print('Error initializing USB plugin: $e');
    // }

    // var description = await SmartUsb.getDeviceDescription(requestPermission: false);
    // if (!stateUsbStreamInit) {
    //   print('Listening to USB state changes');
    //   _usbPlugin.stateUsbStream().listen((state) {
    //     stateUsbStreamInit = true;
    //     addMessage('USB state changed: $state');
    //   });
    // } else {
    //   int? usbState = await _usbPlugin.checkUsbState();
    //   addMessage('USB state : ' + usbState.toString());
    // }

    // final connectedDevicesList = bluetoothUseCase.getConnectedDevices();

    // print(connectedDevicesList);
    // final firebaseToken = await FirebaseMessaging.instance.getToken();
    // print('Fireabse otken : $firebaseToken');
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
