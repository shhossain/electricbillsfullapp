import 'dart:convert';
import 'package:electricbills/helper/error_helper.dart';
import 'package:electricbills/helper/myclasses.dart';
import 'package:http/http.dart' as http;

// ignore: camel_case_types
class requests {
  static get(String url) async {
    return await http.get(Uri.parse(url));
  }

  static post({required String url, required Map<String, String> body}) async {
    try {
      return await http.post(Uri.parse(url), body: body);
    } catch (e) {
      var error = ErrorMessage(e.runtimeType);
      var demoBody = jsonEncode({'success': false, 'msg': error.getMessage()});
      DemoResponse response = DemoResponse(demoBody, 500);
      return response;
    }
  }
}
