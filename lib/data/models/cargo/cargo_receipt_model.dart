// lib/data/models/cargo/cargo_receipt_model.dart


import 'cargo_model.dart';

class CargoReceipt {
  final String receiptNumber;
  final CargoModel cargo;
  final double amount;
  final String paymentMethod;
  final String paymentStatus;
  final DateTime issuedAt;
  final String? qrCode;
  final Map<String, dynamic>? metadata;

  CargoReceipt({
    required this.receiptNumber,
    required this.cargo,
    required this.amount,
    required this.paymentMethod,
    required this.paymentStatus,
    required this.issuedAt,
    this.qrCode,
    this.metadata,
  });

  factory CargoReceipt.fromJson(Map<String, dynamic> json) {
    return CargoReceipt(
      receiptNumber: json['receiptNumber'] ?? '',
      cargo: CargoModel.fromJson(json['cargo']),
      amount: (json['amount'] ?? 0).toDouble(),
      paymentMethod: json['paymentMethod'] ?? '',
      paymentStatus: json['paymentStatus'] ?? '',
      issuedAt: DateTime.parse(json['issuedAt'] ?? DateTime.now().toIso8601String()),
      qrCode: json['qrCode'],
      metadata: json['metadata'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'receiptNumber': receiptNumber,
      'cargo': cargo.toJson(),
      'amount': amount,
      'paymentMethod': paymentMethod,
      'paymentStatus': paymentStatus,
      'issuedAt': issuedAt.toIso8601String(),
      'qrCode': qrCode,
      'metadata': metadata,
    };
  }
}

// lib/data/models/cargo/cargo_type.dart

class CargoType {
  final String id;
  final String name;
  final double baseRate;
  final double minFee;
  final String? icon;
  final String? description;
  final bool isActive;
  final Map<String, dynamic>? rules;

  CargoType({
    required this.id,
    required this.name,
    required this.baseRate,
    required this.minFee,
    this.icon,
    this.description,
    this.isActive = true,
    this.rules,
  });

  factory CargoType.fromJson(Map<String, dynamic> json) {
    return CargoType(
      id: json['_id'] ?? json['id'] ?? '',
      name: json['name'] ?? '',
      baseRate: (json['baseRate'] ?? 0).toDouble(),
      minFee: (json['minFee'] ?? 0).toDouble(),
      icon: json['icon'],
      description: json['description'],
      isActive: json['isActive'] ?? true,
      rules: json['rules'],
    );
  }

  // Add toJson method
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'baseRate': baseRate,
      'minFee': minFee,
      'icon': icon,
      'description': description,
      'isActive': isActive,
      'rules': rules,
    };
  }

  // Optional: copyWith method for immutability
  CargoType copyWith({
    String? id,
    String? name,
    double? baseRate,
    double? minFee,
    String? icon,
    String? description,
    bool? isActive,
    Map<String, dynamic>? rules,
  }) {
    return CargoType(
      id: id ?? this.id,
      name: name ?? this.name,
      baseRate: baseRate ?? this.baseRate,
      minFee: minFee ?? this.minFee,
      icon: icon ?? this.icon,
      description: description ?? this.description,
      isActive: isActive ?? this.isActive,
      rules: rules ?? this.rules,
    );
  }

  // Optional: override toString for debugging
  @override
  String toString() {
    return 'CargoType(id: $id, name: $name, baseRate: $baseRate, minFee: $minFee)';
  }

  // Optional: override equality operator
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CargoType &&
        other.id == id &&
        other.name == name &&
        other.baseRate == baseRate &&
        other.minFee == minFee;
  }

  @override
  int get hashCode {
    return id.hashCode ^ name.hashCode ^ baseRate.hashCode ^ minFee.hashCode;
  }
}