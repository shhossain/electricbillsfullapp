import 'package:electricbills/models/bill.dart';
import 'package:electricbills/models/user.dart';
import 'package:electricbills/widgets/appbar.dart';
import 'package:electricbills/widgets/buttons.dart';
import 'package:electricbills/widgets/goto.dart';
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

class ViewerPage extends StatelessWidget {
  final User user;
  const ViewerPage({Key? key, required this.user}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: viewAppBar(context),
      body: ViewBills(user: user),
    );
  }
}

class ViewBills extends StatelessWidget {
  final User user;
  const ViewBills({Key? key, required this.user}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder(
          future: user.getBills(),
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
                      billData(bills.reversed.toList()),
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

  Expanded billData(List<Bill> bills) {
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
                        context, ViewBillData(bill: bills[index], user: user,appBar: viewAppBar(context),)),
                    label: ListTile(
                      title: Text(bills[index].stringMonth),
                      subtitle: Text(bills[index].year.toString()),
                      trailing: Text("${bills[index].totalUsage} X ${bills[index].unitPrice} = ${bills[index].totalAmmount}"),
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
  const ViewBillData({Key? key, required this.bill, required this.user,required this.appBar})
      : super(key: key);

  final Bill bill;
  final User user;
  final AppBar appBar;

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
            subtitle: MyText(text: user.username),
            trailing: MyText(text: '${bill.stringMonth} ${bill.year}'),
          ),
          ListTile(
            title: const MyText(text: 'Meter Reading'),
            trailing: MyText(text: '${bill.totalUnits.toStringAsFixed(2)} units'),
          ),
          ListTile(
            title: const MyText(text: 'Previous Reading'),
            trailing: MyText(text: '${bill.previousMonthUnits.toStringAsFixed(2)} units'),
          ),
          ListTile(
            title: const MyText(text: 'Monthly Usage'),
            trailing: MyText(text: '${bill.usedUnits.toStringAsFixed(2)} units'),
          ),
          ListTile(
            title: const MyText(text: 'Extra Usage'),
            trailing: MyText(text: '${bill.extraUnit.toStringAsFixed(2)} units'),
          ),
          ListTile(
            title: const MyText(text: 'Total Usage'),
            trailing: MyText(text: '${bill.totalUsage.toStringAsFixed(2)} units'),
          ),
          ListTile(
            title: const MyText(text: 'Unit Price'),
            trailing: MyText(text: '${bill.unitPrice.toStringAsFixed(2)} \$'),
          ),
          ListTile(
            title: const MyText(text: 'Monthly Bill'),
            trailing: MyText(text: '${bill.totalAmmount.toStringAsFixed(2)} \$'),
          ),
        ],
      ),
    );
  }
}
