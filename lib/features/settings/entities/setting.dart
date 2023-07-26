import 'package:datadashwallet/common/common.dart';
import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';

class Setting {
  const Setting({
    required this.title,
    required this.icon,
  });

  final String title;
  final IconData icon;

  static List<Setting> fixedSettings(BuildContext context) {
    return [
      Setting(
        title: FlutterI18n.translate(context, 'security'),
        icon: MXCIcons.security,
      ),
      Setting(
        title: FlutterI18n.translate(context, 'chain_configuration'),
        icon: MXCIcons.chain_configuration,
      ),
      Setting(
        title: FlutterI18n.translate(context, 'xsd_conversions'),
        icon: MXCIcons.conversion,
      ),
      Setting(
        title: FlutterI18n.translate(context, 'language'),
        icon: MXCIcons.language,
      ),
      Setting(
        title: FlutterI18n.translate(context, 'address_book'),
        icon: MXCIcons.address,
      ),
      Setting(
        title: FlutterI18n.translate(context, 'costumer_support'),
        icon: MXCIcons.faq,
      ),
      Setting(
        title: FlutterI18n.translate(context, 'about'),
        icon: MXCIcons.information,
      ),
    ];
  }
}
