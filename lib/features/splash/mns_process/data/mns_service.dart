import 'dart:convert';
import 'package:http/http.dart' as http;

import 'ens_format.dart';

class MnsService {
  MnsService();

  static Future<String> queryNameAvailable(String value) async {
    final name = ENSFormat.nameHash(value);
    try {
      final response = await http.post(
        Uri.parse(
          'https://wannsee-rpc.mxc.com',
        ),
        body: jsonEncode({
          'jsonrpc': '2.0',
          'method': 'eth_call',
          'params': [
            {
              'to': '0xD9EeC15002fF7467a6841EDF6ea2D1048BaBc7c4',
              'data': name,
            },
            'latest'
          ],
          'id': 1,
        }),
        headers: {'Content-Type': 'application/json'},
      );

      final data = jsonDecode(response.body);
      if (data['result'] != null) return data['result'];

      throw Exception('Unknown response: $data');
    } catch (e) {
      throw Exception('Unknown error: $e');
    }
  }
}
