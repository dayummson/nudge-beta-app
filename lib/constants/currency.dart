class AppCurrency {
  final String code;
  final String symbol;
  final String name;

  const AppCurrency({
    required this.code,
    required this.symbol,
    required this.name,
  });
}

const List<AppCurrency> currencies = [
  AppCurrency(code: 'USD', symbol: '\$', name: 'US Dollar'),
  AppCurrency(code: 'EUR', symbol: '€', name: 'Euro'),
  AppCurrency(code: 'GBP', symbol: '£', name: 'British Pound'),
  AppCurrency(code: 'JPY', symbol: '¥', name: 'Japanese Yen'),
  AppCurrency(code: 'CNY', symbol: '¥', name: 'Chinese Yuan'),
  AppCurrency(code: 'AUD', symbol: 'A\$', name: 'Australian Dollar'),
  AppCurrency(code: 'CAD', symbol: 'C\$', name: 'Canadian Dollar'),
  AppCurrency(code: 'SGD', symbol: 'S\$', name: 'Singapore Dollar'),
  AppCurrency(code: 'PHP', symbol: '₱', name: 'Philippine Peso'),
  AppCurrency(code: 'INR', symbol: '₹', name: 'Indian Rupee'),
  AppCurrency(code: 'CHF', symbol: 'CHF', name: 'Swiss Franc'),
  AppCurrency(code: 'NZD', symbol: 'NZ\$', name: 'New Zealand Dollar'),
  AppCurrency(code: 'THB', symbol: '฿', name: 'Thai Baht'),
  AppCurrency(code: 'IDR', symbol: 'Rp', name: 'Indonesian Rupiah'),
  AppCurrency(code: 'MYR', symbol: 'RM', name: 'Malaysian Ringgit'),
  AppCurrency(code: 'KRW', symbol: '₩', name: 'South Korean Won'),
];
