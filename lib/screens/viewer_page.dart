import 'package:electricbills/api/user_methods.dart';
import 'package:electricbills/constants.dart';
import 'package:electricbills/helper/helper_func.dart';
import 'package:electricbills/models/bill.dart';
import 'package:electricbills/models/user.dart';
import 'package:electricbills/widgets/appbar.dart';
import 'package:electricbills/widgets/buttons.dart';
import 'package:electricbills/widgets/goto.dart';
import 'package:electricbills/widgets/rounded_box.dart';
import 'package:electricbills/widgets/texts.dart';
import 'package:flutter/material.dart';

var monthes = [
  'January',
  'February',
  'March',
  'April',
  'May',
  'June',
  'July',
  'August',
  'September',
  'October',
  'November',
  'December'
];

class ViewerPage extends StatefulWidget {
  final User user;
  final String? whichBill;
  const ViewerPage({Key? key, required this.user, this.whichBill})
      : super(key: key);

  @override
  State<ViewerPage> createState() => _ViewerPageState();
}

class _ViewerPageState extends State<ViewerPage> {
  String? _selectedBill;

  @override
  void initState() {
    super.initState();
    _selectedBill = widget.whichBill ?? 'electricity';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: viewAppBar(context),
      body: Column(
        children: [
          Expanded(
            child: ViewBills(whichBill: _selectedBill, user: widget.user),
          ),
          Padding(
            padding: EdgeInsets.all(kDefaultPadding),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                // tab for electricity and water
                AnimatedContainer(
                  duration: Duration(milliseconds: 500),
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
                    label: RounderBox(
                      child: Center(child: MyText(text: 'Electricity')),
                      width: 100,
                      height: 30,
                    ),
                  ),
                ),
                SizedBox(width: 10),
                AnimatedContainer(
                  duration: Duration(milliseconds: 500),
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
                    label: RounderBox(
                      child: Center(child: MyText(text: 'Water')),
                      width: 100,
                      height: 30,
                    ),
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}

class ViewBills extends StatelessWidget {
  final User user;
  final String? whichBill;
  const ViewBills({Key? key, required this.user, this.whichBill})
      : super(key: key);

  _getFullBill() async {
    var result = [];
    result.add(await user.getBills());
    Users users = Users(user: user);
    result.add(await users.getWaterBillForViewAll());
    return result;
  }

  _getBills() {
    return _getFullBill();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder(
          future: _getBills(),
          builder: (context, AsyncSnapshot snapshot) {
            ConnectionState connectionState = snapshot.connectionState;
            if (connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (connectionState == ConnectionState.done) {
              if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              } else {
                var bills = snapshot.data[0];
                var waterBills = snapshot.data[1];

                List<Bill> ebills = bills;
                List<WaterBill> wbills = waterBills;

                printf('ebills: ${ebills.length} wbills: ${wbills.length}');
                return Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const MyText(
                          text: "Info",
                          fontSize: 20,
                          fontWeight: FontWeight.bold),
                      ListTile(
                        title: const MyText(text: "Name:"),
                        subtitle: MyText(text: user.username),
                      ),
                      const MyText(
                          text: "Bills",
                          fontSize: 20,
                          fontWeight: FontWeight.bold),
                      whichBill == 'water'
                          ? wbillData(wbills.reversed.toList())
                          : billData(ebills.reversed.toList(), wbills),
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

  Expanded wbillData(List<WaterBill> bills) {
    return Expanded(
      child: bills.isNotEmpty
          ? ListView.builder(
              itemCount: bills.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 3.0),
                  child: MyTextButton(
                    backgroundColor: Colors.black.withOpacity(0.1),
                    onPressed: () {},
                    label: ListTile(
                      title: Text(bills[index].stringMonth),
                      subtitle: Text(bills[index].year.toString()),
                      trailing: Text(bills[index].amount.toString()),
                    ),
                  ),
                );
              },
            )
          : const Center(child: MyText(text: "No Bills Found", fontSize: 20)),
    );
  }

  Expanded billData(List<Bill> bills, List<WaterBill> wbills) {
    return Expanded(
      child: bills.isNotEmpty
          ? ListView.builder(
              itemCount: bills.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 3.0),
                  child: MyTextButton(
                    backgroundColor: Colors.black.withOpacity(0.1),
                    onPressed: () => goto(
                        context,
                        ViewBillData(
                          bill: bills[index],
                          user: user,
                          appBar: viewAppBar(context),
                          waterBills: wbills,
                        )),
                    label: ListTile(
                      title: Text(bills[index].stringMonth),
                      subtitle: Text(bills[index].year.toString()),
                      trailing: Text(
                          "${bills[index].totalUsage} X ${bills[index].unitPrice} = ${bills[index].totalAmmount}"),
                    ),
                  ),
                );
              },
            )
          : const Center(child: MyText(text: "No Bills Found", fontSize: 20)),
    );
  }
}

class ViewBillData extends StatelessWidget {
  const ViewBillData(
      {Key? key,
      required this.bill,
      required this.user,
      required this.appBar,
      required this.waterBills})
      : super(key: key);

  final Bill bill;
  final List<WaterBill> waterBills;
  final User user;
  final AppBar appBar;

  getMatchingWaterBill() {
    for (WaterBill wbill in waterBills) {
      if (wbill.month == bill.month && wbill.year == bill.year) {
        printf('wbill: ${wbill.toJson()}');
        return wbill;
      }
    }
    return null;
  }

  getTotal(WaterBill? wbill) {
    var wbillAmount = wbill?.amount ?? 0;
    var billAmount = bill.totalAmmount;
    return wbillAmount + billAmount;
  }

  @override
  Widget build(BuildContext context) {
    WaterBill? wbill = getMatchingWaterBill();

    return Scaffold(
      appBar: viewAppBar(context),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            ListTile(
              title: const MyText(text: "For"),
              subtitle: MyText(text: user.username),
              trailing: MyText(text: '${bill.stringMonth} ${bill.year}'),
            ),
            const MyText(
              text: 'Electric Bill',
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
            ListTile(
              title: const MyText(text: 'Meter Reading'),
              trailing:
                  MyText(text: '${bill.totalUnits.toStringAsFixed(2)} units'),
            ),
            ListTile(
              title: const MyText(text: 'Previous Reading'),
              trailing: MyText(
                  text: '${bill.previousMonthUnits.toStringAsFixed(2)} units'),
            ),
            ListTile(
              title: const MyText(text: 'Monthly Usage'),
              trailing:
                  MyText(text: '${bill.usedUnits.toStringAsFixed(2)} units'),
            ),
            ListTile(
              title: const MyText(text: 'Extra Usage'),
              trailing:
                  MyText(text: '${bill.extraUnit.toStringAsFixed(2)} units'),
            ),
            ListTile(
              title: const MyText(text: 'Total Usage'),
              trailing:
                  MyText(text: '${bill.totalUsage.toStringAsFixed(2)} units'),
            ),
            ListTile(
              title: const MyText(text: 'Unit Price'),
              trailing: MyText(text: '${bill.unitPrice.toStringAsFixed(2)} \$'),
            ),
            ListTile(
              title: const MyText(text: 'Monthly Bill'),
              trailing:
                  MyText(text: '${bill.totalAmmount.toStringAsFixed(2)} \$'),
            ),
            const MyText(
              text: 'Water Bill',
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
            ListTile(
              title: const MyText(text: 'Total'),
              trailing: MyText(
                  text:
                      '${(wbill != null ? wbill.amount : 0).toStringAsFixed(2)} \$'),
            ),
            Container(
              height: 1,
              width: MediaQuery.of(context).size.width * .95,
              color: Colors.black.withOpacity(0.5),
            ),
            ListTile(
              title: const MyText(
                text: "Total",
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
              trailing: MyText(
                text: '${getTotal(wbill).toStringAsFixed(2)} \$',
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            )
          ],
        ),
      ),
    );
  }
}
