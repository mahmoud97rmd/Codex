import 'package:flutter/material.dart';

class StochasticPanel extends StatelessWidget {
  const StochasticPanel({super.key, required this.k, required this.d, required this.slow, required this.lower, required this.upper});

  final List<double> k;
  final List<double> d;
  final List<double> slow;
  final double lower;
  final double upper;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 160,
      child: CustomPaint(
        painter: _StochasticPainter(k: k, d: d, slow: slow, lower: lower, upper: upper),
        child: Container(),
      ),
    );
  }
}

class _StochasticPainter extends CustomPainter {
  _StochasticPainter({required this.k, required this.d, required this.slow, required this.lower, required this.upper});
  final List<double> k;
  final List<double> d;
  final List<double> slow;
  final double lower;
  final double upper;

  @override
  void paint(Canvas canvas, Size size) {
    final paintK = Paint()
      ..color = Colors.blue
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;
    final paintD = Paint()
      ..color = Colors.red
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;
    final paintSlow = Paint()
      ..color = Colors.orange
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final lowerY = size.height - (lower / 100) * size.height;
    final upperY = size.height - (upper / 100) * size.height;
    final guidePaint = Paint()
      ..color = Colors.grey
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(Offset(0, lowerY), Offset(size.width, lowerY), guidePaint);
    canvas.drawLine(Offset(0, upperY), Offset(size.width, upperY), guidePaint);

    void drawSeries(List<double> values, Paint paint) {
      if (values.length < 2) return;
      final step = size.width / (values.length - 1);
      final path = Path();
      for (int i = 0; i < values.length; i++) {
        final x = i * step;
        final y = size.height - (values[i] / 100) * size.height;
        if (i == 0) {
          path.moveTo(x, y);
        } else {
          path.lineTo(x, y);
        }
      }
      canvas.drawPath(path, paint);
    }

    drawSeries(k, paintK);
    drawSeries(d, paintD);
    drawSeries(slow, paintSlow);
  }

  @override
  bool shouldRepaint(covariant _StochasticPainter oldDelegate) =>
      oldDelegate.k != k || oldDelegate.d != d || oldDelegate.slow != slow ||
      oldDelegate.lower != lower || oldDelegate.upper != upper;
}
