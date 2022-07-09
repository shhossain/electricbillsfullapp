import 'package:electricbills/env.dart';
import 'package:electricbills/helper/helper_func.dart';
import 'package:flutter/material.dart';

class LoadingPage extends StatelessWidget {
  final dynamic future;
  final dynamic successPage;
  final dynamic failurePage;

  const LoadingPage({
    Key? key,
    required this.future,
    required this.successPage,
    required this.failurePage,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: future,
        builder: (builder, snapshot) {
          ConnectionState connectionState = snapshot.connectionState;
          String msg = '';
          if (connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(
                child: CircularProgressIndicator(),
              ),
            );
          } else if (connectionState == ConnectionState.done) {
            if (snapshot.hasData) {
              var data = snapshot.data as List;
              if (data[0]) {
                msg = data[1];
                showSnackBar(context, msg,icon: Icon(Icons.check,color: Colors.green.shade400,));
                return successPage;
              } else {
                msg = data[1];
                signWaringMsg = data[1];
                addUserWaringMsg = data[1];
                showSnackBar(context, msg,icon: Icon(Icons.error,color: Colors.red.shade400,));
                return failurePage;
              }
            } else {
              return failurePage;
            }
          } else {
            return failurePage;
          }
        });
  }
}
