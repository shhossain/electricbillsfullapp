import 'package:electricbills/models/user.dart';
import 'package:electricbills/screens/editor_page.dart';
import 'package:electricbills/screens/viewer_page.dart';
import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  final User user;

  const HomePage({Key? key, required this.user}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return user.roleName.toLowerCase() == 'editor'
        ? EditorPage(
            user: user,
          )
        : ViewerPage(
            user: user,
          );
  }
}




