import 'package:electricbills/helper/helper_func.dart';
import 'package:http/http.dart' as http;

// ignore: camel_case_types
class requests{
  static get(String url) async {
    return await http.get(Uri.parse(url));
  }

  static post ({required String url,required Map<String,String> body}) async{
    printf('url: $url, body: $body');
    return await http.post(Uri.parse(url),body: body);
  }
}