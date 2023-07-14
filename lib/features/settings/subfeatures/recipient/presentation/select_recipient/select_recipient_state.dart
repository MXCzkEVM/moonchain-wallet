import 'package:equatable/equatable.dart';

import '../../entities/recipient.dart';

class SelectRecipientState with EquatableMixin {
  List<Recipient> recipients = [];
  
  @override
  List<Object?> get props => [
        recipients,
      ];
}
