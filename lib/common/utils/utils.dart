import 'package:mxc_logic/mxc_logic.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:retry/retry.dart';

export 'permission.dart';
export 'validation.dart';

class Utils {
  static void retryFunction(Function function) {
    retry(() => function());
  }
}
