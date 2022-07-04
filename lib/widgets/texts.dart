import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class NoTextGiven implements Exception {
  String cause;
  NoTextGiven(this.cause);
}

class MyText extends StatelessWidget {
  final String text;
  final String? fontFamily;
  final FontWeight? fontWeight;
  final double? fontSize;
  final int? maxLines;
  final TextOverflow? overflow;
  final Color? textColor;
  final Color? backgroundColor;
  const MyText({
    Key? key,
    required this.text,
    this.fontSize,
    this.fontWeight,
    this.maxLines,
    this.overflow,
    this.textColor,
    this.backgroundColor,
    this.fontFamily,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: text,
      textStyle: GoogleFonts.roboto(
        fontSize: 13,
        fontWeight: FontWeight.normal,
      ),
      child: Text(
        text,
        style: GoogleFonts.getFont(
          fontFamily ?? 'Poppins',
          fontSize: fontSize,
          fontWeight: fontWeight,
          color: textColor,
          backgroundColor: backgroundColor,
        ),
        maxLines: maxLines,
        overflow: overflow ?? TextOverflow.ellipsis,
      ),
    );
  }
}
