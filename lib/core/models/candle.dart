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

  Candle copyWith({double? open, double? high, double? low, double? close, double? volume}) {
    return Candle(
      time: time,
      open: open ?? this.open,
      high: high ?? this.high,
      low: low ?? this.low,
      close: close ?? this.close,
      volume: volume ?? this.volume,
    );
  }

  Map<String, dynamic> toJson() => {
        'time': time.millisecondsSinceEpoch,
        'open': open,
        'high': high,
        'low': low,
        'close': close,
        'volume': volume,
      };

  factory Candle.fromOanda(Map<String, dynamic> json) {
    return Candle(
      time: DateTime.parse(json['time'] as String),
      open: double.parse((json['mid']['o'] ?? json['open']).toString()),
      high: double.parse((json['mid']['h'] ?? json['high']).toString()),
      low: double.parse((json['mid']['l'] ?? json['low']).toString()),
      close: double.parse((json['mid']['c'] ?? json['close']).toString()),
      volume: double.tryParse(json['volume'].toString()) ?? 0,
    );
  }
}
