import 'package:electricbills/api/api_details.dart';
import 'package:electricbills/helper/helper_func.dart';
import 'package:electricbills/models/bill.dart';
import 'package:electricbills/api/request.dart';

class User {
  final String username;
  final String? password;
  final String? housename;
  final String? role;
  final String? email;
  final List<Bill>? bills;
  WaterBill? waterBill;
  double? unitPrice;
  double? totalUnit;
  double? previousMonthUnit;
  double? extraUnit;

  get userName => username;
  get passWord => password ?? '';
  get houseName => housename ?? '';
  get roleName => role ?? '';

  User(
      {required this.username,
      this.password,
      this.housename,
      this.role,
      this.email,
      this.bills,
      this.waterBill,
      this.unitPrice,
      this.totalUnit,
      this.previousMonthUnit,
      this.extraUnit});

  Map<String, String> toJson() {
    Map<String, String> result = {};
    result["username"] = username;
    result["password"] = passWord;
    result["housename"] = houseName;
    result["role"] = roleName;
    result["email"] = email ?? "";
    return result;
  }

  factory User.fromWaterBill(WaterBill waterBill) {
    var name = waterBill.name;
    String username = name.split('-')[0];
    String housename = name.split('-')[1];
    return User(
      username: username.toString(),
      housename: housename.toString(),
      waterBill: waterBill,
    );
  }

  factory User.fromJson(Map<String, dynamic> json) {
    WaterBill waterbill = WaterBill.tryFromJson(json["water_bill"]);
    var wbill;
    if (waterbill.year == 0) {
      wbill = null;
    } else {
      wbill = waterbill;
    }

    return User(
      username: json["username"].toString(),
      password: json["password"].toString(),
      housename: json["housename"].toString(),
      role: json["role"].toString(),
      email: json["email"].toString(),
      waterBill: wbill,
    );
  }

  get extraUnits => extraUnit ?? 0;
  get previousMonthUnits => previousMonthUnit ?? 0;
  get totalUnits => totalUnit ?? 0;
  get perUnit => unitPrice ?? 0;
  get monthlyUsedUnits => (totalUnits - previousMonthUnits);
  get totalUsedUnits => (monthlyUsedUnits + extraUnits);
  get totalAmount => totalUsedUnits * perUnit;
  get waterAmount => waterBill?.amount ?? 0;

  double currentUnit() {
    return (totalUnit ?? 0) - (previousMonthUnit ?? 0);
  }

  Bill? getBillDate(String month, String year) {
    if (bills == null) return null;
    if (bills!.isEmpty) return null;
    return bills!.firstWhere(
        (bill) => bill.stringMonth == month && bill.year.toString() == year);
  }

  Future<List<Bill>> getBills() async {
    var body = toJson();
    body['action'] = 'get_bills';
    body['month'] = '1';
    body['year'] = '2020';
    body['day'] = '1';
    String url = "$apiUrl/api/bill/get_bills";
    var response = await requests.post(url: url, body: body);
    var jsonData = jsonDecodeAny(response.body);
    var success = jsonData['success'];
    if (success) {
      var billsData = jsonData['msg'];
      var bills = billsData.map<Bill>((json) => Bill.fromJson(json)).toList();
      return bills;
    }
    return [];
  }
}
