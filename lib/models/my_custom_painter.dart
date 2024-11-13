import 'package:flutter/material.dart';
import 'dart:ui' as ui;

import 'package:skribbl_clone/models/touch_points.dart';

class MyCustomPainter extends CustomPainter {
  MyCustomPainter({required this.pointsList});
  List<TouchPoints> pointsList;
  List<Offset> offsetPoints = [];

  @override
  void paint(Canvas canvas, Size size) {
    Paint background = Paint()..color = Colors.white;
    Rect rect = Rect.fromLTWH(0, 0, size.height, size.width);

    canvas.drawRect(rect, background);
    canvas.clipRect(rect);

    //logic:
    //if there is a point, we need to display point
    //if there is line, we neeed to connect points

    for (int i = 0; i < pointsList.length - 1; i++) {
      //current and next points are not null, then draw a line
      if (pointsList[i] != null && pointsList[i + 1] != null) {
        canvas.drawLine(
          pointsList[i].points,
          pointsList[i + 1].points,
          pointsList[i].paint,
        );
      }
      //if current is not null and next is null, then draw a point
      else if (pointsList[i] != null && pointsList[i + 1] == null) {
        offsetPoints.clear();
        offsetPoints.add(pointsList[i].points);
        offsetPoints.add(Offset(
          pointsList[i].points.dx + 0.1,
          pointsList[i].points.dy + 0.1,
        ));

        canvas.drawPoints(
          ui.PointMode.points,
          offsetPoints,
          pointsList[i].paint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
