import 'package:http/http.dart';

class DemoResponse extends Response{
  DemoResponse(String body,int statuscode) : super(body,statuscode);
}