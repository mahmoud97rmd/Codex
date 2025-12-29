import 'dart:convert';
import 'dart:async';

import 'package:http/http.dart' as http;
import 'package:gold_trading_simulator/core/models/candle.dart';

class OandaStream {
  OandaStream({required this.apiToken, required this.accountId});

  final String apiToken;
  final String accountId;

  static const _streamUrl =
      'https://stream-fxpractice.oanda.com/v3/accounts';

  Stream<Candle> priceStream({String instrument = 'XAU_USD'}) async* {
    final uri = Uri.parse('$_streamUrl/$accountId/pricing/stream?instruments=$instrument');
    final request = http.Request('GET', uri);
    request.headers['Authorization'] = 'Bearer $apiToken';
    final response = await request.send();

    if (response.statusCode != 200) {
      throw Exception('Streaming connection failed: ${response.reasonPhrase}');
    }

    await for (final chunk in response.stream.transform(utf8.decoder)) {
      for (final line in const LineSplitter().convert(chunk)) {
        if (line.isEmpty) continue;
        final decoded = jsonDecode(line) as Map<String, dynamic>;
        if (decoded['type'] == 'PRICE') {
          final bids = decoded['bids'] as List<dynamic>;
          final asks = decoded['asks'] as List<dynamic>;
          final mid = (double.parse(bids.first['price'] as String) +
                  double.parse(asks.first['price'] as String)) /
              2;
          final time = DateTime.parse(decoded['time'] as String);
          yield Candle(
            time: time,
            open: mid,
            high: mid,
            low: mid,
            close: mid,
            volume: 0,
          );
        }
      }
    }
  }
}
