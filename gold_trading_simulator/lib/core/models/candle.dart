import 'dart:convert';

class Candle {
  final DateTime time;
  final double open;
  final double high;
  final double low;
  final double close;
  final double volume;

  Candle({
    required this.time,
    required this.open,
    required this.high,
    required this.low,
    required this.close,
    required this.volume,
  });

  Candle copyWith({
    DateTime? time,
    double? open,
    double? high,
    double? low,
    double? close,
    double? volume,
  }) {
    return Candle(
      time: time ?? this.time,
      open: open ?? this.open,
      high: high ?? this.high,
      low: low ?? this.low,
      close: close ?? this.close,
      volume: volume ?? this.volume,
    );
  }

  Map<String, dynamic> toJson() => {
        'time': time.millisecondsSinceEpoch ~/ 1000,
        'open': open,
        'high': high,
        'low': low,
        'close': close,
        'volume': volume,
      };

  static Candle fromOanda(Map<String, dynamic> raw) {
    final mid = raw['mid'] as Map<String, dynamic>;
    return Candle(
      time: DateTime.parse(raw['time'] as String),
      open: double.parse(mid['o'] as String),
      high: double.parse(mid['h'] as String),
      low: double.parse(mid['l'] as String),
      close: double.parse(mid['c'] as String),
      volume: (raw['volume'] as num).toDouble(),
    );
  }

  static String encodeList(List<Candle> candles) => jsonEncode(
        candles.map((c) => c.toJson()).toList(),
      );
}
