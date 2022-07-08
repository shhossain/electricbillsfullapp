import 'dart:io';

import 'package:electricbills/api/sign_user.dart';
import 'package:electricbills/env.dart';
import 'package:electricbills/helper/helper_func.dart';
import 'package:electricbills/models/user.dart';
import 'package:electricbills/screens/home.dart';
import 'package:electricbills/screens/loading.dart';
import 'package:electricbills/screens/sign_user.dart';
import 'package:electricbills/widgets/goto.dart';
import 'package:flutter/material.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController usenameController = TextEditingController();

  final TextEditingController passwordController = TextEditingController();

  final TextEditingController housenameController = TextEditingController();

  final TextEditingController roleController = TextEditingController();

  String? warningMsg;
  bool firstTime = true;

  login(context) {
    var usename = usenameController.text;
    var password = passwordController.text;
    var housename = housenameController.text;
    var role = roleController.text;

    User user = User(
        username: usename,
        password: password,
        housename: housename,
        role: role);
    Sign sign = Sign(user: user);
    currentUser = user;
    goto(
        context,
        LoadingPage(
          future: sign.logIn(),
          successPage: HomePage(
            user: user,
          ),
          failurePage: const LoginPage(),
        ));
  }

  Future<bool> isinternet() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        return true;
      }
    } on SocketException catch (_) {
      return false;
    }
    return false;
  }

  checkInternet(BuildContext context) async {
    if (!checkedInternet) {
      checkedInternet = true;
      while (true) {
        if ((await isinternet())) {
          internetAvailable = true;
          return;
        }
        internetAvailable = false;
        showSnackBar(context, 'No Internet Connection',
            duration: 3, icon: Icon(Icons.wifi_off, color: Colors.white));
        await Future.delayed(Duration(seconds: 60));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    checkInternet(context);

    if (firstTime) {
      firstTime = false;
      if (signWaringMsg != null) {
        warningMsg = signWaringMsg;
        signWaringMsg = null;
      }
      if (currentUser != null) {
        var user = currentUser!;
        usenameController.text = user.username;
        passwordController.text = user.password;
        housenameController.text = user.housename;
        roleController.text = user.role;
      }
    }

    return UserSign(
        signType: "Login",
        usenameController: usenameController,
        passwordController: passwordController,
        housenameController: housenameController,
        roleController: roleController,
        warningMsg: warningMsg,
        onPressed: () {
          login(context);
        });
  }
}
