class DAppErrors {
  static SwitchEthereumChainErrors switchEthereumChainErrors =
      SwitchEthereumChainErrors();
  static AddEthereumChainErrors addEthereumChainErrors =
      AddEthereumChainErrors();
}

class SwitchEthereumChainErrors {
  Map<String, dynamic> unRecognizedChain(String rawChainId) => {
        "code": 4902,
        "message":
            """Unrecognized chain ID "$rawChainId" Try adding the chain using wallet_addEthereumChain first."""
      };
}

class AddEthereumChainErrors {
  static Map<String, dynamic> invalidData() =>
      {'code': -32602, 'message': 'Invalid data provided'};
}
