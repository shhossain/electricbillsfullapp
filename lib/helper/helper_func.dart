import 'dart:convert';
import 'dart:io';
import 'package:electricbills/constants.dart';
import 'package:electricbills/widgets/texts.dart';
import 'package:flutter/material.dart';
import 'package:open_file/open_file.dart';

double parseDouble(dynamic value) {
  // check with regex if value is a double
  RegExp regex = RegExp(r'^\d+\.\d+$');
  if (regex.hasMatch(value)) {
    return double.parse(value);
  } // chekc with regex if value is an int
  regex = RegExp(r'^\d+$');
  if (regex.hasMatch(value)) {
    return double.parse(value);
  }
  return 0;
}

jsonDecodeAny(dynamic value) {
  try {
    return jsonDecode(value);
  } catch (e) {
    printf('jsonDecodeAny error: $e');
    return {"success": false, "msg": "Something went wrong"};
  }
}

showDouble(double value) {
  return value.toStringAsFixed(2);
}

openFileWindows(String path) async {
  String cmd = '.\$path';
  await Process.run('cmd.exe', ['/c', cmd]);
}

openFlieAndroid(String path) async {
  OpenFile.open(path);
}

openFile(String path) async {
  if (Platform.isWindows) {
    await openFileWindows(path);
  }
  if (Platform.isAndroid) {
    await openFlieAndroid(path);
  }
}

void printf(dynamic value) {
  if (kDebugMode) {
    // ignore: avoid_print
    print(value);
  }
}

Animation<double> snackBarAnimation(BuildContext context) {
  return Tween<double>(begin: 0, end: 1).animate(
    CurvedAnimation(
      parent: CurvedAnimation(
        parent: AnimationController(
          vsync: ScaffoldMessenger.of(context),
          duration: const Duration(milliseconds: 500),
        ),
        curve: Curves.easeIn,
      ),
      curve: Curves.easeIn,
    ),
  );
}

getUniqueId(BuildContext context) {
  // get a unique id from the context
  var key = GlobalKey(debugLabel: context.hashCode.toString());
  return key.currentContext.hashCode.toString();
}

List snackBars = [];

showSnackBar(BuildContext context, String msg,
    {double duration = 1,
    Icon icon = const Icon(
      Icons.check,
      color: Colors.white,
    )}) {
  // convert duration to to milliseconds
  int milliseconds = (duration * 1000).toInt();

  var uniqueId = getUniqueId(context);

  if (!snackBars.contains(uniqueId)) {
    Future.delayed(Duration.zero, () {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          animation: snackBarAnimation(context),
          action: SnackBarAction(
            label: 'Hide',
            onPressed: () {
              ScaffoldMessenger.of(context).hideCurrentSnackBar();
            },
          ),
          content: Row(
            children: [
              SizedBox(
                  width: MediaQuery.of(context).size.width * 0.1, child: icon),
              const SizedBox(width: 10),
              SizedBox(
                width: MediaQuery.of(context).size.width * 0.45,
                child: MyText(
                  text: msg,
                  fontSize: 12,
                ),
              ),
            ],
          ),
          duration: Duration(milliseconds: milliseconds),
        ),
      );
      snackBars.add(uniqueId);
    });
  }
}
