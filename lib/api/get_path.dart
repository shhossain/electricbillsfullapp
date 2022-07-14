// download file
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:package_info_plus/package_info_plus.dart';
// ignore: depend_on_referenced_packages
import "package:path_provider/path_provider.dart";
 

getPath(String path) async {
  Directory appDocDir = await getApplicationDocumentsDirectory();
  PackageInfo packageInfo = await PackageInfo.fromPlatform();

  if (!kIsWeb) {
    if (Platform.isAndroid) {
      var downloadsPath = await getExternalStorageDirectory();
      downloadsPath ??= appDocDir;
    }
  }

  String appName = packageInfo.packageName;
  String filePath = '${appDocDir.path}/$appName';
  await Directory(filePath).create(recursive: true);
  filePath = '$filePath/$path';
  return filePath;
}
