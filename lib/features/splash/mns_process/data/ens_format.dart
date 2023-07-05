
import 'package:convert/convert.dart';
import 'package:sha3/sha3.dart';

class ENSFormat {
  static String nameHash(String? inputName) {
    var node = '';
    for (var i = 0; i < 32; i++) {
      node += '00';
    }
    if (inputName != null) {
      if (!inputName.contains('.mxc')) {
        inputName = '$inputName.mxc';
      }

      var labels = inputName.split('.');

      for (var i = labels.length - 1; i >= 0; i--) {
        String labelSha;
        if (isEncodedLabelhash(labels[i])) {
          labelSha = decodeLabelhash(labels[i]);
        } else {
          var normalisedLabel = labels[i];
          labelSha = sha3(normalisedLabel);
        }

        node = sha3(String.fromCharCodes(hex.decode('$node$labelSha')));
      }
    }

    return '0x6352211e' + node;
  }

  static bool isEncodedLabelhash(hash) {
    return hash.startsWith('[') && hash.endsWith(']') && hash.length == 66;
  }

  static String decodeLabelhash(String hash) {
    if (!(hash.startsWith('[') && hash.endsWith(']'))) {
      throw 'Expected encoded labelhash to start and end with square brackets';
    }

    if (hash.length != 66) {
      throw 'Expected encoded labelhash to have a length of 66';
    }

    return hash.slice(1, -1);
  }

  static String sha3(String string) {
    var hash =
        SHA3(256, KECCAK_PADDING, 256).update(string.runes.toList()).digest();

    return hex.encode(hash);
  }

  static String strip0x(String hex) {
    if (hex.startsWith('0x')) return hex.substring(2);
    return hex;
  }
}

extension Slice on String {
  String slice(int start, [int? end]) {
    if (end != null && end.isNegative) {
      return substring(start, length - end.abs());
    }
    return substring(start, end);
  }
}
