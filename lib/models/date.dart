var allmonths = [
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


class Date{
  final int year;
  final String month;
  final int day;


  Date({
    required this.day,
    required this.month,
    required this.year,
  });
  
  // from datetime
  factory Date.fromDateTime(DateTime dateTime) {
    return Date(
      year: dateTime.year,
      month: allmonths[dateTime.month - 1],
      day: dateTime.day,
    );
  }

  get intMonth => allmonths.indexOf(month) + 1;

}