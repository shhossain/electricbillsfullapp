import 'dart:ui';

import 'package:flutter/material.dart';


class GlassBox extends StatelessWidget {
  final double? height;
  final double? width;
  final Widget child;


  const GlassBox({Key? key,required this.child,this.height,this.width}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: Stack(
        children: [
          BackdropFilter(
            filter: ImageFilter.blur(
              sigmaX: 3,
              sigmaY: 3
            ),
            child: Container(),
          ),
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.white.withOpacity(0.4),
                  Colors.white.withOpacity(0.1)
                ]
              )
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Center(child: child),
          )
        ],
      ),
    );
  }
}