import 'package:mxc_logic/mxc_logic.dart';
import 'package:datadashwallet/core/core.dart';

class DAppHooksRepository extends ControlledCacheRepository {
  @override
  final String zone = 'dapp-hooks';
  late final Field<DAppHooksModel> dappHooksData =
      fieldWithDefault<DAppHooksModel>(
          'dappHooksData', DAppHooksModel.getDefault(),
          serializer: (b) => b.toMap(),
          deserializer: (b) => DAppHooksModel.fromMap(b));

  DAppHooksModel get item => dappHooksData.value;

  void updateItem(DAppHooksModel item) {
    dappHooksData.value = item;
  }

  void removeItem(DAppHooksModel item) =>
      dappHooksData.value = DAppHooksModel.getDefault();
}
