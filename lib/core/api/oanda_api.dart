import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/candle.dart';

enum CandleGranularity { m1, m5, m15 }

extension CandleGranularityExt on CandleGranularity {
  String get apiValue {
    switch (this) {
      case CandleGranularity.m1:
        return 'M1';
      case CandleGranularity.m5:
        return 'M5';
      case CandleGranularity.m15:
        return 'M15';
    }
  }
}

class OandaApi {
  final String token;
  final String accountId;
  final String baseUrl;

  OandaApi({
    required this.token,
    required this.accountId,
    this.baseUrl = 'https://api-fxpractice.oanda.com',
  });

  Future<List<Candle>> fetchCandles({
    required CandleGranularity granularity,
    int count = 400,
    DateTime? from,
    DateTime? to,
  }) async {
    final query = <String, String>{'granularity': granularity.apiValue, 'price': 'M', 'count': '$count'};
    if (from != null) query['from'] = from.toUtc().toIso8601String();
    if (to != null) query['to'] = to.toUtc().toIso8601String();
    final uri = Uri.parse('$baseUrl/v3/instruments/XAU_USD/candles').replace(queryParameters: query);
    final response = await http.get(uri, headers: _headers);
    if (response.statusCode != 200) {
      throw Exception('Failed to fetch candles: ${response.body}');
    }
    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final candles = (data['candles'] as List)
        .map((c) => Candle.fromOanda(c as Map<String, dynamic>))
        .where((c) => c.time.isBefore(DateTime.now().add(const Duration(minutes: 1))))
        .toList();
    return candles;
  }

  Map<String, String> get _headers => {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      };
}
