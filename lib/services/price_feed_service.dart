import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:gold_trading_simulator/core/api/oanda_api.dart';
import 'package:gold_trading_simulator/core/api/oanda_stream.dart';
import 'package:gold_trading_simulator/core/models/candle.dart';

class PriceFeedService extends ChangeNotifier {
  PriceFeedService({required this.api});

  final OandaApi api;
  late final OandaStream _stream =
      OandaStream(apiToken: api.apiToken, accountId: api.accountId);

  final List<Candle> _candles = [];
  Timer? _countdownTimer;
  Duration _timeframe = const Duration(minutes: 1);
  Duration _timeLeft = Duration.zero;
  StreamSubscription<Candle>? _streamSubscription;

  List<Candle> get candles => List.unmodifiable(_candles);
  Duration get timeLeft => _timeLeft;

  Future<void> loadHistory({String granularity = 'M1', int count = 300}) async {
    _timeframe = _mapGranularity(granularity);
    final result = await api.fetchCandles(granularity: granularity, count: count);
    _candles
      ..clear()
      ..addAll(result);
    _resetCountdown();
    notifyListeners();
  }

  void startStreaming({String instrument = 'XAU_USD'}) {
    _streamSubscription?.cancel();
    _streamSubscription = _stream.priceStream(instrument: instrument).listen(
      (tick) {
        if (_candles.isEmpty) return;
        final last = _candles.last;
        if (_isSameCandle(last.time, tick.time)) {
          _candles[_candles.length - 1] = last.copyWith(
            high: tick.high > last.high ? tick.high : last.high,
            low: tick.low < last.low ? tick.low : last.low,
            close: tick.close,
          );
        } else {
          _candles.add(tick.copyWith(open: last.close));
          _resetCountdown();
        }
        notifyListeners();
      },
    );
  }

  void stopStreaming() {
    _streamSubscription?.cancel();
    _streamSubscription = null;
  }

  bool _isSameCandle(DateTime a, DateTime b) {
    return _timeframe <= const Duration(minutes: 1)
        ? a.minute == b.minute && a.hour == b.hour && a.day == b.day
        : a.difference(b).abs() < _timeframe;
  }

  Duration _mapGranularity(String granularity) {
    switch (granularity) {
      case 'M5':
        return const Duration(minutes: 5);
      case 'M15':
        return const Duration(minutes: 15);
      default:
        return const Duration(minutes: 1);
    }
  }

  void _resetCountdown() {
    _countdownTimer?.cancel();
    _timeLeft = _timeframe;
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_timeLeft <= const Duration(seconds: 1)) {
        _timeLeft = _timeframe;
      } else {
        _timeLeft -= const Duration(seconds: 1);
      }
      notifyListeners();
    });
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    _streamSubscription?.cancel();
    super.dispose();
  }
}
