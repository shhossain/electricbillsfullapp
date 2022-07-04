import 'package:electricbills/api/sign_user.dart';
import 'package:electricbills/env.dart';
import 'package:electricbills/models/user.dart';
import 'package:electricbills/screens/home.dart';
import 'package:electricbills/screens/loading.dart';
import 'package:electricbills/screens/sign_user.dart';
import 'package:electricbills/widgets/goto.dart';
import 'package:flutter/material.dart';

class RegistrationPage extends StatefulWidget {
  const RegistrationPage({Key? key}) : super(key: key);

  @override
  State<RegistrationPage> createState() => _RegistrationPageState();
}

class _RegistrationPageState extends State<RegistrationPage> {
  final usenameController = TextEditingController();
  final passwordController = TextEditingController();
  final housenameController = TextEditingController();
  final roleController = TextEditingController();
  final emailController = TextEditingController();

  String? warningMsg;
  bool firstTime = true;

  signUp() {
    var usename = usenameController.text;
    var password = passwordController.text;
    var housename = housenameController.text;
    var role = roleController.text;
    var email = emailController.text;
    if (usename.isEmpty ||
        password.isEmpty ||
        housename.isEmpty ||
        role.isEmpty ||
        email.isEmpty) {
      setState(() {
        warningMsg =
            "Please enter ${usename.isEmpty ? 'username, ' : ''}${password.isEmpty ? 'password, ' : ''}${housename.isEmpty ? 'housename, ' : ''}${role.isEmpty ? 'role, ' : ''} ${email.isEmpty ? 'email' : ''}";
      });
      return;
    } else if (usename.length < 4 || password.length < 4) {
      setState(() {
        warningMsg = "Username and password must be at least 4 characters long";
      });
      return;
    } else if (housename.length < 3) {
      setState(() {
        warningMsg = "Housename must be at least 3 characters long";
      });
      return;
    } else if (usename.length > 5 || password.length > 5) {
      // check if username contains only numbers
      if (usename.contains(RegExp(r'^[0-9]+$'))) {
        setState(() {
          warningMsg = "Username must not contain only numbers";
        });
        return;
      }
    } else {
      setState(() {
        warningMsg = null;
      });
    }

    User user = User(
        username: usename,
        password: password,
        housename: housename,
        role: role,
        email: email);
    Sign sign = Sign(user: user);
    currentUser = user;
    goto(
        context,
        LoadingPage(
          future: sign.signUp(),
          successPage: HomePage(
            user: user,
          ),
          failurePage: RegistrationPage(),
        ));
  }

  

  @override
  Widget build(BuildContext context) {
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
        emailController.text = user.email ?? "";
      }
    }

    return UserSign(
      signType: "Registration",
      usenameController: usenameController,
      passwordController: passwordController,
      housenameController: housenameController,
      roleController: roleController,
      emailController: emailController,
      onPressed: () {
        signUp();
      },
      warningMsg: warningMsg,
    );
  }
}
