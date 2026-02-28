// lib/data/models/user/login_request.dart

class LoginRequest {
  final String phone;
  final String password;
  final String? deviceToken;
  final String? deviceType;

  LoginRequest({
    required this.phone,
    required this.password,
    this.deviceToken,
    this.deviceType,
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'phone': phone,
      'password': password,
    };

    if (deviceToken != null) data['deviceToken'] = deviceToken;
    if (deviceType != null) data['deviceType'] = deviceType;

    return data;
  }

  // For testing/demo purposes
  factory LoginRequest.demoPassenger() {
    return LoginRequest(
      phone: '0912345678',
      password: 'Pass@123',
    );
  }

  factory LoginRequest.demoDriver() {
    return LoginRequest(
      phone: '0987654321',
      password: 'Driver@123',
    );
  }
}

// Refresh Token Request
class RefreshTokenRequest {
  final String refreshToken;

  RefreshTokenRequest({required this.refreshToken});

  Map<String, dynamic> toJson() {
    return {
      'refreshToken': refreshToken,
    };
  }
}

// Logout Request
class LogoutRequest {
  final String? deviceToken;

  LogoutRequest({this.deviceToken});

  Map<String, dynamic> toJson() {
    return {
      'deviceToken': deviceToken,
    };
  }
}