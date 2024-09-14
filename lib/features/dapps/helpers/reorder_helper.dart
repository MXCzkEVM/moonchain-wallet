import 'package:moonchain_wallet/features/dapps/presentation/responsive_layout/dapp_utils.dart';
import 'package:mxc_logic/mxc_logic.dart';

import '../domain/domain.dart';
import '../presentation/dapps_state.dart';

class ReorderHelper {
  ReorderHelper({
    required this.dappsOrderUseCase,
    required this.state,
    required this.notify,
    required this.translate,
  });
  DappsOrderUseCase dappsOrderUseCase;
  DAppsState state;
  void Function([void Function()? fun]) notify;
  String? Function(String) translate;

  void handleOnReorder(int newIndex, int oldIndex) {
    dappsOrderUseCase.reorderDapp(
      oldIndex,
      newIndex,
    );
  }

  void updateReorderedDappsWrapper() {
    dappsMergedWrapper(updateReorderedDapps);
  }

  void updateReorderedDapps() {
    final chainDapps = getChainDapps();
    final newOrderDapps = DappUtils.reorderDApps(chainDapps, state.dappsOrder);
    notify(
      () => state.orderedDapps = newOrderDapps,
    );
  }

  List<Dapp> getChainDapps() {
    List<Dapp> chainDapps = DappUtils.getDappsByChainId(
      allDapps: state.dappsAndBookmarks,
      chainId: state.network!.chainId,
    );
    return chainDapps;
  }

  void updateDappsOrderWrapper() {
    dappsMergedWrapper(updateDappsOrder);
  }

  void updateDappsOrder() {
    if (state.bookMarksMerged & state.dappsMerged) {
      final chainDapps = getChainDapps();
      dappsOrderUseCase.updateOrder(dapps: chainDapps);
    }
  }

  // We need to confirm that all dapps and bookmarks are merged before moving to reordering them, Because If not then the order will be overwritten.
  void dappsMergedWrapper(Function func) {
    if (state.dappsMerged && state.bookMarksMerged) {
      func();
    }
  }

  void resetDappsMerge() {
    state.dappsMerged = false;
  }
}
