import 'package:datadashwallet/app/configuration.dart';
import 'package:datadashwallet/common/common.dart';
import 'package:datadashwallet/features/home/apps/apps.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:web3_provider/web3_provider.dart';

import 'open_app_presenter.dart';
import 'open_app_state.dart';

class OpenAppPage extends HookConsumerWidget {
  const OpenAppPage({
    Key? key,
    required this.dapp,
  }) : super(key: key);

  final DAppCard dapp;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final presenter = ref.read(openAppPageContainer.actions(dapp));
    final state = ref.watch(openAppPageContainer.state(dapp));

    return Scaffold(
      body: PresenterHooks(
        presenter: presenter,
        child: SafeArea(
          child: InAppWebViewEIP1193(
            chainId: Sys.chainId,
            rpcUrl: Sys.rpcUrl,
            isDebug: false,
            initialOptions: InAppWebViewGroupOptions(
              crossPlatform: InAppWebViewOptions(
                useShouldOverrideUrlLoading: true,
              ),
            ),
            shouldOverrideUrlLoading: (controller, navAction) async {
              final url = navAction.request.url.toString();
              debugPrint('URL $url');
              if (url.contains('wc?uri=')) {
                final wcUri = Uri.parse(
                    Uri.decodeFull(Uri.parse(url).queryParameters['uri']!));
                presenter.connectWalletHandler(wcUri.toString());

                return NavigationActionPolicy.CANCEL;
              } else if (url.startsWith('wc:')) {
                presenter.connectWalletHandler(url);

                return NavigationActionPolicy.CANCEL;
              } else {
                return NavigationActionPolicy.ALLOW;
              }
            },
            signCallback: (params, eip1193, controller) {
              final id = params["id"];
              switch (eip1193) {
                case EIP1193.requestAccounts:
                  if (state.address != null) {
                    controller?.setAddress(state.address!.hex, id);
                  }
                  break;
                default:
                  break;
              }
            },
            initialUrlRequest: URLRequest(
              url: Uri.parse(dapp.url!),
            ),
          ),
        ),
      ),
    );
  }
}
