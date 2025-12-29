import 'dart:async';

import '../core/api/oanda_api.dart';
import '../core/api/oanda_stream.dart';
import '../core/models/candle.dart';

class PriceFeedService {
  final OandaApi api;
  final OandaStream stream;
  CandleGranularity granularity;

  PriceFeedService({
    required this.api,
    required this.stream,
    this.granularity = CandleGranularity.m1,
  });

  final _candles = <Candle>[];
  final StreamController<List<Candle>> _controller = StreamController.broadcast();
  StreamSubscription? _subscription;

  Stream<List<Candle>> get prices => _controller.stream;
  List<Candle> get latest => List.unmodifiable(_candles);

  Future<void> initialize() async {
    final history = await api.fetchCandles(granularity: granularity);
    _candles
      ..clear()
      ..addAll(history);
    _controller.add(latest);
    _subscription = await stream.connect();
    _subscription?.onData(_onTick);
  }

  void changeGranularity(CandleGranularity newGranularity) async {
    granularity = newGranularity;
    await initialize();
  }

  void _onTick(Candle tick) {
    if (_candles.isEmpty) return;
    final last = _candles.last;
    final candleEnd = _endOfCandle(last.time, granularity);
    if (tick.time.isBefore(candleEnd)) {
      final updated = last.copyWith(
        high: tick.high > last.high ? tick.high : last.high,
        low: tick.low < last.low ? tick.low : last.low,
        close: tick.close,
        volume: last.volume + tick.volume,
      );
      _candles[_candles.length - 1] = updated;
    } else {
      _candles.add(
        Candle(
          time: candleEnd,
          open: last.close,
          high: tick.high,
          low: tick.low,
          close: tick.close,
          volume: tick.volume,
        ),
      );
    }
    _controller.add(latest);
  }

  DateTime _endOfCandle(DateTime time, CandleGranularity g) {
    switch (g) {
      case CandleGranularity.m1:
        return DateTime(time.year, time.month, time.day, time.hour, time.minute).add(const Duration(minutes: 1));
      case CandleGranularity.m5:
        final minute = (time.minute ~/ 5) * 5;
        return DateTime(time.year, time.month, time.day, time.hour, minute).add(const Duration(minutes: 5));
      case CandleGranularity.m15:
        final minute = (time.minute ~/ 15) * 15;
        return DateTime(time.year, time.month, time.day, time.hour, minute).add(const Duration(minutes: 15));
    }
  }

  void dispose() {
    _subscription?.cancel();
    _controller.close();
    stream.dispose();
  }
}
