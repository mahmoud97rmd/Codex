import 'package:flutter/material.dart';

enum DrawingTool { trendline, horizontal, rectangle }

class DrawingToolsLayer extends StatefulWidget {
  final DrawingTool? activeTool;

  const DrawingToolsLayer({super.key, this.activeTool});

  @override
  State<DrawingToolsLayer> createState() => _DrawingToolsLayerState();
}

class _DrawingToolsLayerState extends State<DrawingToolsLayer> {
  final List<_Shape> _shapes = [];
  Offset? _start;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onPanStart: (details) {
        if (widget.activeTool != null) {
          _start = details.localPosition;
        }
      },
      onPanUpdate: (details) {
        if (_start != null && widget.activeTool != null) {
          setState(() {
            if (_shapes.isNotEmpty && _shapes.last.isDraft) {
              _shapes.removeLast();
            }
            _shapes.add(_Shape(widget.activeTool!, _start!, details.localPosition, isDraft: true));
          });
        }
      },
      onPanEnd: (_) {
        if (_shapes.isNotEmpty) {
          setState(() => _shapes[_shapes.length - 1] = _shapes.last.copyWith(isDraft: false));
        }
        _start = null;
      },
      child: CustomPaint(
        painter: _ShapePainter(_shapes),
        child: Container(),
      ),
    );
  }
}

class _ShapePainter extends CustomPainter {
  final List<_Shape> shapes;
  _ShapePainter(this.shapes);

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
          canvas.drawLine(Offset(0, shape.end.dy), Offset(size.width, shape.end.dy), paint);
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
  final DrawingTool tool;
  final Offset start;
  final Offset end;
  final bool isDraft;

  _Shape(this.tool, this.start, this.end, {this.isDraft = false});

  _Shape copyWith({bool? isDraft}) => _Shape(tool, start, end, isDraft: isDraft ?? this.isDraft);
}
