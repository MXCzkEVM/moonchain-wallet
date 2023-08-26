import 'package:flutter_dotenv/flutter_dotenv.dart';

class Sys {
  /// AppCenter Config of init method
  static final appSecretAndroid = dotenv.env['APPCENTER_SECRET_ANDROID'];
  static final distributionGroupIdAndroid =
      dotenv.env['APPCENTER_DISTRIBUTION_GROUP_ID_ANDROID'];
}
