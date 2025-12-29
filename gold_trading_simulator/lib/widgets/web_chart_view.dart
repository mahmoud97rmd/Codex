import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:gold_trading_simulator/core/models/candle.dart';
import 'package:gold_trading_simulator/core/models/trade.dart';
import 'package:gold_trading_simulator/core/utils/chart_data_converter.dart';

class WebChartView extends StatefulWidget {
  const WebChartView({super.key, required this.candles, required this.ema50, required this.ema150, required this.trades});

  final List<Candle> candles;
  final List<double> ema50;
  final List<double> ema150;
  final List<Trade> trades;

  @override
  State<WebChartView> createState() => _WebChartViewState();
}

class _WebChartViewState extends State<WebChartView> {
  late final WebViewController _controller;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(onPageFinished: (_) => _pushData()),
      )
      ..addJavaScriptChannel('FlutterChannel', onMessageReceived: (msg) {
        debugPrint('Chart message: ${msg.message}');
      })
      ..loadFlutterAsset('assets/chart/chart.html');
  }

  @override
  void didUpdateWidget(covariant WebChartView oldWidget) {
    super.didUpdateWidget(oldWidget);
    _pushData();
  }

  void _pushData() {
    final candlesJson = ChartDataConverter.candlesToJson(widget.candles);
    final ema50Json = ChartDataConverter.lineSeries(widget.ema50, widget.candles);
    final ema150Json = ChartDataConverter.lineSeries(widget.ema150, widget.candles);
    final tradesJson = jsonEncode(widget.trades
        .where((t) => !t.isOpen)
        .map((t) => {
              'time': (t.exitTime ?? t.entryCandle.time).millisecondsSinceEpoch ~/ 1000,
              'direction': t.direction.name,
            })
        .toList());

    _controller.runJavaScript('renderSeries($candlesJson, $ema50Json, $ema150Json, $tradesJson);');
  }

  @override
  Widget build(BuildContext context) {
    return WebViewWidget(controller: _controller);
  }
}
