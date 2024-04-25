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

  void reorderDapp(String url, newIndex) {
    final urlIndex = order.value.indexWhere((e) => e == url);
    List<String> newOrder;

    if (urlIndex == -1) {
      throw 'DApp not found for reordering.';
    } else {
      newOrder = order.value;
      newOrder.removeAt(urlIndex);
      newOrder.insert(newIndex, url);
    }

    _repository.setOrder(newOrder);
    update(order, newOrder);
  }

  /// This will update dappsOrder according to the latest dapps (chainDapps)
  void updateOrder({
    required List<Dapp> dapps,
  }) {
    List<String> dappsOrder = order.value;
    if (dappsOrder.isEmpty) {
      dappsOrder = dapps.map((e) => e.app!.url!).toList();
    }

    for (int i = 0; i < dapps.length; i++) {
      Dapp dapp = dapps[i];
      final dappsOrderIndex = dappsOrder.indexWhere(
        (e) => e == dapp.app!.url,
      );
      if (dappsOrderIndex != -1) {
        dappsOrder.removeAt(dappsOrderIndex);
        dappsOrder.insert(i, dapp.app!.url!);
      } else {
        dappsOrder.add(dapp.app!.url!);
      }
    }

    for (String dappOrder in dappsOrder) {
      final indexOfDapp = dapps.indexWhere((e) => e.app!.url == dappOrder);
      if (indexOfDapp == -1) {
        dappsOrder.remove(dappOrder);
      }
    }

    _repository.setOrder(dappsOrder);
    update(order, dappsOrder);
  }
}
