import 'package:electricbills/api/sign_user.dart';
import 'package:electricbills/api/user_methods.dart';
import 'package:electricbills/models/user.dart';
import 'package:flutter_test/flutter_test.dart';

testPrint(String testname, dynamic value) {
  print('$testname: $value');
}

void main() async {
  User euser = User(
    username: 'Test User',
    password: 'Test Password',
    housename: 'Test House',
    role: 'Editor',
    email: 'test@test.com',
  );
  int failed = 0;
  Sign sign = Sign(user: euser);

  // test 1

  var res = await sign.logIn();
  testPrint('Test 1. LogIn response', res);
  if (!res[0]) {
    failed++;
  }

  res = await sign.signUp();
  testPrint('Test 1. SignUp response', res);

  if (!res[0]) {
    failed++;
  }

  test('Test 1. Sign In/Up', () {
    expect(failed, 1);
  });

  // test 2 - Log in with wrong password
  var euser2 = User(
    username: 'Test User',
    password: 'Wrong Password',
    housename: 'Test House',
    role: 'Editor',
    email: 'test@test.com',
  );
  int failed2 = 0;
  sign = Sign(user: euser2);
  res = await sign.logIn();
  testPrint('Test 2. LogIn wrong password res', res);
  if (res[0]) {
    failed2++;
  }

  test("Test 2. Login With Wrong Pssword", () {
    expect(failed2, 0);
  });

  // tests user methods
  User testUser1 = User(
    username: 'Test User 1',
    password: 'Test Password 1',
    housename: 'Test House 1',
    role: 'Editor',
    email: 'test1@text.com',
  );
  User testUser2 = User(
      username: 'Test User 2',
      password: 'Test Password 2',
      housename: 'Test House 2',
      role: 'Editor',
      email: 'test2@text.com');

  // test 3 - Add user
  Users users = Users(user: euser);
  res = await users.addUserEditor(testUser1);
  testPrint('Test 3. AddUser res', res);

  int failed3 = 0;

  if (!res[0]) {
    failed3++;
  }

  // check if user is added
  var res2 = await users.getUsers();
  testPrint('Test 3. GetUsers res', res2[0].username);

  var allusers = res2;
  if (allusers.isEmpty) {
    failed3++;
  }

  test('Test 3. Get Users', () {
    expect(failed3, lessThan(2));
  });

  // test 4 - check if user can log in
  var sign2 = Sign(user: testUser1);
  res = await sign2.logIn();
  testPrint('Test 4. AddUser LogIn res', res);
  int failed4 = 0;

  if (!res[0]) {
    failed4++;
  }

  test('Test 4. AddUser Log In', () {
    expect(failed4, 0);
  });

  // test 5 add unit check
  // addUnit(User addUser, String month, int year, int day, double totalAmmount,
  //     double prevMonthUnit, double usedUnit)
  int year = 2020, day = 1;
  String month = 'January';
  double prevMonthUnit = 50.0;
  double totalUnit = 100.0;
  double unitPrice = 7;
  double extraUnit = 0;
  double usedUnit = totalUnit - prevMonthUnit;
  double totalAmount = usedUnit * unitPrice;
  User addUser = testUser1;
  addUser.totalUnit = totalUnit;
  addUser.unitPrice = unitPrice;
  addUser.extraUnit = extraUnit;
  res = await users.addUnit(
      addUser, month, year, day, totalAmount, prevMonthUnit, usedUnit);
  testPrint('Test 5. AddUnit res', res);
  int failed5 = 0;

  if (!res[0]) {
    failed5++;
  }

  // check if unit is added
  res = await users.getUnitDataByDate(addUser, month, year, day);
  testPrint('Test 5. GetUnitDataByDate res', res);
  if (!res[0]) {
    failed5++;
  }

  if (res[1][0]['total_unit'] != totalUnit) {
    failed5++;
  }

  test('Test 5. AddUnit', () {
    expect(failed5, 0);
  });

  // test 6 - check previous month unit
  month = 'February';
  res = await users.getPrevUnit(addUser, month, year, day);
  testPrint('Test 6. GetPrevUnit res', res);
  int failed6 = 0;

  if (res[1] != totalUnit) {
    failed6++;
  }

  test('Test 6. GetPrevUnit', () {
    expect(failed6, 0);
  });
}
