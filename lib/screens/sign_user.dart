import 'dart:io';
import 'package:electricbills/api/api_details.dart';
import 'package:electricbills/api/get_path.dart';
import 'package:electricbills/api/request.dart';
import 'package:electricbills/env.dart';
import 'package:electricbills/helper/helper_func.dart';
import 'package:electricbills/localstorage/storage.dart';
import 'package:electricbills/models/user.dart';
import 'package:electricbills/screens/login.dart';
import 'package:electricbills/screens/registration.dart';
import 'package:electricbills/widgets/buttons.dart';
import 'package:electricbills/widgets/download.dart';
import 'package:electricbills/widgets/goto.dart';
import 'package:electricbills/widgets/rounded_box.dart';
import 'package:electricbills/widgets/text_field.dart';
import 'package:electricbills/widgets/texts.dart';
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class UserSign extends StatefulWidget {
  final TextEditingController usenameController;
  final TextEditingController passwordController;
  final TextEditingController housenameController;
  final TextEditingController roleController;
  final TextEditingController? emailController;
  final String signType;
  final Function()? onPressed;
  final String? warningMsg;

  const UserSign(
      {Key? key,
      required this.signType,
      required this.usenameController,
      required this.passwordController,
      required this.housenameController,
      required this.roleController,
      required this.onPressed,
      this.emailController,
      this.warningMsg})
      : super(key: key);

  @override
  State<UserSign> createState() => _UserSignState();
}

class _UserSignState extends State<UserSign> {
  bool passwordVisible = false;
  bool addEmail = true;
  String? warningMsg;
  String? roleValue;

  bool vaildEmail(String email) {
    return RegExp(
            r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
        .hasMatch(email);
  }

  @override
  void initState() {
    super.initState();
    warningMsg = widget.warningMsg;
    roleValue = 'Role';
    setSaveUser();
  }

  @override
  void dispose() {
    super.dispose();
    signWaringMsg = null;
    currentUser = null;
    currentAddUser = null;
    addUserWaringMsg = null;

    widget.usenameController.clear();
    widget.passwordController.clear();
    widget.housenameController.clear();
    widget.roleController.clear();
    widget.emailController?.clear();
  }

  checkForUpdates(BuildContext context) async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    // get os
    String os = Platform.operatingSystem;
    var version = packageInfo.version;
    var body = {'current_version': version, 'os': os};
    String url = "$apiUrl/api/update";
    var response = await requests.post(url: url, body: body);
    var jsonData = jsonDecodeAny(response.body);
    var success = jsonData['success'];
    if (success) {
      var updateAvailable = jsonData['updateAvailable'];
      var version = jsonData['latestVersion'];
      var ignoreAble = jsonData['ignoreAble'];
      if (updateAvailable) {
        showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                title: Text('New version available'),
                content: Text('New version $version is available'),
                actions: <Widget>[
                  MyTextButton(
                    label: Text('Update'),
                    onPressed: () async {
                      await installApp(context);
                    },
                  ),
                  MyTextButton(
                    label: ignoreAble ? Text('Cancel') : Text('Close'),
                    onPressed: () {
                      if (ignoreAble) {
                        Navigator.of(context).pop();
                      } else {
                        exit(0);
                      }
                    },
                  ),
                ],
              );
            });
      }
    }
    else {
      showSnackBar(context, jsonData['msg']);
    }
  }

  installApp(BuildContext context) async {
    String url = "$apiUrl/api/download/";
    String fileName = '';
    if (Platform.isAndroid) {
      url += 'apk';
      fileName = 'app.apk';
    } else if (Platform.isIOS) {
      url += 'ios';
      fileName = 'app.ipa';
    } else {
      url += 'exe';
      fileName = 'app.exe';
    }
    String path = await getPath(fileName);
    if (await Permission.storage.request().isGranted) {
      showDialog(
          context: context,
          builder: (context) {
            return DownloadFile(url: url, filePath: path);
          });

    } else {
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Permission denied'),
            content: Text('Please grant storage permission'),
            actions: <Widget>[
              MyTextButton(
                label: Text('Close'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    }
  }

  setSaveUser() async {
    var savedUser = await Storage.getUser('savedUser');
    if (savedUser != null) {
      User saveUser = savedUser;
      widget.usenameController.text = saveUser.username;
      widget.passwordController.text = saveUser.passWord;
      widget.housenameController.text = saveUser.houseName;

      if (saveUser.email != null) {
        if (widget.emailController != null) {
          widget.emailController!.text = saveUser.email!;
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!kIsWeb) {
      checkForUpdates(context);
    }

    return Scaffold(
        body: Container(
      decoration: BoxDecoration(
          gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
            Colors.black.withOpacity(0.3),
            Colors.black.withOpacity(0.1)
          ])),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          // crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: MyText(
                text: widget.signType,
                fontSize: 30,
                fontFamily: 'Poppins',
              ),
            ),
            // warning message
            warningMsg != null
                ? MyText(
                    text: warningMsg!,
                    fontSize: 10,
                    fontFamily: 'Poppins',
                    backgroundColor: Colors.red.withOpacity(0.5),
                    fontWeight: FontWeight.bold,
                  )
                : Container(),
            SizedBox(height: widget.warningMsg != null ? 10 : 30),
            MyTextField(
                name: "Username",
                icon: Icons.person,
                controller: widget.usenameController,
                onChanged: (value) {
                  if (widget.emailController != null) {
                    if (addEmail) {
                      widget.emailController!.text =
                          "${widget.usenameController.text.replaceAll(' ', '')}@gmail.com";
                      widget.emailController!.text =
                          widget.emailController!.text.toLowerCase();
                    }
                    if (widget.usenameController.text.isEmpty) {
                      widget.emailController!.text = "";
                    }
                  }
                }),
            const SizedBox(height: 20),
            MyTextField(
              name: "Password",
              icon: Icons.password,
              controller: widget.passwordController,
              obscureText: !passwordVisible,
              suffix: IconButton(
                icon: Icon(
                  passwordVisible ? Icons.visibility : Icons.visibility_off,
                  color: Colors.black,
                  size: 20,
                ),
                onPressed: () {
                  setState(() {
                    passwordVisible = !passwordVisible;
                  });
                },
              ),
            ),
            const SizedBox(height: 20),
            MyTextField(
              name: "House name",
              icon: Icons.home,
              controller: widget.housenameController,
            ),
            const SizedBox(height: 20),
            widget.emailController != null
                ? Column(
                    children: [
                      MyTextField(
                        name: "Email",
                        icon: Icons.email,
                        controller: widget.emailController!,
                        onChanged: (value) {
                          addEmail = false;
                          var text = widget.emailController!.text;
                          if (text.contains(" ")) {
                            text = text.replaceAll(" ", "");
                            widget.emailController!.text = text;
                            widget.emailController!.selection =
                                TextSelection.fromPosition(
                                    TextPosition(offset: text.length));
                          }
                        },
                      ),
                      const SizedBox(height: 20),
                    ],
                  )
                : Container(),
            SizedBox(
              height: 47,
              child: MyDropDownButton(
                items: widget.signType.toLowerCase().startsWith("log")
                    ? ['Viewer', 'Editor']
                    : ['Editor', 'Viewer'],
                color: Colors.white,
                controller: widget.roleController,
              ),
            ),
            const SizedBox(height: 5),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                MyText(
                  text:
                      "${widget.signType.toLowerCase().startsWith('log') ? 'Don\'t' : 'Already'} have an account? ",
                  fontSize: 15,
                  fontFamily: 'Lato',
                ),
                Hero(
                  tag: "log-reg",
                  child: MyTextButton(
                    label: MyText(
                      text: widget.signType.toLowerCase().startsWith("log")
                          ? "Sign up"
                          : "Log in",
                      fontSize: 15,
                      fontFamily: 'Lato',
                      fontWeight: FontWeight.bold,
                    ),
                    backgroundColor: Colors.white70.withOpacity(0.2),
                    foregroundColor: Colors.blueAccent.shade100,
                    onPressed: () => goto(
                        context,
                        widget.signType.toLowerCase().startsWith("reg")
                            ? LoginPage()
                            : RegistrationPage()),
                  ),
                )
              ],
            ),
            const SizedBox(height: 50),
            RounderBox(
              borderRadius: 100,
              child: MyTextButton(
                onPressed: () {
                  // chek for valid email
                  if (widget.emailController != null) {
                    // warningMsg = "";
                    if (!vaildEmail(widget.emailController!.text)) {
                      setState(() {
                        warningMsg = "Invalid email";
                      });
                      return;
                    }
                  }
                  if (widget.onPressed != null) {
                    widget.onPressed!();
                  }
                },
                label: MyText(
                  text: widget.signType,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  fontFamily: "Open Sans",
                ),
                width: MediaQuery.of(context).size.width * 0.8,
                height: 40,
                backgroundColor: Colors.white70,
                foregroundColor: Colors.black,
              ),
            )
          ],
        ),
      ),
    ));
  }
}
