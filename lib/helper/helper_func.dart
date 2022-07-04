import 'dart:convert';
import 'dart:io';
import 'package:electricbills/main.dart';
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

openFile(String path) async{
  if (Platform.isWindows) {
    await openFileWindows(path);
  }
  if (Platform.isAndroid) {
    await openFlieAndroid(path);
  }
  
}

void printf(dynamic value) {
  if (kDebugMode) {
    print(value);
  }
}