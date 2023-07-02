import 'package:url_launcher/url_launcher.dart';

Future<void> openUrl(String url, {bool customTabs = false}) async {
  final uri = Uri.parse(url);
  if (await canLaunchUrl(uri)) {
    await launchUrl(
      uri,
      mode:
          customTabs ? LaunchMode.inAppWebView : LaunchMode.externalApplication,
    );
  } else {
    throw Exception('Could not launch $url');
  }
}
