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
      print(e);
      body = {'success': 'false', 'msg': e.toString()};
      DemoResponse response = DemoResponse(body.toString(), 500);
      return response;
    }
  }
}
