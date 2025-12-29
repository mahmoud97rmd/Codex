import 'package:flutter/material.dart';

enum DrawingTool { trendline, horizontal, rectangle }

class DrawingToolsLayer extends StatefulWidget {
  const DrawingToolsLayer({super.key});

  @override
  State<DrawingToolsLayer> createState() => _DrawingToolsLayerState();
}

class _DrawingToolsLayerState extends State<DrawingToolsLayer> {
  DrawingTool selected = DrawingTool.trendline;
  final List<_Shape> shapes = [];
  Offset? start;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          child: GestureDetector(
            onPanStart: (d) => start = d.localPosition,
            onPanUpdate: (d) => setState(() {
              if (start != null) {
                shapes.removeWhere((s) => s.isPreview);
                shapes.add(_Shape(tool: selected, start: start!, end: d.localPosition, isPreview: true));
              }
            }),
            onPanEnd: (_) => setState(() {
              if (start != null) {
                shapes.removeWhere((s) => s.isPreview);
                shapes.add(_Shape(tool: selected, start: start!, end: start!, isPreview: false));
                start = null;
              }
            }),
            child: CustomPaint(
              painter: _ShapePainter(shapes: shapes),
            ),
          ),
        ),
        Positioned(
          left: 8,
          bottom: 8,
          child: Wrap(
            spacing: 8,
            children: [
              _toolButton('Trendline', DrawingTool.trendline),
              _toolButton('Horizontal', DrawingTool.horizontal),
              _toolButton('Rectangle', DrawingTool.rectangle),
            ],
          ),
        ),
      ],
    );
  }

  Widget _toolButton(String label, DrawingTool tool) {
    return ChoiceChip(
      label: Text(label),
      selected: selected == tool,
      onSelected: (_) => setState(() => selected = tool),
    );
  }
}

class _ShapePainter extends CustomPainter {
  _ShapePainter({required this.shapes});
  final List<_Shape> shapes;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.amber
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;
    for (final shape in shapes) {
      switch (shape.tool) {
        case DrawingTool.trendline:
          canvas.drawLine(shape.start, shape.end, paint);
          break;
        case DrawingTool.horizontal:
          canvas.drawLine(Offset(0, shape.start.dy), Offset(size.width, shape.start.dy), paint);
          break;
        case DrawingTool.rectangle:
          final rect = Rect.fromPoints(shape.start, shape.end);
          canvas.drawRect(rect, paint);
          break;
      }
    }
  }

  @override
  bool shouldRepaint(covariant _ShapePainter oldDelegate) => oldDelegate.shapes != shapes;
}

class _Shape {
  _Shape({required this.tool, required this.start, required this.end, required this.isPreview});
  final DrawingTool tool;
  final Offset start;
  final Offset end;
  final bool isPreview;
}
