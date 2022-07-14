import 'dart:io';
import 'package:electricbills/api/api_details.dart';
import 'package:electricbills/api/request.dart';
import 'package:electricbills/constants.dart';
import 'package:electricbills/helper/helper_func.dart';
import 'package:electricbills/screens/login.dart';
import 'package:flutter/material.dart';

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}

setApiUrl() async {
  if (!apiUrlSet) return;
  if (!kDebugMode) return;
  var url = "http://sh0338.pythonanywhere.com/latest_url";
  var response = await requests.get(url);
  var json = jsonDecodeAny(response.body);
  if (json['success']) {
    apiUrl = json['url'];
    apiUrlSet = true;
  }
}

main() {
  HttpOverrides.global = MyHttpOverrides();
  // set api url
  setApiUrl();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'My Bill',
      debugShowCheckedModeBanner: false,
      scaffoldMessengerKey: snackbarKey,
      home: const LoginPage(),
    );
  }
}
