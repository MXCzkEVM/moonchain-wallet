import 'dart:io';

import 'package:moonchain_wallet/common/common.dart';
import 'package:moonchain_wallet/core/core.dart';
import 'package:moonchain_wallet/features/portfolio/subfeatures/token/send_token/choose_crypto/choose_crypto_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:mxc_ui/mxc_ui.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';

class QrScannerPage extends StatefulWidget {
  const QrScannerPage({Key? key, this.returnQrCode = false}) : super(key: key);
  final bool returnQrCode;

  @override
  _QrScannerPageState createState() => _QrScannerPageState();
}

class _QrScannerPageState extends State<QrScannerPage> {
  final GlobalKey _qrKey = GlobalKey(debugLabel: 'QR');
  QRViewController? controller;
  bool flashEnabled = false;

  // In order to get hot reload to work we need to pause the camera if the platform
  // is android, or resume the camera if the platform is iOS.
  @override
  void reassemble() {
    super.reassemble();
    if (Platform.isAndroid) {
      controller!.pauseCamera();
    } else if (Platform.isIOS) {
      controller!.resumeCamera();
    }
  }

  void _onQRViewCreated(QRViewController controller) {
    this.controller = controller;
    controller.scannedDataStream.listen(_listener);
  }

  bool _lock = false;

  void _listener(Barcode barcode) {
    // listener can fire multiple times which results to executing pop several times.
    if (_lock) return;
    _lock = true;
    if (widget.returnQrCode) {
      Navigator.of(context).pop(barcode.code);
      return;
    }
    Navigator.of(context).push(route(ChooseCryptoPage(
      qrCode: barcode.code,
    )));
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MxcPage(
      appBar: MxcAppBarEvenly.close(
        titleText: '',
        useContentPadding: true,
        action: InkWell(
          onTap: () async {
            if (controller == null) return;
            await controller!.toggleFlash();
            setState(() => flashEnabled = !flashEnabled);
          },
          child: Icon(
            flashEnabled ? Icons.flash_on_rounded : Icons.flash_off_rounded,
            size: 32,
          ),
        ),
      ),
      layout: LayoutType.column,
      childrenPadding:
          const EdgeInsets.symmetric(horizontal: Sizes.spaceXLarge),
      children: [
        const SizedBox(height: Sizes.space5XLarge),
        SizedBox(
          width: 280,
          height: 280,
          child: QRView(
            key: _qrKey,
            onQRViewCreated: _onQRViewCreated,
            overlay: QrScannerOverlayShape(
              overlayColor: ColorsTheme.of(context).screenBackground,
              borderColor: ColorsTheme.of(context).borderWhiteInvert,
              borderRadius: 26,
              borderWidth: 5,
            ),
          ),
        ),
        const SizedBox(height: Sizes.space7XLarge),
        MxcButton.primary(
          key: const ValueKey('showQrCodeButton'),
          title: FlutterI18n.translate(context, 'show_qr_code'),
          icon: MxcIcons.qr_code,
          edgeType: UIConfig.settingsScreensButtonsEdgeType,
          onTap: () => BottomFlowDialog.of(context).close(),
        ),
      ],
    );
  }
}
