import 'package:flutter/material.dart';

class RounderBox extends StatelessWidget {
  final double? borderRadius;
  final Color? color;
  final double? height;
  final double? width;
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final Gradient? gradient;
  const RounderBox(
      {Key? key,
      required this.child,
      this.borderRadius,
      this.color,
      this.height,
      this.width,
      this.padding,
      this.margin,
      this.gradient
      })
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      width: width,
      padding: padding,
      margin: margin,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius ?? 10),
        color: color,
        gradient: gradient
      ),
      child: child,
    );
  }
}
