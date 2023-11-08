import 'package:flutter_inappwebview/flutter_inappwebview.dart';

/// Extension's [InAppWebViewController]
extension Web3Result on InAppWebViewController {
  /// send ["Canceled"] error to dapp
  void cancel(int id) {
    sendError("Canceled", id);
  }

  /// send error to dapp
  void sendError(String error, int id) {
    final script = "window.ethereum.sendError($id,\"$error\")";
    evaluateJavascript(source: script);
  }

  /// send error to dapp
  void sendProviderError(int id, int code, String message) {
    final script = "window.ethereum.sendProviderError($id, $code,\"$message\")";
    evaluateJavascript(source: script);
  }

  /// send result to dapp
  void sendResult(String result, int id) {
    final script = "window.ethereum.sendResponse($id, \"$result\")";
    evaluateJavascript(source: script);
  }

  /// send string list result to dapp
  void sendResults(List<String> results, int id) {
    final array = results
        .map((e) => e.toLowerCase())
        .toList()
        .map((e) => "\"$e\"")
        .toList();
    final arrayStr = array.join(",");
    final script = "window.ethereum.sendResponse($id, [$arrayStr])";
    evaluateJavascript(source: script);
  }

  /// set address connect to dapp
  void setAddress(String address, int id) async {
    address = address.toLowerCase();
    final script = "window.ethereum.setAddress('$address');";
    await evaluateJavascript(source: script);
    sendResults([address], id);
  }

  void setChain(String config, int chainId, int? id) async {
    final setConfigScript = "console.log(window.ethereum.setConfig($config))";
    final emitChainChangeScript =
        "console.log(window.ethereum.emitChainChanged($chainId))";
    await evaluateJavascript(source: setConfigScript);
    await evaluateJavascript(source: emitChainChangeScript);
    if (id != null) sendResult('null', id);
  }
}
