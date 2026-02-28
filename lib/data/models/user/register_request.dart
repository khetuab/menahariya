// lib/data/models/user/register_request.dart

class RegisterRequest {
  final String fullName;
  final String phone;
  final String? email;
  final String password;
  final String role;
  final Map<String, dynamic>? metadata;

  // Driver specific fields
  final String? licenseNumber;
  final DateTime? licenseExpiry;

  RegisterRequest({
    required this.fullName,
    required this.phone,
    this.email,
    required this.password,
    this.role = 'passenger',
    this.metadata,
    this.licenseNumber,
    this.licenseExpiry,
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'fullName': fullName,
      'phone': phone,
      'password': password,
      'role': role,
    };

    if (email != null) data['email'] = email;
    if (metadata != null) data['metadata'] = metadata;

    // Driver specific fields
    if (licenseNumber != null) data['licenseNumber'] = licenseNumber;
    if (licenseExpiry != null) {
      data['licenseExpiry'] = licenseExpiry!.toIso8601String();
    }

    return data;
  }

  // Factory for passenger registration
  factory RegisterRequest.passenger({
    required String fullName,
    required String phone,
    String? email,
    required String password,
  }) {
    return RegisterRequest(
      fullName: fullName,
      phone: phone,
      email: email,
      password: password,
      role: 'passenger',
    );
  }

  // Factory for driver registration
  factory RegisterRequest.driver({
    required String fullName,
    required String phone,
    String? email,
    required String password,
    required String licenseNumber,
    required DateTime licenseExpiry,
  }) {
    return RegisterRequest(
      fullName: fullName,
      phone: phone,
      email: email,
      password: password,
      role: 'driver',
      licenseNumber: licenseNumber,
      licenseExpiry: licenseExpiry,
    );
  }
}

// OTP Verification Request
class OtpVerificationRequest {
  final String phone;
  final String otp;
  final String? userId;

  OtpVerificationRequest({
    required this.phone,
    required this.otp,
    this.userId,
  });

  Map<String, dynamic> toJson() {
    return {
      'phone': phone,
      'otp': otp,
      'userId': userId,
    };
  }
}

// Password Reset Request
class PasswordResetRequest {
  final String phone;
  final String otp;
  final String newPassword;

  PasswordResetRequest({
    required this.phone,
    required this.otp,
    required this.newPassword,
  });

  Map<String, dynamic> toJson() {
    return {
      'phone': phone,
      'otp': otp,
      'newPassword': newPassword,
    };
  }
}

// Change Password Request
class ChangePasswordRequest {
  final String currentPassword;
  final String newPassword;

  ChangePasswordRequest({
    required this.currentPassword,
    required this.newPassword,
  });

  Map<String, dynamic> toJson() {
    return {
      'currentPassword': currentPassword,
      'newPassword': newPassword,
    };
  }
}