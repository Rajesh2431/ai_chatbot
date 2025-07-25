import 'package:flutter/material.dart';
import 'dart:math';
import 'dart:ui';

class CircularRevealRoute extends PageRouteBuilder {
  final Widget page;
  final Offset centerAlignment;
  final double startRadius;
  final Color revealColor;
  final Duration duration;

  CircularRevealRoute({
    required this.page,
    required this.centerAlignment,
    required this.startRadius,
    required this.revealColor,
    this.duration = const Duration(milliseconds: 600), // default
  }) : super(
          pageBuilder: (context, animation, secondaryAnimation) => page,
          transitionDuration: duration,
        );


  @override
  Color get barrierColor => revealColor;

  @override
  String get barrierLabel => 'Circular Reveal';

  @override
  Duration get transitionDuration => const Duration(milliseconds: 600);

  @override
  bool get opaque => false;

  @override
  bool get maintainState => true;

  @override
  Widget buildPage(BuildContext context, Animation<double> animation, Animation<double> secondaryAnimation) {
    return page;
  }

  @override
  Widget buildTransitions(BuildContext context, Animation<double> animation, Animation<double> secondaryAnimation, Widget child) {
    final size = MediaQuery.of(context).size;

    // Calculate max radius to cover the screen from centerAlignment
    final maxRadius = sqrt(pow(max(centerAlignment.dx, size.width - centerAlignment.dx), 2) +
        pow(max(centerAlignment.dy, size.height - centerAlignment.dy), 2));

    return AnimatedBuilder(
      animation: animation,
      builder: (context, _) {
        double radius = lerpDouble(startRadius, maxRadius, animation.value)!;
        return ClipPath(
          clipper: CircleRevealClipper(centerAlignment, radius),
          child: child,
        );
      },
      child: child,
    );
  }
}

class CircleRevealClipper extends CustomClipper<Path> {
  final Offset center;
  final double radius;

  CircleRevealClipper(this.center, this.radius);

  @override
  Path getClip(Size size) {
    return Path()..addOval(Rect.fromCircle(center: center, radius: radius));
  }

  @override
  bool shouldReclip(CircleRevealClipper oldClipper) {
    return radius != oldClipper.radius || center != oldClipper.center;
  }
}
