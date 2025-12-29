import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/candle.dart';

class OandaStream {
  final String token;
  final String accountId;
  final StreamController<Candle> _controller = StreamController.broadcast();

  OandaStream({required this.token, required this.accountId});

  Stream<Candle> get stream => _controller.stream;

  Future<StreamSubscription> connect() async {
    final uri = Uri.https(
      'stream-fxpractice.oanda.com',
      '/v3/accounts/$accountId/pricing/stream',
      {'instruments': 'XAU_USD'},
    );
    final request = http.Request('GET', uri);
    request.headers['Authorization'] = 'Bearer $token';
    final response = await request.send();
    return response.stream.transform(utf8.decoder).transform(const LineSplitter()).listen((line) {
      if (line.isEmpty) return;
      try {
        final jsonLine = jsonDecode(line) as Map<String, dynamic>;
        if (jsonLine.containsKey('tick')) {
          final tick = jsonLine['tick'] as Map<String, dynamic>;
          final price = double.parse((tick['bid'] ?? tick['ask']).toString());
          final time = DateTime.parse(tick['time'] as String);
          _controller.add(
            Candle(time: time, open: price, high: price, low: price, close: price, volume: 0),
          );
        }
      } catch (_) {
        // ignore malformed packets but keep stream alive
      }
    });
  }

  void dispose() {
    _controller.close();
  }
}
