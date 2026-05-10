// lib/data/models/passenger/passenger_model.dart

import 'package:menahariya/data/models/ticket/ticket_model.dart';

class PassengerModel {
  final String id;
  final String name;
  final String? phone;
  final String? email;
  final String seatNumber;
  final String ticketNumber;
  final bool checkedIn;
  final DateTime? checkedInTime;
  final bool hasCargo;
  final String? cargoId;
  final bool specialAssistance;
  final Map<String, dynamic>? metadata;
  final String? tripOrigin;
  final String? tripDestination;
  final DateTime? departureTime;

  PassengerModel({
    required this.id,
    required this.name,
    this.phone,
    this.email,
    required this.seatNumber,
    required this.ticketNumber,
    this.checkedIn = false,
    this.checkedInTime,
    this.hasCargo = false,
    this.cargoId,
    this.specialAssistance = false,
    this.metadata,
    this.tripOrigin,
    this.tripDestination,
    this.departureTime,
  });

  // lib/data/models/passenger/passenger_model.dart

  factory PassengerModel.fromJson(Map<String, dynamic> json) {
    return PassengerModel(
      id: json['_id']?.toString() ?? json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? json['passengerName']?.toString() ?? '',
      phone: json['phone']?.toString() ?? json['passengerPhone']?.toString(),
      email: json['email']?.toString() ?? json['passengerEmail']?.toString(),
      seatNumber: json['seatNumber']?.toString() ?? '',
      ticketNumber: json['ticketNumber']?.toString() ?? json['ticketId']?.toString() ?? '',
      checkedIn: json['checkedIn'] ?? false,
      checkedInTime: json['checkedInTime'] != null
          ? DateTime.parse(json['checkedInTime'].toString())
          : null,
      hasCargo: json['hasCargo'] ?? false,
      cargoId: json['cargoId']?.toString(),
      specialAssistance: json['specialAssistance'] ?? false,
      tripOrigin: json['tripOrigin']?.toString(),
      tripDestination: json['tripDestination']?.toString(),
      departureTime: json['departureTime'] != null
          ? DateTime.tryParse(json['departureTime'].toString())
          : null,
      metadata: json['metadata'] is Map ? Map<String, dynamic>.from(json['metadata']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'phone': phone,
      'email': email,
      'seatNumber': seatNumber,
      'ticketNumber': ticketNumber,
      'checkedIn': checkedIn,
      'checkedInTime': checkedInTime?.toIso8601String(),
      'hasCargo': hasCargo,
      'cargoId': cargoId,
      'specialAssistance': specialAssistance,
      'metadata': metadata,
      'tripOrigin': tripOrigin ,
      'tripDestination': tripDestination ,
      'departureTime': departureTime ,
    };
  }

  // Copy with method for immutability
  PassengerModel copyWith({

    String? name,
    String? phone,
    String? email,
    String? seatNumber,
    String? ticketNumber,
    bool? checkedIn,
    DateTime? checkedInTime,
    bool? hasCargo,
    String? cargoId,
    bool? specialAssistance,
    String? tripOrigin,
    String? tripDestination,
    DateTime? departureTime,
    Map<String, dynamic>? metadata,
  }) {
    return PassengerModel(
      id: id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      seatNumber: seatNumber ?? this.seatNumber,
      ticketNumber: ticketNumber ?? this.ticketNumber,
      checkedIn: checkedIn ?? this.checkedIn,
      checkedInTime: checkedInTime ?? this.checkedInTime,
      hasCargo: hasCargo ?? this.hasCargo,
      cargoId: cargoId ?? this.cargoId,
      specialAssistance: specialAssistance ?? this.specialAssistance,
      metadata: metadata ?? this.metadata,
      tripOrigin: tripOrigin ?? this.tripOrigin,
      tripDestination: tripDestination ?? this.tripDestination,
      departureTime: departureTime ?? this.departureTime,
    );
  }

  // Helper getters
  String getInitials() {
    if (name.isEmpty) return '';
    final nameParts = name.split(' ');
    if (nameParts.length > 1) {
      return '${nameParts[0][0]}${nameParts[1][0]}'.toUpperCase();
    }
    return name[0].toUpperCase();
  }

  @override
  String toString() {
    return 'PassengerModel(id: $id, name: $name, seat: $seatNumber, checkedIn: $checkedIn)';
  }
}

// Extension for passenger list operations
extension PassengerListExtension on List<PassengerModel> {
  List<PassengerModel> getCheckedIn() {
    return where((p) => p.checkedIn).toList();
  }

  List<PassengerModel> getPending() {
    return where((p) => !p.checkedIn).toList();
  }

  List<PassengerModel> search(String query) {
    if (query.isEmpty) return this;
    final lowerQuery = query.toLowerCase();
    return where((p) =>
    p.name.toLowerCase().contains(lowerQuery) ||
        p.seatNumber.toLowerCase().contains(lowerQuery) ||
        p.ticketNumber.toLowerCase().contains(lowerQuery) ||
        (p.phone?.toLowerCase().contains(lowerQuery) ?? false)
    ).toList();
  }

  Map<String, int> getStats() {
    return {
      'total': length,
      'checkedIn': getCheckedIn().length,
      'pending': getPending().length,
    };
  }
}