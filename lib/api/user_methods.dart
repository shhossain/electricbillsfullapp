import 'package:electricbills/api/api_details.dart';
import 'package:electricbills/api/request.dart';
import 'package:electricbills/helper/helper_func.dart';
import 'package:electricbills/models/bill.dart';
import 'package:electricbills/models/user.dart';


class Users {
  final User user;
  Users({required this.user});
  Map<String, int> months = {
    'January': 1,
    'February': 2,
    'March': 3,
    'April': 4,
    'May': 5,
    'June': 6,
    'July': 7,
    'August': 8,
    'September': 9,
    'October': 10,
    'November': 11,
    'December': 12
  };

  Future<List<User>> getUsers() async {
    if (user.role.toLowerCase() == 'editor') {
      String url = "$apiUrl/api/users";
      var body = user.toJson();
      body['action'] = 'get_users';

      var response = await requests.post(url: url, body: body);
      var jsonData = jsonDecodeAny(response.body);
      var success = jsonData['success'];
      List<User> users = [];
      if (success) {
        var allusers = jsonData['users'];
        allusers.forEach((user) {
          users.add(User.fromJson(user));
        });
      }
      return users;
    }
    return [];
  }

  addUserEditor(User addUser) async {
    Map<String, String> body = {
      'editor_username': user.username,
      'editor_password': user.password,
      'editor_housename': user.housename,
      'add_username': addUser.username,
      'add_password': addUser.password,
      'add_housename': addUser.housename,
      'add_role': addUser.role,
    };

    String url = "$apiUrl/api/user/editor";
    var response = await requests.post(url: url, body: body);
    var jsonData = jsonDecodeAny(response.body);
    var success = jsonData['success'];
    if (success) {
      return [true, jsonData['msg']];
    }
    return [false, jsonData['msg']];
  }

  addUnit(User addUser, String month, int year, int day, double totalAmmount,
      double prevMonthUnit, double usedUnit) async {
    Map<String, String> body = {
      'username': addUser.username,
      'password': addUser.password,
      'housename': addUser.housename,
      'role': addUser.role,
      'month': months[month].toString(),
      'year': year.toString(),
      'day': day.toString(),
      'total_units': addUser.totalUnit.toString(),
      'per_unit': addUser.unitPrice.toString(),
      'total_amount': totalAmmount.toString(),
      'extra_unit': addUser.extraUnit.toString(),
      'editor_username': user.username,
      'editor_password': user.password,
      'editor_housename': user.housename,
      'action': 'add_unit',
    };

    String url = "$apiUrl/api/unit/add";
    var response = await requests.post(url: url, body: body);
    await addBill(
        addUser, month, year, day, totalAmmount, prevMonthUnit, usedUnit);
    var jsonData = jsonDecodeAny(response.body);
    var success = jsonData['success'];
    if (success) {
      return [true, jsonData['msg']];
    }
    return [false, jsonData['msg']];
  }

  getPrevUnit(User addUser, String month, int year, int day) async {
    Map<String, String> body = {
      'username': addUser.username,
      'password': addUser.password,
      'housename': addUser.housename,
      'role': addUser.role,
      'month': months[month].toString(),
      'year': year.toString(),
      'day': day.toString(),
      'editor_username': user.username,
      'editor_password': user.password,
      'editor_housename': user.housename,
      'action': 'prev_units',
    };
    String url = "$apiUrl/api/unit/get";
    var response = await requests.post(url: url, body: body);
    var jsonData = jsonDecodeAny(response.body);
    var success = jsonData['success'];
    if (success) {
      return [true, jsonData['msg']];
    }
    return [false, jsonData['msg']];
  }

  addBill(User addUser, String month, int year, int day, double totalAmmount,
      double prevMonthUnit, double usedUnit) async {
    Map<String, String> body = {
      'username': addUser.username,
      'password': addUser.password,
      'housename': addUser.housename,
      'role': addUser.role,
      'month': months[month].toString(),
      'year': year.toString(),
      'day': day.toString(),
      'total_units': addUser.totalUnit.toString(),
      'per_unit': addUser.unitPrice.toString(),
      'total_amount': totalAmmount.toString(),
      'extra_unit': addUser.extraUnit.toString(),
      'editor_username': user.username,
      'editor_password': user.password,
      'editor_housename': user.housename,
      'prev_month_unit': prevMonthUnit.toString(),
      'used_unit': usedUnit.toString(),
    };
    String url = "$apiUrl/api/bill/add";
    var response = await requests.post(url: url, body: body);
    var jsonData = jsonDecodeAny(response.body);
    var success = jsonData['success'];
    if (success) {
      return [true, jsonData['msg']];
    }
    return [false, jsonData['msg']];
  }

  getUnitDataByDate(User addUser, String month, int year, int day) async {
    Map<String, String> body = {
      'username': addUser.username,
      'password': addUser.password,
      'housename': addUser.housename,
      'role': addUser.role,
      'month': months[month].toString(),
      'year': year.toString(),
      'day': day.toString(),
      'editor_username': user.username,
      'editor_password': user.password,
      'editor_housename': user.housename,
      'action': 'get_units_date',
    };
    String url = "$apiUrl/api/unit/get";
    var response = await requests.post(url: url, body: body);
    var jsonData = jsonDecodeAny(response.body);
    var success = jsonData['success'];
    if (success) {
      return [true, jsonData['msg']];
    }
    return [false, jsonData['msg']];
  }

  Future<List<dynamic>> getBill(
      dynamic month, dynamic year, dynamic day) async {
    var body = user.toJson();
    body['month'] = month.toString();
    body['year'] = year.toString();
    body['day'] = day.toString();

    String url = "$apiUrl/api/bill/get";
    var response = await requests.post(url: url, body: body);
    var jsonData = jsonDecodeAny(response.body);
    var success = jsonData['success'];
    if (success) {
      return [true, Bill.fromJson(jsonData['msg'])];
    }
    return [false, jsonData['msg']];
  }

  Future<List<dynamic>> getBillsDate(String month, String year) async {
    var body = user.toJson();
    body['action'] = 'get_bills_date';
    body['month'] = months[month].toString();
    body['year'] = year;
    body['day'] = '1';
    String url = "$apiUrl/api/bill/get_bills";
    var response = await requests.post(url: url, body: body);
    var jsonData = jsonDecodeAny(response.body);
    var success = jsonData['success'];
    if (success) {
      var billsData = jsonData['msg'];
      var bills = billsData.map<Bill>((json) => Bill.fromJson(json)).toList();
      return [true, bills];
    }
    return [false, jsonData['msg']];
  }

  Future<List<User>> getUsersBill(String month, String year) async {
    List<User> users = await getUsers();
    var billsData = await getBillsDate(month, year);
    List<Bill> bills = billsData[0] ? billsData[1] : [];

    List<User> usersWithBill = [];
    for (var user in users) {
      List<Bill> userBills =
          bills.where((bill) => bill.name.contains(user.username)).toList();
      User newUser = User(
        username: user.username,
        password: user.password,
        housename: user.housename,
        role: user.role,
        totalUnit: user.totalUnit,
        unitPrice: user.unitPrice,
        bills: userBills,
      );
      usersWithBill.add(newUser);
    }
    return usersWithBill;
  }

  deleteUser(User deleteUser) async {
    var body = deleteUser.toJson();
    body['action'] = 'delete_user';
    body['editor_username'] = user.username;
    body['editor_password'] = user.password;
    body['editor_housename'] = user.housename;
    String url = "$apiUrl/api/user/delete";
    var response = await requests.post(url: url, body: body);
    var jsonData = jsonDecodeAny(response.body);
    var success = jsonData['success'];
    if (success) {
      return [true, jsonData['msg']];
    }
    return [false, jsonData['msg']];
  }

  deleteBill(User deleteUser, String month, String year, String day) async {
    var body = deleteUser.toJson();
    body['action'] = 'delete_bill';
    body['month'] = months[month].toString();
    body['year'] = year;
    body['day'] = day;
    body['editor_username'] = user.username;
    body['editor_password'] = user.password;
    body['editor_housename'] = user.housename;
    String url = "$apiUrl/api/bill/delete";
    var response = await requests.post(url: url, body: body);
    var jsonData = jsonDecodeAny(response.body);
    var success = jsonData['success'];
    if (success) {
      return [true, jsonData['msg']];
    }
    return [false, jsonData['msg']];
  }

  editBill(User editUser, int month, String year, String day) async {
    Map<String, String> body = {
      'username': editUser.username,
      'password': editUser.password,
      'housename': editUser.housename,
      'role': editUser.role,
      'month': month.toString(),
      'year': year.toString(),
      'day': day.toString(),
      'total_units': editUser.totalUnit.toString(),
      'per_unit': editUser.unitPrice.toString(),
      'total_amount': editUser.totalAmount.toString(),
      'extra_unit': editUser.extraUnit.toString(),
      'editor_username': user.username,
      'editor_password': user.password,
      'editor_housename': user.housename,
      'prev_month_unit': editUser.previousMonthUnit.toString(),
      'used_unit': editUser.monthlyUsedUnits.toString(),
    };
    String url = "$apiUrl/api/bill/edit";
    var response = await requests.post(url: url, body: body);
    var jsonData = jsonDecodeAny(response.body);
    var success = jsonData['success'];
    if (success) {
      return [true, jsonData['msg']];
    }
    return [false, jsonData['msg']];
  }

// def water(username,password,housename,year,month,amount,action):
//     if action == 'add_water':
//         waterdata:WaterBill = WaterBill(WATERDATA_PATH)
//         waterdata.add_bill(username=username, housename=housename, year=year, month=month, amount=amount)
//         return jsonify({'success': True, 'msg': 'Water added successfully'})
//     elif action == 'get_bills':
//         data = waterdata.get_bills(username, housename)
//         # custom_print('/api/water/get_waters data: ', data,color='blue')
//         return jsonify({'success': True, 'msg': data})
//     elif action == 'get_bill':
//         data = waterdata.get_bill(username, housename, year, month)
//         # custom_print('/api/water/get_bill data: ', data,color='blue')
//         return jsonify({'success': True, 'msg': data})
//     elif action == 'get_biils_date':
//         data = waterdata.get_bills_date(housename, month, year)
//         # custom_print('/api/water/get_bills_data data: ', data,color='blue')
//         return jsonify({'success': True, 'msg': data})
//     elif action == 'delete_bill':
//         waterdata.delete_bill(username=username, housename=housename, year=year, month=month)
//         return jsonify({'success': True, 'msg': 'Water deleted successfully'})
//     elif action == 'edit_bill':
//         waterdata.edit_bill(username=username, housename=housename, year=year, month=month, amount=amount)
//         return jsonify({'success': True, 'msg': 'Water edited successfully'})

  addWaterBill(
      User addUser, String month, String year, double totalAmmount) async {
    Map<String, String> body = {
      'username': addUser.username,
      'password': addUser.password,
      'housename': addUser.housename,
      'role': addUser.role,
      'month': months[month].toString(),
      'year': year.toString(),
      'amount': totalAmmount.toString(),
      'editor_username': user.username,
      'editor_password': user.password,
      'editor_housename': user.housename,
    };
    String url = "$apiUrl/api/water/add_water";
    var response = await requests.post(url: url, body: body);
    var jsonData = jsonDecodeAny(response.body);
    var success = jsonData['success'];
    if (success) {
      return [true, jsonData['msg']];
    }
    return [false, jsonData['msg']];
  }

  editWaterBill(User editUser, String month, int year, int day,
      double totalAmmount, double prevMonthUnit, double usedUnit) async {
    Map<String, String> body = {
      'username': editUser.username,
      'password': editUser.password,
      'housename': editUser.housename,
      'role': editUser.role,
      'month': months[month].toString(),
      'year': year.toString(),
      'amount': totalAmmount.toString(),
      'editor_username': user.username,
      'editor_password': user.password,
      'editor_housename': user.housename,
    };
    String url = "$apiUrl/api/water/edit_bill";
    var response = await requests.post(url: url, body: body);
    var jsonData = jsonDecodeAny(response.body);
    var success = jsonData['success'];
    if (success) {
      return [true, jsonData['msg']];
    }
    return [false, jsonData['msg']];
  }

  deleteWaterBill(User deleteUser, String month, int year) async {
    Map<String, String> body = {
      'username': deleteUser.username,
      'password': deleteUser.password,
      'housename': deleteUser.housename,
      'role': deleteUser.role,
      'month': months[month].toString(),
      'year': year.toString(),
      'editor_username': user.username,
      'editor_password': user.password,
      'editor_housename': user.housename,
    };
    String url = "$apiUrl/api/water/delete_bill";
    var response = await requests.post(url: url, body: body);
    var jsonData = jsonDecodeAny(response.body);
    var success = jsonData['success'];
    if (success) {
      return [true, jsonData['msg']];
    }
    return [false, jsonData['msg']];
  }

  getWaterBill(User getUser, String month, String year) async {
    Map<String, String> body = {
      'username': getUser.username,
      'password': getUser.password,
      'housename': getUser.housename,
      'role': getUser.role,
      'month': months[month].toString(),
      'year': year.toString(),
      'editor_username': user.username,
      'editor_password': user.password,
      'editor_housename': user.housename,
    };
    String url = "$apiUrl/api/water/get_bill";
    var response = await requests.post(url: url, body: body);
    var jsonData = jsonDecodeAny(response.body);
    var success = jsonData['success'];
    if (success) {
      return [true, jsonData['msg']];
    }
    return [false, jsonData['msg']];
  }

  getWaterBills(User getUser) async {
    Map<String, String> body = {
      'username': getUser.username,
      'password': getUser.password,
      'housename': getUser.housename,
      'role': getUser.role,
      'editor_username': user.username,
      'editor_password': user.password,
      'editor_housename': user.housename,
    };
    String url = "$apiUrl/api/water/get_bills";
    var response = await requests.post(url: url, body: body);
    var jsonData = jsonDecodeAny(response.body);
    var success = jsonData['success'];
    if (success) {
      return [true, jsonData['msg']];
    }
    return [false, jsonData['msg']];
  }

  getWaterBillsDate(User getUser, String month, String year) async {
    Map<String, String> body = {
      'username': getUser.username,
      'password': getUser.password,
      'housename': getUser.housename,
      'role': getUser.role,
      'month': months[month].toString(),
      'year': year.toString(),
      'editor_username': user.username,
      'editor_password': user.password,
      'editor_housename': user.housename,
    };
    String url = "$apiUrl/api/water/get_bill_date";
    var response = await requests.post(url: url, body: body);
    var jsonData = jsonDecodeAny(response.body);
    var success = jsonData['success'];
    if (success) {
      return [true, jsonData['msg']];
    }
    return [false, jsonData['msg']];
  }

  Future<List<User>> getUsersWaterBillsDate(String month, String year) async {
    List<User> users = await getUsers();
    for (var user in users) {
      var result = await getWaterBillsDate(user, month, year);
      if (result[0]) {
        WaterBill waterBill = WaterBill.fromJson(result[1]);
        user.waterBill = waterBill;
      }
    }
    return users;
  }

  totalWaterBill(String month, String year) async {
    var body = user.toJson();
    body['month'] = months[month].toString();
    body['year'] = year.toString();
    body['editor_username'] = user.username;
    body['editor_password'] = user.password;
    body['editor_housename'] = user.housename;

    String url = "$apiUrl/api/water/total_bill";
    var response = await requests.post(url: url, body: body);
    var jsonData = jsonDecodeAny(response.body);
    var success = jsonData['success'];
    if (success) {
      return [true, jsonData['msg']];
    }
    return [false, jsonData['msg']];
  }

  AddWaterBillFromTotal(String month, String year, double totalAmmount) async {
    List<User> users = await getUsers();
    double perUserAmmount = totalAmmount / users.length;
    var successUsers = [];
    var failedUsers = [];
    var success = false;
    for (var user in users) {
      var result = await addWaterBill(user, month, year, perUserAmmount);
      if (!result[0]) {
        failedUsers.add(user);
        success = false;
      } else {
        successUsers.add(user);
        success = true;
      }
    }
    var msg = "";
    if (success) {
      msg = "${successUsers.length} Bills Changed";
    } else {
      msg = "${failedUsers.length} Biils Failed";
    }
    return [success, msg];
  }


  getWaterBillForView(String month, String year){
    var body = user.toJson();
    body['month'] = months[month].toString();
    body['year'] = year.toString();

    String url = "$apiUrl/api/water/get_water_bill/one";
    var response = requests.post(url: url, body: body);
    var jsonData = jsonDecodeAny(response.body);
    var success = jsonData['success'];
    if (success) {
      return [true, jsonData['msg']];
    }
    return [false, jsonData['msg']];
  }

  getWaterBillForViewAll(){
    var body = user.toJson();
    body['month'] = months[0].toString();
    body['year'] = '2000';

    String url = "$apiUrl/api/water/get_water_bill/all";
    var response = requests.post(url: url, body: body);
    var jsonData = jsonDecodeAny(response.body);
    var success = jsonData['success'];
    if (success) {
      return [true, jsonData['msg']];
    }
    return [false, jsonData['msg']];
  }
}
