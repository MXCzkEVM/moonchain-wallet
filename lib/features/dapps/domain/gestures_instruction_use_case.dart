import 'package:moonchain_wallet/core/core.dart';

import 'gestures_instruction_repository.dart';

class GesturesInstructionUseCase extends ReactiveUseCase {
  GesturesInstructionUseCase(this._repository);
  final GesturesInstructionRepository _repository;

  late final ValueStream<bool> educated = reactiveField(_repository.educated);

  void setEducated(bool value) {
    _repository.setEducated(value);
    update(educated, value);
  }
}
