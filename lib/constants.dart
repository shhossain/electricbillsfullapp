import 'package:flutter/material.dart';

bool kDebugMode = false;
double kDefaultPadding = 16;
final GlobalKey<ScaffoldMessengerState> snackbarKey =
    GlobalKey<ScaffoldMessengerState>();
List<BuildContext> storeContext = [];


bool apiUrlSet = false;