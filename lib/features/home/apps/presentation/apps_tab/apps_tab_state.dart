import 'package:datadashwallet/features/home/apps/apps.dart';
import 'package:equatable/equatable.dart';

class AppsTabPageState with EquatableMixin {
  List<DAppCard> dappCards = List.from(DAppCard.getAppCards());

  @override
  List<Object?> get props => [
        dappCards,
      ];
}
