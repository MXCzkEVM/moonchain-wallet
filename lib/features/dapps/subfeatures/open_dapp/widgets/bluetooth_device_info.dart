import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:flutter_svg/svg.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:mxc_ui/mxc_ui.dart';

import '../open_dapp_presenter.dart';

class BlueberryDeviceInfo extends HookConsumerWidget {
  const BlueberryDeviceInfo({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(openDAppPageContainer.state);
    final scanResults = state.scanResults;
    final isBluetoothScanning = state.isBluetoothScanning;

    return Column(
      children: [
        isBluetoothScanning
            ? Container(
                margin: const EdgeInsets.only(bottom: Sizes.spaceSmall),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Center(
                      child: SizedBox(
                          height: 10,
                          width: 10,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                          )),
                    ),
                    const SizedBox(
                      width: Sizes.spaceSmall,
                    ),
                    Container(
                        alignment: AlignmentDirectional.centerStart,
                        child: Text(
                          FlutterI18n.translate(context, 'scanning'),
                          style: FontTheme.of(context).subtitle1.primary(),
                        )),
                  ],
                ),
              )
            : Container(),
        SingleChildScrollView(
          child: Column(
            children: scanResults
                .map(
                  (e) => InkWell(
                    onTap: () => Navigator.of(context).pop(e),
                    child: Column(
                      children: [
                        Container(
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: ColorsTheme.of(context)
                                        .primaryBackground),
                                height: 45,
                                width: 45,
                                child: SvgPicture.asset(
                                    'assets/svg/blueberryring.svg'),
                              ),
                              const SizedBox(
                                width: Sizes.spaceSmall,
                              ),
                              Text(
                                e.device.advName.isEmpty
                                    ? 'No name'
                                    : e.device.advName,
                                style: FontTheme.of(context).body2.primary(),
                              ),
                              const Spacer(),
                              Text(
                                e.device.remoteId.str,
                                style:
                                    FontTheme.of(context).subtitle2.primary(),
                              ),
                            ],
                          ),
                        ),
                        const Divider()
                      ],
                    ),
                  ),
                )
                .toList(),
          ),
        ),
      ],
    );
  }
}
