import 'package:electricbills/models/date.dart';

class Bill {
  final int id;
  final String name;
  final int year;
  final int month;
  final double totalUnits;
  final double previousMonthUnits;
  final double usedUnits;
  final double unitPrice;
  final double? extraUnits;

  Bill({required this.id, required this.name, required this.year, required this.month, required this.totalUnits, required this.previousMonthUnits, required this.usedUnits, required this.unitPrice, this.extraUnits});


  // from json
  factory Bill.fromJson(Map<String, dynamic> json) {
    return Bill(
      id: json['id'],
      name: json['name'],
      year: json['year'],
      month: json['month'],
      totalUnits: json['total_units'],
      previousMonthUnits: json['previous_month_units'],
      usedUnits: json['used_units'],
      unitPrice: json['unit_price'],
      extraUnits: json['extra_units'],
    );
  }

  // to json
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'year': year,
      'month': month,
      'total_units': totalUnits,
      'previous_month_units': previousMonthUnits,
      'used_units': usedUnits,
      'unit_price': unitPrice,
      'extra_units': extraUnits,
    };
  }

  get stringMonth => allmonths[month - 1];
  get extraUnit => extraUnits ?? 0;
  get totalUsage => usedUnits + extraUnit;
  get totalAmmount => totalUsage * unitPrice;

}

class WaterBill {
  // name, year, month, amount
  final String name;
  final int year;
  final int month;
  final double amount;

  WaterBill({required this.name, required this.year, required this.month, required this.amount});

  // from json
  factory WaterBill.fromJson(Map<String, dynamic> json) {
    return WaterBill(
      name: json['name'],
      year: json['year'],
      month: json['month'],
      amount: json['amount'],
    );
  }

  factory WaterBill.tryFromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return WaterBill(name: 'null', year: 0, month: 0, amount: 0);
    }
    return WaterBill.fromJson(json);
  }

  // to json
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'year': year,
      'month': month,
      'amount': amount,
    };
  }

  get stringMonth => allmonths[month - 1];
}