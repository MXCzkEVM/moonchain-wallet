import 'package:datadashwallet/features/settings/subfeatures/notifications/notificaitons_page.dart';
import 'package:mxc_ui/mxc_ui.dart';
import 'package:mxc_logic/mxc_logic.dart';
import 'package:datadashwallet/core/core.dart';
import 'package:datadashwallet/features/settings/settings.dart';
import 'package:datadashwallet/features/settings/subfeatures/chain_configuration/chain_configuration_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:url_launcher/url_launcher.dart';

class Setting {
  const Setting(
      {required this.title,
      required this.icon,
      this.page,
      this.onTap,
      this.trailingIcon});

  final String title;
  final IconData icon;
  final Widget? page;
  final VoidCallback? onTap;
  final IconData? trailingIcon;

  static List<Setting> fixedSettings(BuildContext context) {
    return [
      Setting(
        title: FlutterI18n.translate(context, 'security'),
        icon: MxcIcons.security,
        page: const SecuritySettingsPage(),
      ),
      Setting(
          title: FlutterI18n.translate(context, 'chain_configuration'),
          icon: MxcIcons.chain_configuration,
          onTap: () => Navigator.of(context)
              .push(route(const ChainConfigurationPage()))),
      Setting(
        title: FlutterI18n.translate(context, 'xsd_conversions'),
        icon: MxcIcons.conversion,
        page: const XsdConversionRatePage(),
      ),
      Setting(
        title: FlutterI18n.translate(context, 'language'),
        icon: MxcIcons.language,
        page: const LanguagePage(),
      ),
      Setting(
        title: FlutterI18n.translate(context, 'theme'),
        icon: MxcIcons.theme,
        page: const ThemeSettingsPage(),
      ),
      Setting(
        title: FlutterI18n.translate(context, 'address_book'),
        icon: MxcIcons.address,
        page: const SelectRecipientPage(
          editFlow: true,
        ),
      ),
      Setting(
        title: FlutterI18n.translate(context, 'costomer_support'),
        icon: MxcIcons.faq,
        page: const CustomerSupportPage(),
      ),
      Setting(
        title: FlutterI18n.translate(context, 'about'),
        icon: MxcIcons.information,
        page: const AboutPage(),
      ),
      Setting(
          title: FlutterI18n.translate(context, 'notifications'),
          icon: Icons.notifications,
          page: const NotificationsPage(),
          trailingIcon: null,
          onTap: null),
      Setting(
          title: FlutterI18n.translate(context, 'network_status'),
          icon: MxcIcons.network_status,
          page: const AboutPage(),
          trailingIcon: MxcIcons.external_link,
          onTap: () async {
            final uri = Uri.parse(Urls.mxcStatus);
            if (await canLaunchUrl(uri)) launchUrl(uri);
          }),
    ];
  }
}
