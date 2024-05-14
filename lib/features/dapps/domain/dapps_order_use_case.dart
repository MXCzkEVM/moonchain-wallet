import 'package:datadashwallet/core/core.dart';
import 'package:mxc_logic/mxc_logic.dart';

import 'dapps_order_repository.dart';

class DappsOrderUseCase extends ReactiveUseCase {
  DappsOrderUseCase(this._repository);
  final DappsOrderRepository _repository;

  late final ValueStream<List<String>> order = reactiveField(_repository.order);

  void setOrder(List<String> value) {
    _repository.setOrder(value);
    update(order, value);
  }

  void reorderDapp(int oldIndex, int newIndex) {
    List<String> newOrder;

    newOrder = order.value;
    final item = newOrder[oldIndex];
    newOrder.removeAt(oldIndex);
    newOrder.insert(newIndex, item);

    _repository.setOrder(newOrder);
    update(order, newOrder);
  }

  /// This will update dappsOrder according to the latest dapps (chainDapps)
  void updateOrder({
    required List<Dapp> dapps,
  }) {
    List<String> dappsOrder = order.value;
    if (dappsOrder.isEmpty) {
      dappsOrder = dapps.map((e) => e is Bookmark ? e.url : e.app!.url!).toList();
    }

    if (dapps.isEmpty) {
      return;
    }

    for (int i = 0; i < dapps.length; i++) {
      Dapp dapp = dapps[i];
      int dappsOrderIndex;
      if (dapp is Bookmark) {
        dappsOrderIndex = dappsOrder.indexWhere(
          (e) => e == dapp.url,
        );
      } else {
        dappsOrderIndex = dappsOrder.indexWhere(
          (e) => e == dapp.app!.url,
        );
      }

      if (dappsOrderIndex == -1) {
        dappsOrder.insert(i, dapp is Bookmark ? dapp.url : dapp.app!.url!);
      }
    }

    dappsOrder.removeWhere((element) =>
        dapps.indexWhere(
            (e) => (e is Bookmark ? e.url : e.app!.url) == element) ==
        -1);

    _repository.setOrder(dappsOrder);
    update(order, dappsOrder);
  }
}
