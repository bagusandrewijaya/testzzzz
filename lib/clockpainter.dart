import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ClockPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // Draw clock face
    final centerX = size.width / 2;
    final centerY = size.height / 2;
    final centerOffset = Offset(centerX, centerY);
    final radius = size.width / 2;
    final facePaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    canvas.drawCircle(centerOffset, radius, facePaint);

    // Draw hour hand
    final hourHandPaint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6;
    final hour = DateTime.now().hour;
    final hourRadians = -(hour * 30 - 90) * (pi / 180);
    final hourHandX = centerX + (radius - 40) * cos(hourRadians);
    final hourHandY = centerY + (radius - 40) * sin(hourRadians);
    final hourHandOffset = Offset(hourHandX, hourHandY);
    canvas.drawLine(centerOffset, hourHandOffset, hourHandPaint);

    // Draw minute hand
    final minuteHandPaint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4;
    final minute = DateTime.now().minute;
    final minuteRadians = -(minute * 6 - 90) * (pi / 180);
    final minuteHandX = centerX + (radius - 30) * cos(minuteRadians);
    final minuteHandY = centerY + (radius - 30) * sin(minuteRadians);
    final minuteHandOffset = Offset(minuteHandX, minuteHandY);
    canvas.drawLine(centerOffset, minuteHandOffset, minuteHandPaint);

    // Draw second hand
    final secondHandPaint = Paint()
      ..color = Colors.red
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    final second = DateTime.now().second;
    final secondRadians = -(second * 6 - 90) * (pi / 180);
    final secondHandX = centerX + (radius - 20) * cos(secondRadians);
    final secondHandY = centerY + (radius - 20) * sin(secondRadians);
    final secondHandOffset = Offset(secondHandX, secondHandY);
    canvas.drawLine(centerOffset, secondHandOffset, secondHandPaint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}
