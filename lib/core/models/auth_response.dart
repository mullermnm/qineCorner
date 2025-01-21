import 'package:qine_corner/core/models/user.dart';

class AuthResponse {
  final String token;
  final User user;

  AuthResponse({
    required this.token,
    required this.user,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      token: json['token'] as String,
      user: User.fromJson(json['user'] as Map<String, dynamic>),
    );
  }
}

class RegisterResponse {
  final String userId;
  final String otp;
  final bool isVerified;

  RegisterResponse({
    required this.userId,
    required this.otp,
    required this.isVerified,
  });

  factory RegisterResponse.fromJson(Map<String, dynamic> json) {
    return RegisterResponse(
      userId: json['user_id'].toString(),
      otp: json['otp'].toString(),
      isVerified: json['is_verified'],
    );
  }
}
