// lib/core/utils/formatters/currency_formatter.dart

import 'package:intl/intl.dart';
import 'package:menahariya/core/constants/app_constants.dart';

class CurrencyFormatter {
  // Private constructor
  CurrencyFormatter._();

  // Currency symbols
  static const String etbSymbol = 'ETB';
  static const String etbShortSymbol = 'Br';

  // Default locale for Ethiopian Birr
  static const String etLocale = 'en_ET';

  // Format amount with ETB symbol
  static String format(
      dynamic amount, {
        bool showSymbol = true,
        int decimalPlaces = 2,
        String? symbol,
        bool useShortSymbol = false,
      }) {
    if (amount == null) return _emptyValue(showSymbol, useShortSymbol);

    try {
      final num value = _parseAmount(amount);
      final formattedNumber = _formatNumber(value, decimalPlaces);

      if (!showSymbol) return formattedNumber;

      final currencySymbol = _getSymbol(useShortSymbol);
      return '$currencySymbol $formattedNumber';
    } catch (e) {
      return amount.toString();
    }
  }

  // Format without decimal places (for whole numbers)
  static String formatWhole(
      dynamic amount, {
        bool showSymbol = true,
        bool useShortSymbol = false,
      }) {
    return format(
      amount,
      showSymbol: showSymbol,
      decimalPlaces: 0,
      useShortSymbol: useShortSymbol,
    );
  }

  // Format for compact display (e.g., 1.2K ETB)
  static String formatCompact(
      dynamic amount, {
        bool showSymbol = true,
        bool useShortSymbol = false,
      }) {
    if (amount == null) return _emptyValue(showSymbol, useShortSymbol);

    try {
      final num value = _parseAmount(amount);
      final compact = NumberFormat.compact().format(value);
      final symbol = _getSymbol(useShortSymbol);

      return showSymbol ? '$symbol $compact' : compact;
    } catch (e) {
      return amount.toString();
    }
  }

  // Format for display in lists
  static String forList(dynamic amount) {
    return format(amount, decimalPlaces: 0);
  }

  // Format for payment summary
  static String forPayment(
      dynamic amount, {
        bool showSymbol = true,
        bool useShortSymbol = true,
      }) {
    return format(
      amount,
      showSymbol: showSymbol,
      decimalPlaces: 2,
      useShortSymbol: useShortSymbol,
    );
  }

  // Format for receipt/invoice
  static String forReceipt(dynamic amount) {
    return format(amount, decimalPlaces: 2, useShortSymbol: false);
  }

  // Format for cargo fee
  static String forCargoFee(dynamic amount) {
    return format(amount, decimalPlaces: 1, useShortSymbol: true);
  }

  // Format for ticket price
  static String forTicketPrice(dynamic amount) {
    return format(amount, decimalPlaces: 2, useShortSymbol: true);
  }

  // Format for total amount (with word representation)
  static String forTotalWithWords(dynamic amount) {
    final formatted = format(amount, decimalPlaces: 2);
    final words = _numberToWords(_parseAmount(amount).floor());
    return '$formatted ($words Ethiopian Birr only)';
  }

  // Format for currency input field
  static String forInput(dynamic amount) {
    if (amount == null) return '';

    try {
      final value = _parseAmount(amount);
      return value.toStringAsFixed(2);
    } catch (e) {
      return amount.toString();
    }
  }

  // Parse from formatted string
  static double? parse(String? formattedString) {
    if (formattedString == null || formattedString.isEmpty) return null;

    // Remove currency symbols and spaces
    String cleaned = formattedString
        .replaceAll(RegExp(r'[ETB|Br|\s]'), '')
        .replaceAll(',', '');

    return double.tryParse(cleaned);
  }

  // Format for comparison (remove formatting)
  static String forComparison(dynamic amount) {
    if (amount == null) return '0';

    try {
      final value = _parseAmount(amount);
      return value.toStringAsFixed(2);
    } catch (e) {
      return '0';
    }
  }

  // Calculate total with tax
  static String withTax(dynamic amount, double taxRate) {
    final baseAmount = _parseAmount(amount);
    final tax = baseAmount * (taxRate / 100);
    final total = baseAmount + tax;

    return format(total, decimalPlaces: 2);
  }

  // Calculate discounted amount
  static String withDiscount(dynamic amount, double discountPercent) {
    final baseAmount = _parseAmount(amount);
    final discount = baseAmount * (discountPercent / 100);
    final total = baseAmount - discount;

    return format(total, decimalPlaces: 2);
  }

  // Format for change (e.g., "Change: 50 ETB")
  static String forChange(dynamic paid, dynamic total) {
    final paidAmount = _parseAmount(paid);
    final totalAmount = _parseAmount(total);
    final change = paidAmount - totalAmount;

    if (change < 0) {
      return 'Short: ${format(change.abs())}';
    } else {
      return 'Change: ${format(change)}';
    }
  }

  // Format for installment
  static String forInstallment(dynamic total, int installments) {
    if (installments <= 0) return format(total);

    final perInstallment = _parseAmount(total) / installments;
    return '${installments}x ${format(perInstallment)}';
  }

  // Get currency symbol
  static String _getSymbol(bool useShortSymbol) {
    return useShortSymbol ? etbShortSymbol : etbSymbol;
  }

  // Parse amount to num
  static num _parseAmount(dynamic amount) {
    if (amount is num) return amount;
    if (amount is String) return num.tryParse(amount) ?? 0;
    return 0;
  }

  // Format number with decimal places
  static String _formatNumber(num value, int decimalPlaces) {
    final formatter = NumberFormat('#,###.##', 'en_US');
    formatter.minimumFractionDigits = decimalPlaces;
    formatter.maximumFractionDigits = decimalPlaces;
    return formatter.format(value);
  }

  // Return empty value
  static String _emptyValue(bool showSymbol, bool useShortSymbol) {
    final symbol = _getSymbol(useShortSymbol);
    return showSymbol ? '$symbol 0.00' : '0.00';
  }

  // Convert number to words (for checks/receipts)
  static String _numberToWords(int number) {
    if (number == 0) return 'Zero';

    final units = [
      '', 'One', 'Two', 'Three', 'Four', 'Five', 'Six', 'Seven', 'Eight', 'Nine',
      'Ten', 'Eleven', 'Twelve', 'Thirteen', 'Fourteen', 'Fifteen', 'Sixteen',
      'Seventeen', 'Eighteen', 'Nineteen'
    ];

    final tens = [
      '', '', 'Twenty', 'Thirty', 'Forty', 'Fifty', 'Sixty', 'Seventy', 'Eighty', 'Ninety'
    ];

    if (number < 20) {
      return units[number];
    }

    if (number < 100) {
      return '${tens[number ~/ 10]} ${number % 10 != 0 ? units[number % 10] : ''}'.trim();
    }

    if (number < 1000) {
      return '${units[number ~/ 100]} Hundred ${number % 100 != 0 ? _numberToWords(number % 100) : ''}'.trim();
    }

    if (number < 1000000) {
      return '${_numberToWords(number ~/ 1000)} Thousand ${number % 1000 != 0 ? _numberToWords(number % 1000) : ''}'.trim();
    }

    if (number < 1000000000) {
      return '${_numberToWords(number ~/ 1000000)} Million ${number % 1000000 != 0 ? _numberToWords(number % 1000000) : ''}'.trim();
    }

    return number.toString();
  }

  // Currency comparison
  static int compare(dynamic a, dynamic b) {
    final numA = _parseAmount(a);
    final numB = _parseAmount(b);

    if (numA < numB) return -1;
    if (numA > numB) return 1;
    return 0;
  }

  // Sum amounts
  static String sum(List<dynamic> amounts) {
    num total = 0;
    for (final amount in amounts) {
      total += _parseAmount(amount);
    }
    return format(total);
  }

  // Average of amounts
  static String average(List<dynamic> amounts) {
    if (amounts.isEmpty) return format(0);

    num total = 0;
    for (final amount in amounts) {
      total += _parseAmount(amount);
    }

    return format(total / amounts.length);
  }
}