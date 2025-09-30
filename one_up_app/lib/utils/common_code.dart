
import 'package:intl/intl.dart';

class CommonCode {
  static String setDateFormat(String? inputDate) {
    if (inputDate == null || inputDate.trim().isEmpty) {
      return ""; // or return today's date if you want
    }

    try {
      // Parse incoming format (adjust based on your API/DB format)
      DateTime parsedDate = DateFormat("yyyy-MM-dd").parse(inputDate);

      // Convert to desired format
      return DateFormat("dd-MM-yyyy").format(parsedDate);
    } catch (e) {
      return inputDate; // fallback to original if parse fails
    }
  }


}
enum EventStatus {upcoming, ongoing, completed}
