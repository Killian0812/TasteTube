import 'package:intl/intl.dart';

class DateTimeUtil {
  static String dateTimeHHmmddMMyyyy(DateTime date) {
    return DateFormat('HH:mm dd/MM/yyyy').format(date.toLocal());
  }
}
