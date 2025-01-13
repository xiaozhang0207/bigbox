import 'package:intl/intl.dart';

String money(num m) {
  if (m >= 1000000000000) {
    return ("${(m / 1000000000000).toStringAsFixed(1).replaceAll(".0", "")} их наяд");
  }
  if (m >= 1000000000) {
    return ("${(m / 1000000000).toStringAsFixed(1).replaceAll(".0", "")} тэрбум");
  }
  if (m >= 1000000) {
    return "${(m / 1000000).toStringAsFixed(1).replaceAll(".0", "")} сая";
  }
  return "${(m / 1000).toStringAsFixed(1).replaceAll(".0", "")} мянга";
}

String unit(num m) {
  var formatter = NumberFormat('#,###,###.#');
  return formatter.format(m).replaceAll(".0", "");
}
