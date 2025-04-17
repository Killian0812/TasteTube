class CurrencyUtil {
  static String amountWithCurrency(double amount, String currency) {
    if (currency == 'VND') {
      return '${amount.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')} $currency';
    } else if (currency == 'USD') {
      return '${amount.toStringAsFixed(2)} $currency';
    }
    return '${amount.toStringAsFixed(2)} $currency';
  }
}
