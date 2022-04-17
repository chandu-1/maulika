import 'dart:convert';

import 'package:http/http.dart' as http;

class Repository {
 static Future<Map<String, dynamic>> getcoins(String coinSymbols) async {
    Uri url = Uri.parse(
        "https://pro-api.coinmarketcap.com/v1/cryptocurrency/quotes/latest?symbol=$coinSymbols");
    final response = await http.get(
      url,
      headers: <String, String>{
        'Accept': 'application/json; charset=UTF-8',
        "X-CMC_PRO_API_KEY": '27ab17d1-215f-49e5-9ca4-afd48810c149',
      },
    );
    final body = jsonDecode(response.body);
    print("body: $body");
    if (response.statusCode == 200) {
      return body['data'] as Map<String, dynamic>;
    } else {
      return Future.error(body['status']['error_message']);
    }
  }
}
