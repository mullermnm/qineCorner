import 'package:qine_corner/core/models/user.dart';

class AuthState {
  final String? userId;
  final String? phone;
  final bool isLoggedIn;
  final bool isVerified;
  final String? otp;
  final User? user;

  AuthState({
    this.userId,
    this.phone,
    this.isLoggedIn = false,
    this.isVerified = false,
    this.otp,
    this.user,
  });

  AuthState copyWith({
    String? userId,
    String? phone,
    bool? isLoggedIn,
    bool? isVerified,
    String? otp,
  }) {
    return AuthState(
      userId: userId ?? this.userId,
      phone: phone ?? this.phone,
      isLoggedIn: isLoggedIn ?? this.isLoggedIn,
      isVerified: isVerified ?? this.isVerified,
      otp: otp ?? this.otp,
      user: user ?? this.user,
    );
  }
}

class AuthResult {
  final String userId;
  final String phone;
  final String otp;
  final bool isVerified;
  final User? user;

  AuthResult({
    required this.userId,
    required this.phone,
    required this.otp,
    this.isVerified = false,
    this.user,
  });
}
