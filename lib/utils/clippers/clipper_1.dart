import 'package:flutter/material.dart';
//https://www.youtube.com/watch?v=pBYWIxhA4Bo

class Clipper1 extends CustomClipper<Path> {
  const Clipper1({this.radius = 25});

  final double radius;

  @override
  Path getClip(Size size) {
    final w = size.width;
    final h = size.height;
    final r = radius;
    return Path()
      ..moveTo(r, 0)
      ..lineTo(0.16 * w, 0)
      ..cubicTo(
        0.95 * w,
        0.1 * h,
        0.9 * w,
        0.2 * h,
        w,
        h,
      )
      ..lineTo(r, h)
      ..arcToPoint(
        Offset(0, h - r),
        radius: Radius.circular(r),
      )
      ..lineTo(0, r)
      ..arcToPoint(
        Offset(r, 0),
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

