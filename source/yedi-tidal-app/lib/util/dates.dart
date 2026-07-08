import 'package:intl/intl.dart';

extension DateTimeExtensions on DateTime {
  String formatDate({String format = 'dd/MM/yyyy'}) =>
      DateFormat(format).format(this);

  String formatDateDB() => DateFormat("yyyy-MM-dd").format(this);

  String formatDateTime({String format = 'dd/MM/yyyy HH:mm'}) =>
      DateFormat(format).format(this);

  String formatTime({String format = 'HH:mm'}) =>
      DateFormat(format).format(this);

  String formatDateTimeDB() =>
      DateFormat("yyyy-MM-dd'T'HH:mm:ss'Z'").format(toUtc());

  bool isToday() {
    final now = DateTime.now();
    return year == now.year && month == now.month && day == now.day;
  }

  bool isInThePast() {
    return isBefore(DateTime.now());
  }

  bool isInTheFuture() {
    return isAfter(DateTime.now());
  }

  bool isBefore(DateTime other) {
    return compareTo(other) < 0;
  }

  bool isAfter(DateTime other) {
    return compareTo(other) > 0;
  }

  DateTime addBusinessDays(int days) {
    DateTime result = this;
    int absDays = days.abs();
    int sign = days.isNegative ? -1 : 1;

    while (absDays > 0) {
      result = result.add(Duration(days: sign));
      if (result.weekday != DateTime.saturday &&
          result.weekday != DateTime.sunday) {
        absDays--;
      }
    }
    return result;
  }

  DateTime get startOfDay {
    return DateTime(year, month, day);
  }

  DateTime get endOfDay {
    return DateTime(year, month, day, 23, 59, 59, 999);
  }

  bool isSameDay(DateTime other) {
    return year == other.year && month == other.month && day == other.day;
  }

  DateTime next(int weekday) {
    if (weekday < DateTime.monday || weekday > DateTime.sunday) {
      throw ArgumentError('Weekday must be between Monday (1) and Sunday (7)');
    }
    int daysToAdd = (weekday - this.weekday) % 7;
    if (daysToAdd <= 0) daysToAdd += 7;
    return add(Duration(days: daysToAdd));
  }

  String toFormattedString({String format = 'yMd'}) {
    return DateFormat(format).format(this);
  }

  int yearsBetween(DateTime other) {
    int yearsDiff = other.year - year;
    if (DateTime(year + yearsDiff, month, day).isAfter(other)) {
      yearsDiff--;
    }
    return yearsDiff;
  }

  String applyByLabel() {
    // https://stackoverflow.com/a/62215027
    Duration difference = DateTime.now().difference(this);
    if (difference.isNegative) {
      difference = -difference;
    } else {
      return 'Deadline passed';
    }

    if (difference.inMinutes < 1) {
      final differenceValue = difference.inSeconds;
      final unit = differenceValue == 1 ? 'second' : 'seconds';
      return "${difference.inSeconds} $unit";
    } else if (difference.inHours < 1) {
      final differenceValue = difference.inMinutes;
      final unit = differenceValue == 1 ? 'min' : 'mins';
      return "${difference.inMinutes} $unit";
    } else if (difference.inHours < 24) {
      final differenceValue = difference.inHours;
      final unit = differenceValue == 1 ? 'hour' : 'hours';
      return "${difference.inHours} $unit";
    } else if (difference.inDays < 31) {
      final differenceValue = difference.inDays;
      final unit = differenceValue == 1 ? 'day' : 'days';
      return "${difference.inDays} $unit";
    } else if (difference.inDays < 365) {
      final differenceValue = (difference.inDays / 31).floor();
      final unit = differenceValue == 1 ? 'month' : 'months';
      return "${(difference.inDays / 31).floor()} $unit";
    } else {
      final differenceValue = (difference.inDays / 365).floor();
      final unit = differenceValue == 1 ? 'year' : 'years';
      return "${(difference.inDays / 365).floor()} $unit";
    }
  }
}
