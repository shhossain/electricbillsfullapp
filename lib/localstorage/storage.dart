// create local storage in flutter
import 'dart:convert';

import 'package:electricbills/models/user.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Storage {
  static saveUser(String key, User user) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString(key, jsonEncode(user.toJson()));
  }

  static getUser(String key) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var user = prefs.getString(key);
    if (user != null) {
      return User.fromJson(jsonDecode(user));
    }
    return null;
  }
}
