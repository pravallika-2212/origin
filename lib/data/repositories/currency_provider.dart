import '../../core/riverpod.dart';
import '../../core/utils/formatters.dart';

class CurrencyNotifier extends StateNotifier<Currency> {
  CurrencyNotifier() : super(Currency.usd);

  void toggleCurrency() {
    state = state == Currency.usd ? Currency.inr : Currency.usd;
  }

  void setCurrency(Currency currency) {
    state = currency;
  }
}

final currencyProvider = StateNotifierProvider<CurrencyNotifier, Currency>((ref) {
  return CurrencyNotifier();
});
