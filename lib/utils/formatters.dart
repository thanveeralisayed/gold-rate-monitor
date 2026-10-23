import 'package:intl/intl.dart';

class CurrencyFormatter {
  static final NumberFormat _inrFormat = NumberFormat.currency(
    locale: 'en_IN',
    symbol: '₹',
    decimalDigits: 0,
  );

  static final NumberFormat _inrFormatDecimal = NumberFormat.currency(
    locale: 'en_IN',
    symbol: '₹',
    decimalDigits: 2,
  );

  static String format(num value, {bool decimal = false}) {
    if (decimal) {
      return _inrFormatDecimal.format(value);
    }
    return _inrFormat.format(value);
  }

  static String formatChange(num value, {bool isGram = false}) {
    final prefix = value > 0 ? '+' : '';
    if (isGram) {
      return '$prefix${_inrFormatDecimal.format(value)}';
    }
    return '$prefix${_inrFormat.format(value)}';
  }

  static String formatPercent(double value) {
    final prefix = value > 0 ? '+' : '';
    return '$prefix${value.toStringAsFixed(2)}%';
  }
}
