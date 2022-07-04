import 'package:electricbills/api/api_details.dart';
import 'package:electricbills/api/request.dart';
import 'package:electricbills/helper/helper_func.dart';
import 'package:electricbills/localstorage/storage.dart';
import 'package:electricbills/models/user.dart';
import 'package:http/http.dart';

class Sign {
  final User user;

  Sign({required this.user});

  Future<List> logIn() async {
    var body = user.toJson();
    var url = "$apiUrl/api/user";
    Response res = await requests.post(url: url, body: body);
    if (res.statusCode == 200) {
      var response = jsonDecodeAny(res.body);
      var success = response["success"];
      Storage.saveUser('savedUser', user);
      if (success) {
        printf('login savedUser: ${user.username}');
        return [true, response['msg'], user];
      } else {
        return [false, response['msg'], user];
      }
    }
    return [false, '', user];
  }

  Future<List> signUp() async {
    var body = user.toJson();
    var url = "$apiUrl/api/user/add";
    Response res = await requests.post(url: url, body: body);
    var response = jsonDecodeAny(res.body);
    var success = response["success"];
    Storage.saveUser('savedUser', user);
    if (res.statusCode == 200) {
      if (success) {
        return [true, response['msg'], user];
      } else {
        return [false, response['msg'], user];
      }
    }
    return [false, '', user];
  }
}
