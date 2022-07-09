import 'package:electricbills/colors.dart';
import 'package:flutter/material.dart';

class MyTextButton extends StatelessWidget {
  final Function()? onPressed;
  final Widget label;
  final double? width;
  final double? height;
  final Color? backgroundColor;
  final Color? foregroundColor;
  const MyTextButton({
    Key? key,
    this.onPressed,
    required this.label,
    this.width,
    this.height,
    this.backgroundColor,
    this.foregroundColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: TextButton(
        style: ButtonStyle(
            backgroundColor:
                MaterialStateProperty.all(backgroundColor ?? MyColors.cream),
            foregroundColor:
                MaterialStateProperty.all(foregroundColor ?? Colors.black)),
        onPressed: onPressed,
        child: label,
      ),
    );
  }
}
