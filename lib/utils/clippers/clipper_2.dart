import 'package:flutter/material.dart';

class Clipper2 extends CustomClipper<Path> {
  const Clipper2({this.radius = 25});

  final double radius;

  @override
  Path getClip(Size size) {
    final w = size.width;
    final h = size.height;
    final r = radius;
    return Path()
      ..moveTo(0, h)
      ..cubicTo(
        0.15 * w,
        0.4 * h,
        0.4 * w,
        0.2 * h,
        w,
        0,
      )
      ..lineTo(w, 0)
      ..lineTo(w, h - r)
      ..arcToPoint(
        Offset(w - r, h),
        radius: Radius.circular(r),
      )
      ..close();
  }

  @override
  bool shouldReclip(covariant CustomClipper oldClipper) {
    // TODO: implement shouldReclip
    throw UnimplementedError();
  }
}