// download file
import 'dart:io';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path_provider/path_provider.dart';

getPath(String path) async {
  Directory appDocDir = await getApplicationDocumentsDirectory();
  PackageInfo packageInfo = await PackageInfo.fromPlatform();
  String appName = packageInfo.packageName;
  String filePath = '${appDocDir.path}/$appName';
  await Directory(filePath).create(recursive: true);
  filePath = '$filePath/$path';
  return filePath;
}
