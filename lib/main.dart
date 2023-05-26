import 'dart:math';
import 'package:flutter/material.dart';

class CircleData {
  late double value;
  late Color color;
  late String label;

  CircleData(this.value, this.color, this.label);
}

class PieChart extends StatelessWidget {
  final List<CircleData> data;

  PieChart(this.data);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CustomPaint(
          size: Size.square(200.0),
          painter: PieChartPainter(data),
        ),
        SizedBox(height: 10),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: data.map((circle) {
            return Row(
              children: [
                Container(
                  width: 12,
                  height: 12,
                  color: circle.color,
                ),
                SizedBox(width: 4),
                Text('${circle.label}: ${circle.value}'),
              ],
            );
          }).toList(),
        ),
      ],
    );
  }
}

class PieChartPainter extends CustomPainter {
  final List<CircleData> data;

  PieChartPainter(this.data);

  @override
  void paint(Canvas canvas, Size size) {
    double total = 0;
    data.forEach((circle) => total += circle.value);

    double startRadian = 0;
    for (var circle in data) {
      double sweepRadian = (circle.value / total) * 2 * pi;

      final paint = Paint()
        ..color = circle.color
        ..style = PaintingStyle.fill;

      canvas.drawArc(
        Rect.fromLTWH(0, 0, size.width, size.height),
        startRadian,
        sweepRadian,
        true,
        paint,
      );

      startRadian += sweepRadian;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}

void main() {
  runApp(
    MaterialApp(
      home: Scaffold(
        body: Center(
          child: PieChart([
            CircleData(30, Colors.red, 'Red'),
            CircleData(50, Colors.green, 'Green'),
            CircleData(20, Colors.blue, 'Blue'),
          ]),
        ),
      ),
    ),
  );
}
