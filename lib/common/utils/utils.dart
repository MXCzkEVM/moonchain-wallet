import 'package:retry/retry.dart';

export 'permission.dart';
export 'validation.dart';

class Utils {
  static void retryFunction(Function function) {
    retry(() => function());
  }
}
