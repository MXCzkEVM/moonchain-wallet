import 'package:moonchain_wallet/features/settings/settings.dart';
import 'package:equatable/equatable.dart';

class ThemeSettingsState with EquatableMixin {
  late ThemeOption option;

  @override
  List<Object?> get props => [
        option,
      ];
}
