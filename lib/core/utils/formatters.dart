import 'package:intl/intl.dart';

enum Currency { usd, inr }

class OriginFormatters {
  static const double usdToInrRate = 85.0;

  static String formatPrice(double priceUsd, Currency currency) {
    if (currency == Currency.inr) {
      final inr = priceUsd * usdToInrRate;
      final format = NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 0);
      return format.format(inr);
    } else {
      final format = NumberFormat.currency(locale: 'en_US', symbol: r'$', decimalDigits: 0);
      return '${format.format(priceUsd)} USD';
    }
  }

  static String formatDate(DateTime date) {
    return DateFormat('MMMM d, y').format(date);
  }
}
