import 'package:datadashwallet/features/security/security.dart';

class PasscodeRequiredPageState extends PasscodeBasePageState {
  int wrongInputCounter = 0;

  @override
  List<Object?> get props => [
        ...super.props,
        wrongInputCounter,
      ];
}
