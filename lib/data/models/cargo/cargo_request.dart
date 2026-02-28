// lib/data/models/cargo/cargo_request.dart

class CargoRequest {
  final String senderName;
  final String senderPhone;
  final String receiverName;
  final String receiverPhone;
  final String tripId;
  final String cargoTypeId;
  final double weight;
  final String? dimensions;
  final String? description;
  final double? declaredValue;
  final bool isFragile;
  final bool isPerishable;
  final bool needsRefrigeration;

  CargoRequest({
    required this.senderName,
    required this.senderPhone,
    required this.receiverName,
    required this.receiverPhone,
    required this.tripId,
    required this.cargoTypeId,
    required this.weight,
    this.dimensions,
    this.description,
    this.declaredValue,
    this.isFragile = false,
    this.isPerishable = false,
    this.needsRefrigeration = false,
  });

  Map<String, dynamic> toJson() {
    return {
      'senderName': senderName,
      'senderPhone': senderPhone,
      'receiverName': receiverName,
      'receiverPhone': receiverPhone,
      'tripId': tripId,
      'cargoTypeId': cargoTypeId,
      'weight': weight,
      'dimensions': dimensions,
      'description': description,
      'declaredValue': declaredValue,
      'isFragile': isFragile,
      'isPerishable': isPerishable,
      'needsRefrigeration': needsRefrigeration,
    };
  }
}

// Cargo Tracking Request
class CargoTrackingRequest {
  final String trackingCode;

  CargoTrackingRequest({required this.trackingCode});

  Map<String, dynamic> toJson() {
    return {
      'trackingCode': trackingCode,
    };
  }
}

// Cargo Fee Calculation Request
class CargoFeeCalculationRequest {
  final String tripId;
  final String cargoTypeId;
  final double weight;
  final String? dimensions;
  final bool isFragile;
  final bool isPerishable;
  final bool needsRefrigeration;

  CargoFeeCalculationRequest({
    required this.tripId,
    required this.cargoTypeId,
    required this.weight,
    this.dimensions,
    this.isFragile = false,
    this.isPerishable = false,
    this.needsRefrigeration = false,
  });

  Map<String, dynamic> toJson() {
    return {
      'tripId': tripId,
      'cargoTypeId': cargoTypeId,
      'weight': weight,
      'dimensions': dimensions,
      'isFragile': isFragile,
      'isPerishable': isPerishable,
      'needsRefrigeration': needsRefrigeration,
    };
  }
}

// Cargo Status Update Request (Driver)
class CargoStatusUpdateRequest {
  final String cargoId;
  final String status;
  final String? location;
  final String? notes;

  CargoStatusUpdateRequest({
    required this.cargoId,
    required this.status,
    this.location,
    this.notes,
  });

  Map<String, dynamic> toJson() {
    return {
      'cargoId': cargoId,
      'status': status,
      'location': location,
      'notes': notes,
    };
  }
}