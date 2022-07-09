import 'package:electricbills/api/user_methods.dart';
import 'package:electricbills/constants.dart';
import 'package:electricbills/env.dart';
import 'package:electricbills/helper/helper_func.dart';
import 'package:electricbills/models/bill.dart';
import 'package:electricbills/models/date.dart';
import 'package:electricbills/models/user.dart';
import 'package:electricbills/widgets/appbar.dart';
import 'package:electricbills/widgets/buttons.dart';
import 'package:electricbills/widgets/goto.dart';
import 'package:electricbills/widgets/rounded_box.dart';
import 'package:electricbills/widgets/text_field.dart';
import 'package:electricbills/widgets/texts.dart';
import 'package:flutter/material.dart';

class ShowWaterBill extends StatelessWidget {
  final User user;
  final String month;
  final String year;
  const ShowWaterBill(
      {Key? key, required this.user, required this.month, required this.year})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    Users users = Users(user: user);
    return FutureBuilder(
      future: users.getUsersWaterBillsDate(month, year),
      builder: (context, AsyncSnapshot<List<User>> snapshot) {
        ConnectionState connectionState = snapshot.connectionState;
        if (connectionState == ConnectionState.waiting) {
          return Center(
            child: CircularProgressIndicator(),
          );
        } else if (connectionState == ConnectionState.done) {
          List<User> users = snapshot.data!;
          return UserWaterBills(
            editUser: user,
            users: users,
            month: month,
            year: year,
          );
        } else {
          return Center(
            child: Text('Error'),
          );
        }
      },
    );
  }
}

class UserWaterBills extends StatefulWidget {
  const UserWaterBills({
    Key? key,
    required this.users,
    required this.editUser,
    required this.month,
    required this.year,
  }) : super(key: key);

  final List<User> users;
  final User editUser;
  final String month;
  final String year;

  @override
  State<UserWaterBills> createState() => _UserWaterBillsState();
}

class _UserWaterBillsState extends State<UserWaterBills> {
  String? totalBill;
  final TextEditingController _totalBillController = TextEditingController();
  bool edit = false;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    setTotalBill();
  }

  setTotalBill() async {
    Users users = Users(user: widget.editUser);
    var res = await users.totalWaterBill(widget.month, widget.year);
    setState(() {
      if (res[0]) {
        totalBill = res[1];
      } else {
        totalBill = '0';
      }
    });
    _totalBillController.text = parseDouble(totalBill).toStringAsFixed(2);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            MyText(
              text: 'Total',
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Padding(
                  padding: EdgeInsets.only(bottom: !edit ? 0 : 8),
                  child: AnimatedContainer(
                    duration: Duration(milliseconds: 500),
                    width: !edit ? 80 : 120,
                    height: 20,
                    // remove border
                    child: edit
                        ? TextField(
                            autofocus: true,
                            decoration: InputDecoration(
                              border: InputBorder.none,
                              enabled: edit,
                            ),
                            controller: _totalBillController,
                          )
                        : MyText(
                            text: _totalBillController.text,
                          ),
                  ),
                ),
                !isLoading
                    ? IconButton(
                        icon: Icon(
                          !edit ? Icons.edit_outlined : Icons.check_outlined,
                          size: 20,
                        ),
                        onPressed: () async {
                          if (edit) {
                            double total =
                                parseDouble(_totalBillController.text);

                            if (total == totalBill) {
                              return;
                            }
                            print('total: $total totalBill: $totalBill');

                            Users users = Users(user: widget.editUser);
                            String month = widget.month;
                            String year = widget.year;

                            setState(() {
                              isLoading = true;
                            });

                            var res = await users.AddWaterBillFromTotal(
                                month, year, total);
                            bool success = res[0];
                            showSnackBar(context, res[1],
                                icon: Icon(
                                    success
                                        ? Icons.check_circle_outline
                                        : Icons.error_outline,
                                    color:
                                        success ? Colors.green : Colors.red));

                            setState(() {
                              isLoading = false;
                            });
                          }
                          setState(() {
                            edit = !edit;
                          });
                        },
                      )
                    : CircularProgressIndicator(),
              ],
            ),
          ],
        ),
        SizedBox(
          height: 10,
        ),
        Expanded(
          child: Padding(
            padding: EdgeInsets.only(
                left: kDefaultPadding / 2, right: kDefaultPadding / 2),
            child: Hero(
              tag: 'userList',
              child: ListView.builder(
                itemCount: widget.users.length,
                itemBuilder: (context, index) {
                  // sort users by wateramount
                  List<User> users = widget.users;
                  users.sort((a, b) => b.waterAmount.compareTo(a.waterAmount));
                  User cuser = users[index];
                  return Padding(
                    padding: EdgeInsets.only(bottom: kDefaultPadding / 4),
                    child: RounderBox(
                      color: Colors.white,
                      child: MyTextButton(
                        backgroundColor: Colors.black.withOpacity(0.1),
                        onPressed: () => goto(
                            context,
                            ViewUserWaterBill(
                                user: cuser,
                                editorUser: widget.editUser,
                                month: widget.month,
                                year: widget.year)),
                        label: ListTile(
                          title: Text(cuser.username),
                          // subtitle: Text(cuser.role),
                          trailing: Text(
                              cuser.waterBill?.amount.toStringAsFixed(2) ??
                                  '0'),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class ViewUserWaterBill extends StatelessWidget {
  final User user;
  final User editorUser;
  final String month;
  final String year;
  const ViewUserWaterBill(
      {Key? key,
      required this.user,
      required this.editorUser,
      required this.month,
      required this.year})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    Users users = Users(user: editorUser);
    return Scaffold(
      appBar: editorAppBar(context),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          MyText(
            text: 'Water Bills',
            fontWeight: FontWeight.bold,
          ),
          FutureBuilder(
            future: users.getWaterBills(user),
            builder: (context, AsyncSnapshot snapshot) {
              ConnectionState connectionState = snapshot.connectionState;
              if (connectionState == ConnectionState.waiting) {
                return Center(
                  child: CircularProgressIndicator(),
                );
              } else if (connectionState == ConnectionState.done) {
                printf('snapshot.data: ${snapshot.data}');
                if (snapshot.data![0]) {
                  List<WaterBill> waterBills =
                      snapshot.data![1].map<WaterBill>((json) {
                    return WaterBill.fromJson(json);
                  }).toList();
                  if (waterBills.isEmpty) {
                    return Center(
                      child: Text('No Water Bills'),
                    );
                  } else {
                    return Expanded(
                      child: ListView.builder(
                        itemCount: waterBills.length,
                        itemBuilder: (context, index) {
                          WaterBill waterBill = waterBills[index];
                          return ViewUserWaterBillTile(
                            waterBill: waterBill,
                            user: user,
                            editorUser: editorUser,
                          );
                        },
                      ),
                    );
                  }
                }
              }
              return Center(
                child: Text('Error'),
              );
            },
          ),
        ],
      ),
      floatingActionButton: MyTextButton(
        onPressed: () {
          goto(context, AddWaterBill(user: user, editorUser: editorUser));
        },
        label: MyText(
          text: "Add Water Bill",
        ),
      ),
    );
  }
}

class ViewUserWaterBillTile extends StatefulWidget {
  const ViewUserWaterBillTile(
      {Key? key,
      required this.waterBill,
      required this.editorUser,
      required this.user})
      : super(key: key);

  final WaterBill waterBill;
  final User editorUser;
  final User user;

  @override
  State<ViewUserWaterBillTile> createState() => _ViewUserWaterBillTileState();
}

class _ViewUserWaterBillTileState extends State<ViewUserWaterBillTile> {
  bool edit = false;
  bool deleted = false;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onLongPress: () {
        setState(() {
          edit = !edit;
        });
      },
      onTap: () {
        if (edit) {
          setState(() {
            edit = false;
          });
        }
      },
      child: !deleted
          ? ListTile(
              title: Text(widget.waterBill.stringMonth),
              subtitle: Text(widget.waterBill.year.toString()),
              trailing: !edit
                  ? Text(widget.waterBill.amount.toString())
                  : Container(
                      padding: const EdgeInsets.only(top: 10),
                      width: MediaQuery.of(context).size.width * 0.4,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        // crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          // edit button,
                          IconButton(
                            icon: Icon(
                              Icons.edit_outlined,
                              size: 20,
                            ),
                            onPressed: () {
                              goto(
                                  context,
                                  AddWaterBill(
                                    user: widget.user,
                                    editorUser: widget.editorUser,
                                    waterBill: widget.waterBill,
                                  ));
                            },
                          ),
                          SizedBox(
                            width: 10,
                          ),
                          IconButton(
                              onPressed: () async {
                                Users users = Users(user: widget.editorUser);
                                var result = await users.deleteWaterBill(
                                    widget.user,
                                    widget.waterBill.stringMonth,
                                    widget.waterBill.year);
                                showSnackBar(
                                  context,
                                  result[1],
                                  icon: Icon(
                                    result[0]
                                        ? Icons.check_circle
                                        : Icons.error,
                                    color: result[0]
                                        ? Colors.green.shade400
                                        : Colors.red.shade400,
                                  ),
                                );
                                if (result[0]) {
                                  setState(() {
                                    deleted = true;
                                  });
                                }
                              },
                              icon: Icon(Icons.delete_forever)),
                        ],
                      ),
                    ),
            )
          : SizedBox(),
    );
  }
}

class AddWaterBill extends StatefulWidget {
  final User user;
  final User editorUser;
  final WaterBill? waterBill;

  const AddWaterBill(
      {Key? key, required this.user, required this.editorUser, this.waterBill})
      : super(key: key);

  @override
  State<AddWaterBill> createState() => _AddWaterBillState();
}

class _AddWaterBillState extends State<AddWaterBill> {
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _monthController = TextEditingController();
  final TextEditingController _yearController = TextEditingController();
  Date currentDate = Date.fromDateTime(DateTime.now());
  List<String>? _years;
  String? _selectedMonth;
  String? _selectedYear;
  bool _isLoading = false;

  @override
  void initState() {
    _years = List.generate(20, (i) => (currentDate.year - 10 + i).toString());

    if (widget.waterBill != null) {
      _amountController.text = widget.waterBill?.amount.toString() ?? '0';
      _monthController.text =
          widget.waterBill?.stringMonth ?? currentDate.month.toString();
      _yearController.text =
          widget.waterBill?.year.toString() ?? currentDate.year.toString();
      _selectedMonth =
          widget.waterBill?.stringMonth ?? currentDate.month.toString();
      _selectedYear = widget.waterBill?.year.toString();
    } else {
      if (saveMonth != null && saveYear != null) {
        _monthController.text = saveMonth!;
        _yearController.text = saveYear!;
        _selectedMonth = saveMonth;
        _selectedYear = saveYear;
      } else {
        _monthController.text = currentDate.month.toString();
        _yearController.text = currentDate.year.toString();
        _selectedMonth = currentDate.month.toString();
        _selectedYear = currentDate.year.toString();
      }
    }

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: editorAppBar(context),
      body: Padding(
        padding: EdgeInsets.all(kDefaultPadding),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            MyTextField(
              name: "Amount",
              icon: Icons.monetization_on,
              controller: _amountController,
              keyboardType: TextInputType.number,
              onChanged: (val) {
                String value = _amountController.text;
                value = value.replaceAll(RegExp(r'[^0-9.]'), '');
                // check if two dots are added
                if (value.contains('.')) {
                  if (value.split('.').length > 2) {
                    value = value.substring(0, value.length - 1);
                  }
                }
                _amountController.text = value;
                _amountController.selection = TextSelection.fromPosition(
                    TextPosition(offset: value.length));
              },
            ),
            SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: MediaQuery.of(context).size.width * .4,
                  child: MyDropDownButton(
                      onChanged: (val) {
                        saveYear = val;
                      },
                      value: _selectedYear,
                      items: _years!,
                      controller: _yearController),
                ),
                SizedBox(
                  width: MediaQuery.of(context).size.width * .4,
                  child: MyDropDownButton(
                      onChanged: (val) {
                        saveMonth = val;
                      },
                      value: _selectedMonth,
                      items: allmonths,
                      controller: _monthController),
                )
              ],
            ),
            SizedBox(height: 40),
            _isLoading ? CircularProgressIndicator() : SizedBox(),
            MyTextButton(
              onPressed: () async {
                double amount = parseDouble(_amountController.text);
                String month = _monthController.text;
                String year = _yearController.text;

                if (amount == 0) {
                  showSnackBar(context, "Please enter amount",
                      icon: Icon(Icons.error, color: Colors.red.shade400));
                  return;
                }
                Users users = Users(user: widget.editorUser);
                saveMonth = month;
                saveYear = year;
                _isLoading = true;
                var result =
                    await users.addWaterBill(widget.user, month, year, amount);
                _isLoading = false;

                if (result[0]) {
                  Navigator.pop(context);
                }
                showSnackBar(
                  context,
                  result[1],
                  icon: Icon(
                    result[0] ? Icons.check_circle : Icons.error,
                    color:
                        result[0] ? Colors.green.shade400 : Colors.red.shade400,
                  ),
                );

                // goto(
                //     context,
                //     LoadingPage(
                //       future:
                //           users.addWaterBill(widget.user, month, year, amount),
                //       failurePage: AddWaterBill(
                //         user: widget.user,
                //         editorUser: widget.editorUser,
                //       ),
                //       successPage: ViewUserWaterBill(
                //         user: widget.user,
                //         editorUser: widget.editorUser,
                //         month: month,
                //         year: year,
                //       ),
                //     ));
              },
              label: MyText(
                text: "${widget.waterBill != null ? "Update" : "Add"}",
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// class ShowWaterBills extends StatelessWidget {
//   final List<WaterBill> waterBills;
//   const ShowWaterBills({
//     Key? key,
//     required this.waterBills,
//   }) : super(key: key);

//   @override
//   Widget build(BuildContext context) {}
// }
