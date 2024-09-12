import 'package:moonchain_wallet/core/core.dart';
import 'package:moonchain_wallet/features/settings/subfeatures/chain_configuration/domain/chain_configuration_use_case.dart';
import 'package:mxc_logic/mxc_logic.dart';

class FunctionUseCase extends ReactiveUseCase {
  FunctionUseCase(
    this._repository,
    this._chainConfigurationUseCase,
  );

  final Web3Repository _repository;
  final ChainConfigurationUseCase _chainConfigurationUseCase;

  void onlyMXCChainsFuncWrapper(
    Function mxcChainsFunc,
  ) {
    if (_chainConfigurationUseCase.isMXCChains()) {
      mxcChainsFunc();
    }
  }

  void mxcChainsAndEthereumFuncWrapper(
    Function func,
  ) {
    if (_chainConfigurationUseCase.isMXCChains() ||
        _chainConfigurationUseCase.isEthereumMainnet()) {
      func();
    }
  }

  void chainsFuncWrapper(Function mxcChainsFunc, Function noneMXCChainsFunc) {
    if (_chainConfigurationUseCase.isMXCChains()) {
      mxcChainsFunc();
    } else {
      noneMXCChainsFunc();
    }
  }
}
