// lib/data/models/payment/payment_request.dart

class PaymentRequest {
  final String bookingId;
  final double amount;
  final String method;
  final Map<String, dynamic>? paymentDetails;
  final bool useWallet;

  PaymentRequest({
    required this.bookingId,
    required this.amount,
    required this.method,
    this.paymentDetails,
    this.useWallet = false,
  });

  Map<String, dynamic> toJson() {
    return {
      'bookingId': bookingId,
      'amount': amount,
      'method': method,
      'paymentDetails': paymentDetails,
      'useWallet': useWallet,
    };
  }
}

// Telebirr Payment Request
class TelebirrPaymentRequest {
  final String bookingId;
  final double amount;
  final String phone;

  TelebirrPaymentRequest({
    required this.bookingId,
    required this.amount,
    required this.phone,
  });

  Map<String, dynamic> toJson() {
    return {
      'bookingId': bookingId,
      'amount': amount,
      'phone': phone,
    };
  }
}

// CBE Birr Payment Request
class CbeBirrPaymentRequest {
  final String bookingId;
  final double amount;
  final String phone;

  CbeBirrPaymentRequest({
    required this.bookingId,
    required this.amount,
    required this.phone,
  });

  Map<String, dynamic> toJson() {
    return {
      'bookingId': bookingId,
      'amount': amount,
      'phone': phone,
    };
  }
}

// Card Payment Request
class CardPaymentRequest {
  final String bookingId;
  final double amount;
  final String cardNumber;
  final String cardHolderName;
  final String expiryMonth;
  final String expiryYear;
  final String cvv;

  CardPaymentRequest({
    required this.bookingId,
    required this.amount,
    required this.cardNumber,
    required this.cardHolderName,
    required this.expiryMonth,
    required this.expiryYear,
    required this.cvv,
  });

  Map<String, dynamic> toJson() {
    return {
      'bookingId': bookingId,
      'amount': amount,
      'cardNumber': cardNumber,
      'cardHolderName': cardHolderName,
      'expiryMonth': expiryMonth,
      'expiryYear': expiryYear,
      'cvv': cvv,
    };
  }
}

// Refund Request
class RefundRequest {
  final String paymentId;
  final double? amount;
  final String reason;

  RefundRequest({
    required this.paymentId,
    this.amount,
    required this.reason,
  });

  Map<String, dynamic> toJson() {
    return {
      'paymentId': paymentId,
      'amount': amount,
      'reason': reason,
    };
  }
}

// Payment Verification Request
class PaymentVerificationRequest {
  final String paymentId;
  final String? transactionId;

  PaymentVerificationRequest({
    required this.paymentId,
    this.transactionId,
  });

  Map<String, dynamic> toJson() {
    return {
      'paymentId': paymentId,
      'transactionId': transactionId,
    };
  }
}