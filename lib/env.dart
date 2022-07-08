import 'package:electricbills/models/user.dart';
import 'package:flutter/cupertino.dart';

String? signWaringMsg;
User? currentUser;
User? currentAddUser;
String? addUserWaringMsg;
double? savedUnitPrice;
double? saveExtraUnits;
String? saveMonth;
String? saveYear;

Map<dynamic, BuildContext> recentPages = {};
List<dynamic> recentPagesList = [];
bool checkedInternet = false;
bool internetAvailable = false;
