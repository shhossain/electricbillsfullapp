import 'package:electricbills/api/user_methods.dart';
import 'package:electricbills/constants.dart';
import 'package:electricbills/env.dart';
import 'package:electricbills/helper/helper_func.dart';
import 'package:electricbills/models/bill.dart';
import 'package:electricbills/models/date.dart';
import 'package:electricbills/models/user.dart';
import 'package:electricbills/screens/loading.dart';
import 'package:electricbills/widgets/appbar.dart';
import 'package:electricbills/widgets/buttons.dart';
import 'package:electricbills/widgets/goto.dart';
import 'package:electricbills/widgets/rounded_box.dart';
import 'package:electricbills/widgets/text_field.dart';
import 'package:electricbills/widgets/texts.dart';
import 'package:electricbills/widgets/water_bill.dart';
import 'package:flutter/material.dart';

class EditorPage extends StatefulWidget {
  final User user;
  final String? selectedBill;
  const EditorPage({Key? key, required this.user,this.selectedBill}) : super(key: key);

  @override
  State<EditorPage> createState() => _EditorPageState();
}

class _EditorPageState extends State<EditorPage> {
  Widget? actionWidget;
  Date currentDate = Date.fromDateTime(DateTime.now());
  final TextEditingController _monthController = TextEditingController();
  final TextEditingController _yearController = TextEditingController();
  String? _selectedMonth;
  String? _selectedYear;
  String? _selectedBill;
  List<String>? _years;

  @override
  void initState() {
    super.initState();
    addUserWaringMsg = null;
    signWaringMsg = null;
    actionWidget = AddUser(user: widget.user);
    _selectedBill = widget.selectedBill ?? 'electricity';
    _years = List.generate(20, (i) => (currentDate.year - 10 + i).toString());
  }

  changeActionWidget(Widget widget) {
    setState(() {
      actionWidget = widget;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: editorAppBar(context),
      body: Column(
        children: [
          SizedBox(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height * 0.1,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 0.45,
                      child: MyDropDownButton(
                        controller: _monthController,
                        items: allmonths,
                        itemFontSize: 14,
                        value: allmonths[currentDate.intMonth - 1],
                        onChanged: (value) {
                          saveMonth = value;
                          setState(() {
                            _selectedMonth = value;
                          });
                        },
                      ),
                    ),
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 0.4,
                      child: MyDropDownButton(
                        controller: _yearController,
                        items: _years!,
                        value: currentDate.year.toString(),
                        itemFontSize: 15,
                        onChanged: (value) {
                          saveYear = value;
                          setState(() {
                            _selectedYear = int.parse(value).toString();
                          });
                        },
                      ),
                    ),
                  ]),
            ),
          ),
          Expanded(
            child: ShowBill(
              whichBill: _selectedBill ?? 'electricity',
              user: widget.user,
              month: _selectedMonth ?? currentDate.month,
              year: _selectedYear ?? currentDate.year.toString(),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(kDefaultPadding),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                // tab for electricity and water
                AnimatedContainer(
                  duration: const Duration(milliseconds: 500),
                  width: _selectedBill == 'electricity'
                      ? MediaQuery.of(context).size.width * 0.35
                      : MediaQuery.of(context).size.width * 0.25,
                  child: MyTextButton(
                    onPressed: () {
                      setState(() {
                        _selectedBill = 'electricity';
                      });
                    },
                    backgroundColor: _selectedBill == 'electricity'
                        ? Colors.blue.shade400
                        : Colors.grey[200],
                    label: const RounderBox(
                      width: 100,
                      height: 30,
                      child: Center(child: MyText(text: 'Electricity')),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 500),
                  width: _selectedBill == 'water'
                      ? MediaQuery.of(context).size.width * 0.35
                      : MediaQuery.of(context).size.width * 0.25,
                  child: MyTextButton(
                    onPressed: () {
                      setState(() {
                        _selectedBill = 'water';
                      });
                    },
                    backgroundColor: _selectedBill == 'water'
                        ? Colors.blue.shade400
                        : Colors.grey[200],
                    label: const RounderBox(
                      width: 100,
                      height: 30,
                      child: Center(child: MyText(text: 'Water')),
                    ),
                  ),
                ),
              ],
            ),
          )
        ],
      ),
      floatingActionButton: IconButton(
        icon: const Icon(Icons.add),
        onPressed: () {
          goto(context, actionWidget);
        },
      ),
    );
  }
}

class ShowBill extends StatelessWidget {
  final User user;
  final String month;
  final String year;
  final String whichBill;
  const ShowBill(
      {Key? key,
      required this.user,
      required this.month,
      required this.year,
      required this.whichBill})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (whichBill.contains('elect')) {
      return UserPage(user: user, month: month, year: year);
    } else {
      return ShowWaterBill(user: user, month: month, year: year);
    }
  }
}

class UserPage extends StatelessWidget {
  final User user;
  final String month;
  final String year;
  const UserPage(
      {Key? key, required this.user, required this.month, required this.year})
      : super(key: key);

  allUseresUsages(List<User> users) {
    double totalUnits = 0;
    double totalAmount = 0;

    for (User user in users) {
      var getBillDate = user.getBillDate(month, year);
      totalAmount += getBillDate?.totalAmmount ?? 0;
      totalUnits += getBillDate?.totalUsage ?? 0;
    }
    return [totalUnits, totalAmount];
  }

  sortUsersByTotalAmmount(List<User> users) {
    users.sort((a, b) => (b.getBillDate(month, year)?.totalAmmount ?? 0)
        .compareTo(a.getBillDate(month, year)?.totalAmmount ?? 0));
    return users;
  }

  @override
  Widget build(BuildContext context) {
    Users users = Users(user: user);
    return FutureBuilder(
      future: users.getUsersBill(month, year),
      builder: (context, AsyncSnapshot<List<User>> snapshot) {
        ConnectionState connectionState = snapshot.connectionState;
        if (connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (connectionState == ConnectionState.done) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            List<User> users = snapshot.data!;
            List<double> totalUsageAndAmount = allUseresUsages(users);
            return Column(
              children: [
                Padding(
                  padding: EdgeInsets.all(kDefaultPadding),
                  child: SizedBox(
                    width: MediaQuery.of(context).size.width,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const MyText(text: "Total Usage:", fontSize: 12),
                        MyText(
                          text: totalUsageAndAmount[0].toStringAsFixed(2),
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                        const MyText(
                          text: "Total Amount:",
                          fontSize: 12,
                        ),
                        MyText(
                          text: totalUsageAndAmount[1].toStringAsFixed(2),
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  child: Hero(
                    tag: 'userList',
                    child: ListView.builder(
                      itemCount: snapshot.data!.length,
                      itemBuilder: (context, index) {
                        List<User> sortedUsers = sortUsersByTotalAmmount(users);
                        return UserData(
                          user: sortedUsers[index],
                          editorUser: user,
                          month: month,
                          year: year,
                          totalAmount: totalUsageAndAmount[1],
                        );
                      },
                    ),
                  ),
                ),
              ],
            );
          }
        } else {
          return Center(child: Text('Error: ${snapshot.error}'));
        }
      },
    );
  }
}

class UserData extends StatefulWidget {
  final User user;
  final User editorUser;
  final String month;
  final String year;
  final double totalAmount;
  const UserData(
      {Key? key,
      required this.user,
      required this.editorUser,
      required this.month,
      required this.year,
      required this.totalAmount})
      : super(key: key);

  @override
  State<UserData> createState() => _UserDataState();
}

class _UserDataState extends State<UserData> {
  bool isDelete = false;

  @override
  void initState() {
    super.initState();
  }

  List<Color> getGradiantColors() {
    var getBillDate = widget.user.getBillDate(widget.month, widget.year);
    if ((getBillDate?.totalAmmount ?? 0) > 0 && widget.totalAmount > 0) {
      int halfs = 100;
      var total =
          ((getBillDate?.totalAmmount ?? 0) / widget.totalAmount) * halfs;
      int greens = total.round();
      int blanks = halfs - greens;

      List<Color> greenList = [];
      for (int i = 0; i < greens; i++) {
        greenList.add(Colors.black.withOpacity(0.3));
      }

      List<Color> blankList = [];
      for (int i = 0; i < blanks; i++) {
        blankList.add(Colors.black.withOpacity(0.1));
      }

      return greenList + blankList;
    }
    return [
      Colors.black.withOpacity(0.1),
      Colors.black.withOpacity(0.1),
      Colors.black.withOpacity(0.1),
      Colors.black.withOpacity(0.1)
    ];
  }

  @override
  Widget build(BuildContext context) {
    var getBillDate = widget.user.getBillDate(widget.month, widget.year);
    return InkWell(
      onLongPress: () {
        setState(() {
          isDelete = !isDelete;
        });
      },
      onTap: () {
        if (isDelete) {
          setState(() {
            isDelete = false;
          });
        } else {
          goto(
              context,
              ViewBills(
                user: widget.user,
                editorUser: widget.editorUser,
              ));
        }
      },
      child: Padding(
        padding: const EdgeInsets.only(left: 8.0, right: 8.0, bottom: 3.0),
        child: RounderBox(
          // show gradient with total amount / total users
          gradient: LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: getGradiantColors(),
          ),

          // color: Colors.black.withOpacity(0.1),
          child: ListTile(
            title: Text(widget.user.username),
            trailing: isDelete
                ? IconButton(
                    onPressed: () {
                      Users users = Users(user: widget.editorUser);
                      goto(
                          context,
                          LoadingPage(
                            failurePage: EditorPage(
                              user: widget.editorUser,
                            ),
                            future: users.deleteUser(widget.user),
                            successPage: EditorPage(
                              user: widget.editorUser,
                            ),
                          ));
                    },
                    icon: const Icon(Icons.delete))
                : Text((getBillDate?.totalUsage ?? 0) != 0
                    ? "${getBillDate?.totalUsage.toStringAsFixed(2) ?? 0} X ${getBillDate?.unitPrice.toStringAsFixed(2) ?? 0} = ${getBillDate?.totalAmmount.toStringAsFixed(2) ?? 0}"
                    : "0"),
          ),
        ),
      ),
    );
  }
}

class ViewBills extends StatefulWidget {
  final User user;
  final User editorUser;
  const ViewBills({Key? key, required this.user, required this.editorUser})
      : super(key: key);

  @override
  State<ViewBills> createState() => _ViewBillsState();
}

class _ViewBillsState extends State<ViewBills> {
  bool isDelete = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: editorAppBar(context),
      body: FutureBuilder(
          future: widget.user.getBills(),
          builder: (context, AsyncSnapshot<List<Bill>?> snapshot) {
            ConnectionState connectionState = snapshot.connectionState;
            if (connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (connectionState == ConnectionState.done) {
              if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              } else {
                List<Bill> bills = snapshot.data!;

                return Padding(
                  padding: EdgeInsets.all(kDefaultPadding),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const MyText(
                          text: "Info",
                          fontSize: 20,
                          fontWeight: FontWeight.bold),
                      ListTile(
                        title: const MyText(text: "Name:"),
                        subtitle: MyText(text: widget.user.username),
                      ),
                      const MyText(
                          text: "Bills",
                          fontSize: 20,
                          fontWeight: FontWeight.bold),
                      billData(bills.reversed.toList(), widget.user),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          RounderBox(
                            child: MyTextButton(
                              label: const MyText(
                                text: "Add Bill",
                                fontSize: 15,
                              ),
                              onPressed: () {
                                goto(
                                    context,
                                    AddUnit(
                                        user: widget.user,
                                        editorUser: widget.editorUser));
                              },
                              backgroundColor: Colors.black.withOpacity(0.1),
                            ),
                          ),
                        ],
                      )
                    ],
                  ),
                );
              }
            } else {
              return Center(child: Text('Error: ${snapshot.error}'));
            }
          }),
    );
  }

  Widget billData(List<Bill> bills, User user) {
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            isDelete = !isDelete;
          });
        },
        child: bills.isNotEmpty
            ? ListView.builder(
                itemCount: bills.length,
                itemBuilder: (context, index) {
                  return ViewBill(
                    user: user,
                    bill: bills[index],
                    editorUser: widget.editorUser,
                    isDelete: isDelete,
                  );
                },
              )
            : const Center(child: MyText(text: "No Bills Found", fontSize: 20)),
      ),
    );
  }
}

class ViewBill extends StatefulWidget {
  final Bill bill;
  final User user;
  final User editorUser;
  final bool isDelete;
  const ViewBill({
    Key? key,
    required this.bill,
    required this.user,
    required this.editorUser,
    required this.isDelete,
  }) : super(key: key);

  @override
  State<ViewBill> createState() => _ViewBillState();
}

class _ViewBillState extends State<ViewBill> {
  bool isDelete = false;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 3.0),
      child: InkWell(
        onLongPress: () {
          setState(() {
            isDelete = !isDelete;
          });
        },
        child: MyTextButton(
          onPressed: () {
            if (!isDelete) {
              goto(
                  context,
                  ViewBillDataEditor(
                    bill: widget.bill,
                    user: widget.user,
                    appBar: editorAppBar(context),
                    editorUser: widget.editorUser,
                  ));
            } else {
              setState(() {
                isDelete = false;
              });
            }
          },
          backgroundColor: Colors.black.withOpacity(0.1),
          label: ListTile(
            title: Text(widget.bill.stringMonth),
            subtitle: Text(widget.bill.year.toString()),
            trailing: !isDelete
                ? Text(
                    "${widget.bill.totalUsage.toStringAsFixed(2)} X ${widget.bill.unitPrice.toStringAsFixed(2)} = ${widget.bill.totalAmmount.toStringAsFixed(2)}")
                : IconButton(
                    onPressed: () {
                      Users users = Users(user: widget.editorUser);
                      goto(
                          context,
                          LoadingPage(
                            failurePage: ViewBills(
                              user: widget.user,
                              editorUser: widget.editorUser,
                            ),
                            future: users.deleteBill(
                                widget.user,
                                widget.bill.stringMonth,
                                widget.bill.year.toString(),
                                '1'),
                            successPage: ViewBills(
                              user: widget.user,
                              editorUser: widget.editorUser,
                            ),
                          ));
                    },
                    icon: const Icon(Icons.delete),
                  ),
          ),
        ),
      ),
    );
  }
}

class AddUnit extends StatefulWidget {
  final User user;
  final User editorUser;
  const AddUnit({Key? key, required this.user, required this.editorUser})
      : super(key: key);

  @override
  State<AddUnit> createState() => _AddUnitState();
}

class _AddUnitState extends State<AddUnit> {
  final TextEditingController _totalUnitController = TextEditingController();
  final TextEditingController _yearController = TextEditingController();
  final TextEditingController _monthController = TextEditingController();
  final TextEditingController _dayController = TextEditingController();
  final TextEditingController _unitPriceController = TextEditingController();
  final TextEditingController _totalUnitPriceController =
      TextEditingController();
  final TextEditingController _prevMonthUnit = TextEditingController();
  final TextEditingController _usedUnitController = TextEditingController();
  final TextEditingController _extraUnitsController = TextEditingController();
  final TextEditingController _allUnitController = TextEditingController();

  DateTime currentDate = DateTime.now();
  String? unitWaringMsg;
  String? apiWaringMsg;

  updatePrevMonthUnit() async {
    var syear = _yearController.text;
    var month = _monthController.text;
    var sday = _dayController.text;
    if (syear.isNotEmpty && month.isNotEmpty && sday.isNotEmpty) {
      var year = int.parse(syear);
      var day = int.parse(sday);
      Users users = Users(user: widget.editorUser);
      List result = await users.getPrevUnit(widget.user, month, year, day);

      if (result.first) {
        if (result.last.toString() != '0') {
          _prevMonthUnit.text = result.last.toString();
        }
        onChange();
      }
    }
  }

  onChange() {
    var totalUnitText = _totalUnitController.text;
    var unitPriceText = _unitPriceController.text;
    var prevMonthUnitText = _prevMonthUnit.text;
    var extraUnitsText = _extraUnitsController.text;

    if (totalUnitText.isNotEmpty) {
      // if (extraUnitsText.isEmpty) _extraUnitsController.text = '0';

      var totalUnit = parseDouble(totalUnitText);
      var unitPrice = parseDouble(unitPriceText);
      var prevMonthUnit = parseDouble(prevMonthUnitText);
      var extraUnits = parseDouble(extraUnitsText);

      var usedUnit = totalUnit - prevMonthUnit;
      _usedUnitController.text = usedUnit.toString();

      var allUnit = usedUnit + extraUnits;
      _allUnitController.text = allUnit.toString();

      var totalUnitPrice = (usedUnit + extraUnits) * unitPrice;
      _totalUnitPriceController.text = totalUnitPrice.toString();
    }
  }

  @override
  void initState() {
    super.initState();
    if (currentAddUser != null) {
      if (currentAddUser!.username == widget.user.username) {
        _totalUnitController.text = currentAddUser!.totalUnit.toString();
        _unitPriceController.text = currentAddUser!.unitPrice.toString();

        // if unit and price is not empty and is number
        if (currentAddUser!.totalUnit != null &&
            currentAddUser!.unitPrice != null) {
          _totalUnitPriceController.text =
              (currentAddUser!.totalUnit! * currentAddUser!.unitPrice!)
                  .toString();
        }

        if (addUserWaringMsg != null) {
          apiWaringMsg = addUserWaringMsg;
          addUserWaringMsg = null;
        }
      }
    }

    if (savedUnitPrice != null) {
      _unitPriceController.text = savedUnitPrice.toString();
    }

    if (saveExtraUnits != null) {
      _extraUnitsController.text = saveExtraUnits.toString();
    }

    if (_totalUnitController.text == 'null') {
      _totalUnitController.text = '';
    }

    onChange();
  }

  check(String whichText) {
    if (whichText == 'totalUnitName') {
      if (_totalUnitController.text.isEmpty) {
        setState(() {
          unitWaringMsg = 'Please enter total unit name';
        });
      } // total unit must be number check with regexp
      else if (_totalUnitController.text.contains(RegExp(r'[^0-9.]'))) {
        setState(() {
          unitWaringMsg = 'Total unit name must be number';
        });
      } else {
        setState(() {
          unitWaringMsg = null;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    List<String> years =
        List.generate(21, (i) => (currentDate.year - 10 + i).toString());
    List<String> dates = List.generate(31, (i) => (i + 1).toString());
    return Scaffold(
      appBar: editorAppBar(context),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(kDefaultPadding),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              unitWaringMsg != null
                  ? MyText(
                      text: unitWaringMsg!,
                      textColor: Colors.redAccent.shade400,
                    )
                  : Container(),
              apiWaringMsg != null
                  ? MyText(
                      text: apiWaringMsg!,
                      textColor: Colors.redAccent.shade400,
                    )
                  : Container(),
              MyTextField(
                controller: _totalUnitController,
                name: 'Current Usage',
                icon: Icons.power_settings_new,
                onChanged: (value) {
                  check('totalUnitName');
                  onChange();
                },
                suffix: MyText(
                  text: 'Unit',
                  textColor: Colors.grey.shade600,
                ),
              ),
              MyTextField(
                controller: _prevMonthUnit,
                name: 'Previous Month Usage',
                icon: Icons.power_settings_new,
                onChanged: (value) {
                  check('prevMonthUnit');
                  onChange();
                },
                suffix: IconButton(
                  icon: const Icon(Icons.refresh_outlined),
                  onPressed: () async {
                    await updatePrevMonthUnit();
                  },
                ),
              ),

              // used unit
              MyTextField(
                controller: _usedUnitController,
                name: 'Used Unit',
                icon: Icons.power_settings_new,
                onChanged: (value) {
                  check('usedUnit');
                  onChange();
                },
                suffix: MyText(
                  text: 'Unit',
                  textColor: Colors.grey.shade600,
                ),
              ),
              // extra unit
              MyTextField(
                controller: _extraUnitsController,
                name: 'Extra Unit',
                icon: Icons.power_settings_new,
                onChanged: (value) {
                  onChange();
                },
                suffix: MyText(
                  text: 'Unit',
                  textColor: Colors.grey.shade600,
                ),
              ),
              // all unit
              MyTextField(
                controller: _allUnitController,
                name: 'Total Unit',
                icon: Icons.power_settings_new,
                onChanged: (value) {},
                suffix: MyText(
                  text: 'Unit',
                  textColor: Colors.grey.shade600,
                ),
              ),
              // total ammount price
              MyTextField(
                controller: _unitPriceController,
                name: 'Unit Price',
                icon: Icons.attach_money,
                onChanged: (value) {
                  check('unitPrice');
                  onChange();
                },
                suffix: MyText(
                  text: '\$',
                  textColor: Colors.grey.shade600,
                ),
              ),
              // unit price
              MyTextField(
                controller: _totalUnitPriceController,
                name: 'Bill',
                icon: Icons.attach_money,
                onChanged: (value) {
                  check('bill');
                },
                suffix: MyText(
                  text: '\$',
                  textColor: Colors.grey.shade600,
                ),
              ),
              MyDropDownButton(
                items: allmonths,
                controller: _monthController,
                value: allmonths[currentDate.month - 1],
                onChanged: (value) async {
                  saveMonth = value;
                  await updatePrevMonthUnit();
                },
              ),
              MyDropDownButton(
                items: years,
                controller: _yearController,
                value: currentDate.year.toString(),
                onChanged: (String? val) async {
                  saveYear = val;
                  await updatePrevMonthUnit();
                },
              ),
              MyDropDownButton(
                items: dates,
                controller: _dayController,
                value: currentDate.day.toString(),
              ),
              const SizedBox(height: 20),
              MyTextButton(
                label: const MyText(text: 'Add Bill'),
                onPressed: () {
                  if (unitWaringMsg == null) {
                    double unitPrice = parseDouble(_unitPriceController.text);
                    double extraUnits = parseDouble(_extraUnitsController.text);
                    savedUnitPrice = unitPrice;
                    saveExtraUnits = extraUnits;
                    User addUser = User(
                        username: widget.user.username,
                        password: widget.user.password,
                        housename: widget.user.housename,
                        role: widget.user.role,
                        unitPrice: unitPrice,
                        extraUnit: extraUnits,
                        totalUnit: parseDouble(_totalUnitController.text));
                    Users users = Users(user: widget.editorUser);
                    int year = int.parse(_yearController.text);
                    String month = _monthController.text;
                    int date = int.parse(_dayController.text);
                    double totalAmmount =
                        parseDouble(_totalUnitPriceController.text);
                    double prevMonthUnit = parseDouble(_prevMonthUnit.text);
                    double usedUnit = parseDouble(_usedUnitController.text);
                    currentAddUser = addUser;
                    goto(
                        context,
                        LoadingPage(
                          failurePage: AddUnit(
                            user: widget.user,
                            editorUser: widget.editorUser,
                          ),
                          successPage: EditorPage(user: widget.editorUser),
                          future: users.addUnit(addUser, month, year, date,
                              totalAmmount, prevMonthUnit, usedUnit),
                        ));
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class AddUser extends StatefulWidget {
  final User user;
  const AddUser({Key? key, required this.user}) : super(key: key);

  @override
  State<AddUser> createState() => _AddUserState();
}

class _AddUserState extends State<AddUser> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _roleController = TextEditingController();

  String? userWarning;
  String? passwordWarning;
  String? apiWarning;

  @override
  void initState() {
    super.initState();

    if (currentAddUser != null) {
      var user = currentAddUser!;
      _usernameController.text = user.username;
      _passwordController.text = user.passWord;
      _roleController.text = user.roleName;
    }

    if (addUserWaringMsg != null) {
      setState(() {
        apiWarning = addUserWaringMsg;
        addUserWaringMsg = null;
      });
    }
  }

  checkText(String whichText) {
    if (whichText == 'username') {
      _passwordController.text = '${_usernameController.text}123';
      if (_usernameController.text.isEmpty) {
        setState(() {
          userWarning = 'Username cannot be empty';
        });
      } else if (_usernameController.text.length < 4) {
        setState(() {
          userWarning = 'Username must be at least 4 characters';
        });
      } else {
        setState(() {
          userWarning = null;
        });
      }
    } else if (whichText == 'password') {
      if (_passwordController.text.isEmpty) {
        setState(() {
          passwordWarning = 'Password cannot be empty';
        });
      } else if (_passwordController.text.length < 4) {
        setState(() {
          passwordWarning = 'Password must be at least 4 characters';
        });
      } else {
        setState(() {
          passwordWarning = null;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: editorAppBar(context),
        body: Padding(
          padding: EdgeInsets.all(kDefaultPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              apiWarning != null
                  ? MyText(
                      text: apiWarning!,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      textColor: Colors.red.withOpacity(0.5),
                    )
                  : const SizedBox(),
              MyTextField(
                controller: _usernameController,
                name: 'Username',
                icon: Icons.person,
                onChanged: (String value) {
                  checkText('username');
                },
              ),
              userWarning != null
                  ? MyText(
                      text: userWarning!,
                      textColor: Colors.red.withOpacity(.6),
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    )
                  : Container(),
              MyTextField(
                controller: _passwordController,
                name: 'Password',
                icon: Icons.lock,
                onChanged: (String value) {
                  checkText('password');
                },
              ),
              passwordWarning != null
                  ? MyText(
                      text: passwordWarning!,
                      textColor: Colors.red.withOpacity(.6),
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    )
                  : Container(),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: MyDropDownButton(
                  items: const ['Viewer', 'Editor'],
                  controller: _roleController,
                ),
              ),
              const SizedBox(height: 40),
              Center(
                child: MyTextButton(
                  label: const MyText(
                    text: 'Add User',
                  ),
                  backgroundColor: Colors.black.withOpacity(0.5),
                  onPressed: () {
                    if (userWarning == null && passwordWarning == null) {
                      Users users = Users(user: widget.user);
                      User addUser = User(
                        username: _usernameController.text,
                        password: _passwordController.text,
                        role: _roleController.text,
                        housename: widget.user.housename,
                      );
                      currentAddUser = addUser;
                      goto(
                          context,
                          LoadingPage(
                            failurePage: AddUser(
                              user: widget.user,
                            ),
                            successPage: EditorPage(user: widget.user),
                            future: users.addUserEditor(addUser),
                          ));
                    }
                  },
                ),
              )
            ],
          ),
        ));
  }
}

class ViewBillDataEditor extends StatefulWidget {
  const ViewBillDataEditor(
      {Key? key,
      required this.bill,
      required this.user,
      required this.appBar,
      required this.editorUser})
      : super(key: key);

  final Bill bill;
  final User user;
  final User editorUser;
  final AppBar appBar;

  @override
  State<ViewBillDataEditor> createState() => _ViewBillDataEditorState();
}

class _ViewBillDataEditorState extends State<ViewBillDataEditor> {
  // final texteditingcontrollers : meterReadingController,PreviousReadingController,extraUsageController,unitPriceController
  final TextEditingController _meterReadingController = TextEditingController();
  final TextEditingController _previousReadingController =
      TextEditingController();
  final TextEditingController _extraUsageController = TextEditingController();
  final TextEditingController _unitPriceController = TextEditingController();

  bool meterReadingEdit = false;
  bool previousReadingEdit = false;
  bool extraUsageEdit = false;
  bool unitPriceEdit = false;
  bool isEdited = false;
  List? warnings;

  String _meterReading = '';
  String _previousReading = '';
  String _extraUsage = '';
  String _unitPrice = '';

  String monthlyUsage = '';
  String totalUsage = '';
  String monthlyBill = '';

  @override
  void initState() {
    super.initState();
    _meterReadingController.text = widget.bill.totalUnits.toString();
    _previousReadingController.text = widget.bill.previousMonthUnits.toString();
    _extraUsageController.text = widget.bill.extraUnit.toString();
    _unitPriceController.text = widget.bill.unitPrice.toString();

    _meterReading = widget.bill.totalUnits.toStringAsFixed(2);
    _previousReading = widget.bill.previousMonthUnits.toStringAsFixed(2);
    _extraUsage = widget.bill.extraUnit.toStringAsFixed(2);
    _unitPrice = widget.bill.unitPrice.toStringAsFixed(2);

    monthlyUsage = widget.bill.usedUnits.toStringAsFixed(2);
    totalUsage = widget.bill.totalUsage.toStringAsFixed(2);
    monthlyBill = widget.bill.totalAmmount.toStringAsFixed(2);
  }

  updateBill() {
    monthlyUsage = (parseDouble(_meterReading) - parseDouble(_previousReading))
        .toStringAsFixed(2);
    totalUsage = (parseDouble(monthlyUsage) + parseDouble(_extraUsage))
        .toStringAsFixed(2);
    monthlyBill =
        (parseDouble(totalUsage) * parseDouble(_unitPrice)).toStringAsFixed(2);
  }

  @override
  void dispose() {
    super.dispose();
    _meterReadingController.dispose();
    _previousReadingController.dispose();
    _extraUsageController.dispose();
    _unitPriceController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: viewAppBar(context),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const MyText(
            text: 'Electric Bill',
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
          ListTile(
            title: const MyText(text: "For"),
            subtitle: MyText(text: widget.user.username),
            trailing:
                MyText(text: '${widget.bill.stringMonth} ${widget.bill.year}'),
          ),
          ListTile(
            title: const MyText(text: 'Meter Reading'),
            trailing: setEditInfo(
                text: '$_meterReading units',
                controller: _meterReadingController,
                edit: meterReadingEdit,
                onPressed: () {
                  setState(() {
                    meterReadingEdit = true;
                  });
                },
                onPressed2: () {
                  setState(() {
                    meterReadingEdit = false;
                    _meterReading = _meterReadingController.text;
                    updateBill();
                  });
                }),
          ),
          ListTile(
            title: const MyText(text: 'Previous Reading'),
            trailing: setEditInfo(
                text: '$_previousReading units',
                controller: _previousReadingController,
                edit: previousReadingEdit,
                onPressed: () {
                  setState(() {
                    previousReadingEdit = true;
                  });
                },
                onPressed2: () {
                  setState(() {
                    previousReadingEdit = false;
                    _previousReading = _previousReadingController.text;
                    updateBill();
                  });
                }),
          ),
          ListTile(
            title: const MyText(text: 'Monthly Usage'),
            trailing: MyText(text: '$monthlyUsage units'),
          ),
          ListTile(
            title: const MyText(text: 'Extra Usage'),
            trailing: setEditInfo(
                text: '$_extraUsage units',
                controller: _extraUsageController,
                edit: extraUsageEdit,
                onPressed: () {
                  setState(() {
                    extraUsageEdit = true;
                  });
                },
                onPressed2: () {
                  setState(() {
                    extraUsageEdit = false;
                    _extraUsage = _extraUsageController.text;
                    updateBill();
                  });
                }),
          ),
          ListTile(
            title: const MyText(text: 'Total Usage'),
            trailing: MyText(text: '$totalUsage units'),
          ),
          ListTile(
            title: const MyText(text: 'Unit Price'),
            trailing: setEditInfo(
                text: '$_unitPrice \$',
                controller: _unitPriceController,
                edit: unitPriceEdit,
                onPressed: () {
                  setState(() {
                    unitPriceEdit = true;
                  });
                },
                onPressed2: () {
                  setState(() {
                    unitPriceEdit = false;
                    _unitPrice = _unitPriceController.text;
                    updateBill();
                  });
                }),
          ),
          ListTile(
            title: const MyText(text: 'Monthly Bill'),
            trailing: MyText(text: '$monthlyBill \$'),
          ),
          warnings != null
              ? Column(
                  children: [
                    for (var warning in warnings!)
                      MyText(
                        text: warning,
                        textColor: Colors.red.withOpacity(.6),
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                  ],
                )
              : Container(),
          isEdited
              ? MyTextButton(
                  label: const MyText(text: 'Save'),
                  onPressed: () {
                    Users users = Users(user: widget.editorUser);
                    var month = widget.bill.month;
                    printf('month: $month');
                    var year = widget.bill.year;
                    var day = '1';

                    User editUser = User(
                      username: widget.user.username,
                      password: widget.user.password,
                      extraUnit: double.parse(_extraUsage),
                      totalUnit: double.parse(_meterReading),
                      previousMonthUnit: double.parse(_previousReading),
                      unitPrice: double.parse(_unitPrice),
                      housename: widget.user.housename,
                      role: widget.user.role,
                    );

                    goto(
                      context,
                      LoadingPage(
                        future: users.editBill(
                            editUser, month, year.toString(), day),
                        successPage: ViewBills(
                          editorUser: widget.editorUser,
                          user: widget.user,
                        ),
                        failurePage: ViewBillDataEditor(
                          bill: widget.bill,
                          user: widget.user,
                          editorUser: widget.editorUser,
                          appBar: widget.appBar,
                        ),
                      ),
                    );
                  },
                )
              : const SizedBox()
        ],
      ),
    );
  }

  Widget setEditInfo(
      {required String text,
      required dynamic onPressed,
      required dynamic onPressed2,
      required bool edit,
      required TextEditingController controller}) {
    return SizedBox(
      width: 200,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          !edit
              ? MyText(text: text)
              : SizedBox(
                  width: 100,
                  height: 50,
                  child: TextField(
                    onChanged: ((value) {
                      text = controller.text;
                      List? lwarnings = [];
                      if (text.isEmpty) {
                        lwarnings.add('Field is empty');
                      } else if (double.tryParse(text) == null) {
                        lwarnings.add('Invalid Number');
                      } else {
                        lwarnings = null;
                      }
                      setState(() {
                        warnings = lwarnings;
                      });
                    }),
                    controller: controller,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                        border: const OutlineInputBorder(), hintText: text),
                  ),
                ),
          !edit
              ? IconButton(
                  icon: const Icon(Icons.edit, size: 14),
                  onPressed: () {
                    if (!isEdited) {
                      setState(() {
                        isEdited = true;
                      });
                    }
                    onPressed();
                  },
                )
              : IconButton(
                  icon: const Icon(Icons.check, size: 14),
                  onPressed: () {
                    if (warnings == null) {
                      onPressed2();
                    }
                  },
                )
        ],
      ),
    );
  }
}
