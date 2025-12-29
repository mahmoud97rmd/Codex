import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../core/models/candle.dart';
import '../core/utils/chart_data_converter.dart';

class WebChartView extends StatefulWidget {
  final List<Candle> candles;
  final List<double> ema50;
  final List<double> ema150;
  final void Function()? onReady;
  final ValueChanged<DateTime>? onCrosshairMove;

  const WebChartView({
    super.key,
    required this.candles,
    required this.ema50,
    required this.ema150,
    this.onReady,
    this.onCrosshairMove,
  });

  @override
  State<WebChartView> createState() => _WebChartViewState();
}

class _WebChartViewState extends State<WebChartView> {
  late final WebViewController _controller;
  bool _loaded = false;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..addJavaScriptChannel('DartChannel', onMessageReceived: _onJsMessage)
      ..setNavigationDelegate(
        NavigationDelegate(onPageFinished: (_) {
          setState(() => _loaded = true);
          _pushData();
          widget.onReady?.call();
        }),
      )
      ..loadFlutterAsset('assets/chart/chart.html');
  }

  @override
  void didUpdateWidget(covariant WebChartView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_loaded && (oldWidget.candles != widget.candles || oldWidget.ema50 != widget.ema50)) {
      _pushData();
    }
  }

  void _pushData() {
    final candlesJson = ChartDataConverter.candlesToJson(widget.candles);
    final ema50 = jsonEncode(widget.ema50);
    final ema150 = jsonEncode(widget.ema150);
    _controller.runJavaScript('setSeries($candlesJson, $ema50, $ema150);');
  }

  void _onJsMessage(JavaScriptMessage message) {
    final payload = jsonDecode(message.message) as Map<String, dynamic>;
    if (payload['type'] == 'crosshair' && payload['time'] != null) {
      final epoch = (payload['time'] as num).toInt();
      widget.onCrosshairMove?.call(DateTime.fromMillisecondsSinceEpoch(epoch * 1000));
    }
  }

  @override
  Widget build(BuildContext context) {
    return WebViewWidget(controller: _controller);
  }
}
