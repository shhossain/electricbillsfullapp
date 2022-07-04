import 'package:electricbills/screens/login.dart';
import 'package:electricbills/widgets/goto.dart';
import 'package:flutter/material.dart';

editorAppBar(BuildContext context, {String? page}) {
  return AppBar(
    elevation: 0,
    backgroundColor: Colors.white,
    surfaceTintColor: Colors.white,
    foregroundColor: Colors.black,
    toolbarHeight: MediaQuery.of(context).size.height * 0.1,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () => Navigator.canPop(context) ? Navigator.pop(context) : null,
      ),
      actions: [
        // refresh button
        IconButton(
          icon: const Icon(Icons.refresh),
          onPressed: () {
            // ignore: invalid_use_of_protected_member
            (context as Element).reassemble();
          },
        ),
        // logout button
        IconButton(
          icon: const Icon(Icons.logout),
          onPressed: () {
            goto(context, const LoginPage());
          },
        ),
      ],
    );
}

AppBar viewAppBar(BuildContext context, {String? page}) {
  return AppBar(
    elevation: 0,
    backgroundColor: Colors.white,
    surfaceTintColor: Colors.white,
    foregroundColor: Colors.black,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () => Navigator.canPop(context) ? Navigator.pop(context) : null,
      ),
      actions: [
        // logout button
        IconButton(
          icon: const Icon(Icons.logout),
          onPressed: () {
            goto(context, const LoginPage());
          },
        ),
      ],
    );
}


bottomAppBar(BuildContext context, {String? page}) {
  return BottomAppBar(
    elevation: 0,
    color: Colors.white,
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.canPop(context) ? Navigator.pop(context) : null,
        ),
        IconButton(
          icon: const Icon(Icons.logout),
          onPressed: () {
            goto(context, const LoginPage());
          },
        ),
      ],
    ),
  );
}

