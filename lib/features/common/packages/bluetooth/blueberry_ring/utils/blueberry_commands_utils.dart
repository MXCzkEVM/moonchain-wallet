import 'dart:typed_data';

class Method {
  final int uid;
  final List<int>? arg;
  final bool frag;

  Method({required this.uid, this.arg, this.frag = false});
}

class BlueberryCommandsUtils {
  static List<String> radix16bcd(List<int> array, {bool no0x = false}) {
    return array.map((v) {
      String s = v.toRadixString(16);
      String b = '0x${s.length == 1 ? '0$s' : s}';
      return no0x ? bcd(b) : b;
    }).toList();
  }

  static String bcd(String str) {
    return str.replaceAll('0x', '');
  }

  static List<List<T>> splitArrayByLength<T>(List<T> arr, int length) {
    List<List<T>> result = [];
    for (int i = 0; i < arr.length; i += length) {
      int end = (i + length < arr.length) ? i + length : arr.length;
      result.add(arr.sublist(i, end));
    }
    return result;
  }

  static Uint8List parseMethodBytes(Method method,
      [List<int> args = const []]) {
    List<int> command = [method.uid, ...List.filled(15, 0x00)];
    int ai = 0;
    for (final index in method.arg ?? []) {
      command[index] = args.length > ai ? args[ai] : command[index];
      ai++;
    }
    int last = command.length - 1;
    int crc = command.sublist(0, last - 1).reduce((t, c) => t + c);
    command[last] = crc & 0xFF;
    return Uint8List.fromList(command);
  }
}
