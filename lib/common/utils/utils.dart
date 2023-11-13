import 'package:datadashwallet/common/common.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:retry/retry.dart';

export 'formatter.dart';
export 'permission.dart';
export 'validation.dart';

class Utils {
  static Future<bool> isEmailAppAvailable() async {
    final url = Uri.parse(Urls.emailApp);

    return await canLaunchUrl(url);
  }

  static Future<void> launchEmailApp() async {
    final url = Uri.parse(Urls.emailApp);

    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      throw 'unable_to_launch_email_app';
    }
  }

  static void retryFunction(Function function) {
    retry(() => function());
  }
}
