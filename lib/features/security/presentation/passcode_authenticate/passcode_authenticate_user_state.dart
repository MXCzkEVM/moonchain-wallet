import 'package:moonchain_wallet/features/security/security.dart';

class PasscodeAuthenticateUserState extends PasscodeBasePageState {
  int wrongInputCounter = 0;

  @override
  List<Object?> get props => [
        ...super.props,
        wrongInputCounter,
      ];
}
