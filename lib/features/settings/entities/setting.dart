import 'package:datadashwallet/common/common.dart';
import 'package:datadashwallet/features/settings/settings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';

class Setting {
  const Setting({
    required this.title,
    required this.icon,
    required this.page,
  });

  final String title;
  final IconData icon;
  final Widget page;

  static List<Setting> fixedSettings(BuildContext context) {
    return [
      Setting(
        title: FlutterI18n.translate(context, 'security'),
        icon: MXCIcons.security,
        page: const AboutPage(),
      ),
      Setting(
        title: FlutterI18n.translate(context, 'chain_configuration'),
        icon: MXCIcons.chain_configuration,
        page: const AboutPage(),
      ),
      Setting(
        title: FlutterI18n.translate(context, 'xsd_conversions'),
        icon: MXCIcons.conversion,
        page: const AboutPage(),
      ),
      Setting(
        title: FlutterI18n.translate(context, 'language'),
        icon: MXCIcons.language,
        page: const LanguagePage(),
      ),
      Setting(
        title: FlutterI18n.translate(context, 'theme'),
        icon: MXCIcons.language,
        page: const ThemeSettingsPage(),
      ),
      Setting(
        title: FlutterI18n.translate(context, 'address_book'),
        icon: MXCIcons.address,
        page: const AboutPage(),
      ),
      Setting(
        title: FlutterI18n.translate(context, 'costumer_support'),
        icon: MXCIcons.faq,
        page: const AboutPage(),
      ),
      Setting(
        title: FlutterI18n.translate(context, 'about'),
        icon: MXCIcons.information,
        page: const AboutPage(),
      ),
    ];
  }
}
