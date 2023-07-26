import 'package:equatable/equatable.dart';

class SettingsState with EquatableMixin {
  String? walletAddress;

  String? accountName;

  String? name;

  String? appVersion;

  @override
  List<Object?> get props => [
        walletAddress,
        accountName,
        name,
        appVersion,
      ];
}
