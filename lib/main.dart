import 'dart:io';

import 'package:electricbills/screens/login.dart';
import 'package:flutter/material.dart';

bool kDebugMode = false;

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}

main() {
  HttpOverrides.global = MyHttpOverrides();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Electric Bills',
      debugShowCheckedModeBanner: false,
      home: LoginPage(),
    );
  }
}
