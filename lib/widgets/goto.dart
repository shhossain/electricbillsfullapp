import 'package:flutter/material.dart';

goto(BuildContext context, dynamic page,{replace = false}) {
  if (replace) {
    return Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => page));
  }
  return Navigator.of(context).push(MaterialPageRoute(builder: (context) => page));
}
