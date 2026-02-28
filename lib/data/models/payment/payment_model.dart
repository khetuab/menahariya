// lib/data/models/payment/payment_model.dart

class PaymentModel {
  final String id;
  final String bookingId;
  final String? ticketId;
  final String userId;
  final double amount;
  final String currency;
  final String method; // telebirr, cbe_birr, card, cash, wallet
  final String status; // pending, processing, completed, failed, refunded
  final String? transactionId;
  final String? reference;
  final Map<String, dynamic>? providerData;
  final DateTime createdAt;
  final DateTime? completedAt;
  final DateTime? refundedAt;
  final String? failureReason;
  final Map<String, dynamic>? metadata;

  PaymentModel({
    required this.id,
    required this.bookingId,
    this.ticketId,
    required this.userId,
    required this.amount,
    required this.currency,
    required this.method,
    required this.status,
    this.transactionId,
    this.reference,
    this.providerData,
    required this.createdAt,
    this.completedAt,
    this.refundedAt,
    this.failureReason,
    this.metadata,
  });

  factory PaymentModel.fromJson(Map<String, dynamic> json) {
    return PaymentModel(
      id: json['_id'] ?? json['id'] ?? '',
      bookingId: json['bookingId'] ?? '',
      ticketId: json['ticketId'],
      userId: json['userId'] ?? '',
      amount: (json['amount'] ?? 0).toDouble(),
      currency: json['currency'] ?? 'ETB',
      method: json['method'] ?? '',
      status: json['status'] ?? 'pending',
      transactionId: json['transactionId'],
      reference: json['reference'],
      providerData: json['providerData'],
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      completedAt: json['completedAt'] != null ? DateTime.parse(json['completedAt']) : null,
      refundedAt: json['refundedAt'] != null ? DateTime.parse(json['refundedAt']) : null,
      failureReason: json['failureReason'],
      metadata: json['metadata'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'bookingId': bookingId,
      'ticketId': ticketId,
      'userId': userId,
      'amount': amount,
      'currency': currency,
      'method': method,
      'status': status,
      'transactionId': transactionId,
      'reference': reference,
      'providerData': providerData,
      'completedAt': completedAt?.toIso8601String(),
      'refundedAt': refundedAt?.toIso8601String(),
      'failureReason': failureReason,
      'metadata': metadata,
    };
  }

  // Helper getters
  bool get isCompleted => status == 'completed';
  bool get isPending => status == 'pending';
  bool get isFailed => status == 'failed';
  bool get isRefunded => status == 'refunded';
}

// lib/data/models/payment/payment_method_model.dart

class PaymentMethodModel {
  final String id;
  final String name;
  final String code;
  final String? icon;
  final double? minAmount;
  final double? maxAmount;
  final bool isActive;
  final Map<String, dynamic>? config;

  PaymentMethodModel({
    required this.id,
    required this.name,
    required this.code,
    this.icon,
    this.minAmount,
    this.maxAmount,
    this.isActive = true,
    this.config,
  });

  factory PaymentMethodModel.fromJson(Map<String, dynamic> json) {
    return PaymentMethodModel(
      id: json['_id'] ?? json['id'] ?? '',
      name: json['name'] ?? '',
      code: json['code'] ?? '',
      icon: json['icon'],
      minAmount: json['minAmount']?.toDouble(),
      maxAmount: json['maxAmount']?.toDouble(),
      isActive: json['isActive'] ?? true,
      config: json['config'],
    );
  }

  // Add toJson method
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'code': code,
      'icon': icon,
      'minAmount': minAmount,
      'maxAmount': maxAmount,
      'isActive': isActive,
      'config': config,
    };
  }

  // Optional: copyWith method for immutability
  PaymentMethodModel copyWith({
    String? id,
    String? name,
    String? code,
    String? icon,
    double? minAmount,
    double? maxAmount,
    bool? isActive,
    Map<String, dynamic>? config,
  }) {
    return PaymentMethodModel(
      id: id ?? this.id,
      name: name ?? this.name,
      code: code ?? this.code,
      icon: icon ?? this.icon,
      minAmount: minAmount ?? this.minAmount,
      maxAmount: maxAmount ?? this.maxAmount,
      isActive: isActive ?? this.isActive,
      config: config ?? this.config,
    );
  }

  // Optional: override toString for debugging
  @override
  String toString() {
    return 'PaymentMethodModel(id: $id, name: $name, code: $code, minAmount: $minAmount, maxAmount: $maxAmount, isActive: $isActive)';
  }

  // Optional: override equality operator
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is PaymentMethodModel &&
        other.id == id &&
        other.name == name &&
        other.code == code &&
        other.minAmount == minAmount &&
        other.maxAmount == maxAmount &&
        other.isActive == isActive;
  }

  @override
  int get hashCode {
    return id.hashCode ^
    name.hashCode ^
    code.hashCode ^
    minAmount.hashCode ^
    maxAmount.hashCode ^
    isActive.hashCode;
  }

  // Helper method to check if amount is within allowed range
  bool isAmountAllowed(double amount) {
    if (minAmount != null && amount < minAmount!) return false;
    if (maxAmount != null && amount > maxAmount!) return false;
    return true;
  }

  // Helper method to get display name with limits
  String getDisplayNameWithLimits() {
    String display = name;
    if (minAmount != null || maxAmount != null) {
      display += ' (';
      if (minAmount != null) display += 'Min: ${minAmount!.toStringAsFixed(0)} ETB';
      if (minAmount != null && maxAmount != null) display += ', ';
      if (maxAmount != null) display += 'Max: ${maxAmount!.toStringAsFixed(0)} ETB';
      display += ')';
    }
    return display;
  }
}

// Payment Transaction
class PaymentTransaction {
  final String id;
  final String paymentId;
  final String type; // authorization, capture, refund
  final double amount;
  final String status;
  final Map<String, dynamic>? providerResponse;
  final DateTime timestamp;

  PaymentTransaction({
    required this.id,
    required this.paymentId,
    required this.type,
    required this.amount,
    required this.status,
    this.providerResponse,
    required this.timestamp,
  });

  factory PaymentTransaction.fromJson(Map<String, dynamic> json) {
    return PaymentTransaction(
      id: json['_id'] ?? json['id'] ?? '',
      paymentId: json['paymentId'] ?? '',
      type: json['type'] ?? '',
      amount: (json['amount'] ?? 0).toDouble(),
      status: json['status'] ?? '',
      providerResponse: json['providerResponse'],
      timestamp: DateTime.parse(json['timestamp'] ?? DateTime.now().toIso8601String()),
    );
  }
}