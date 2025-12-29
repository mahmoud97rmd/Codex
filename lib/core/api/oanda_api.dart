import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:gold_trading_simulator/core/models/candle.dart';

class OandaApi {
  OandaApi({required this.apiToken, required this.accountId});

  final String apiToken;
  final String accountId;

  static const _baseUrl = 'https://api-fxpractice.oanda.com/v3';

  Future<List<Candle>> fetchCandles({
    String instrument = 'XAU_USD',
    String granularity = 'M1',
    int count = 300,
  }) async {
    final uri = Uri.parse(
      '$_baseUrl/instruments/$instrument/candles?granularity=$granularity&count=$count&price=M',
    );
    final response = await http.get(
      uri,
      headers: {
        'Authorization': 'Bearer $apiToken',
      },
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to load candles: ${response.body}');
    }
    final decoded = jsonDecode(response.body) as Map<String, dynamic>;
    final candles = decoded['candles'] as List<dynamic>;
    return candles
        .map((c) => Candle.fromOanda(c as Map<String, dynamic>))
        .toList();
  }
}
