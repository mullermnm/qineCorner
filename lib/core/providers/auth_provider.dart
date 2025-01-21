import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qine_corner/core/services/auth_service.dart';
import 'package:qine_corner/core/api/api_service.dart';
import 'package:qine_corner/core/models/user.dart';
import 'package:qine_corner/core/providers/shared_preferences_provider.dart';

final authServiceProvider =
    Provider((ref) => AuthService(ref.read(apiServiceProvider)));

final authNotifierProvider =
    AsyncNotifierProvider<AuthNotifier, AuthState?>(() => AuthNotifier());

class AuthNotifier extends AsyncNotifier<AuthState?> {
  late final AuthService _authService;
  static const String _authStateKey = 'auth_state';

  @override
  Future<AuthState?> build() async {
    _authService = ref.read(authServiceProvider);
    final prefs = ref.read(sharedPreferencesProvider);

    // Load saved auth state
    final savedState = prefs.getString(_authStateKey);
    if (savedState != null) {
      final Map<String, dynamic> json = jsonDecode(savedState);
      return AuthState(
        token: json['token'],
        userId: json['userId'],
        phone: json['phone'],
        isVerified: json['isVerified'],
        user: json['user'] != null ? User.fromJson(json['user']) : null,
      );
    }
    return null;
  }

  Future<void> _saveAuthState(AuthState state) async {
    final prefs = ref.read(sharedPreferencesProvider);
    final json = {
      'token': state.token,
      'userId': state.userId,
      'phone': state.phone,
      'isVerified': state.isVerified,
      'user': state.user?.toJson(),
    };
    await prefs.setString(_authStateKey, jsonEncode(json));
  }

  Future<void> _clearAuthState() async {
    final prefs = ref.read(sharedPreferencesProvider);
    await prefs.remove(_authStateKey);
  }

  Future<Map<String, dynamic>> register({
    required String name,
    required String phone,
    required String password,
    String? email,
    String? profileImage,
  }) async {
    state = const AsyncLoading();

    try {
      final data = await _authService.register(
        name: name,
        phone: phone,
        password: password,
        email: email,
        profileImage: profileImage,
      );

      final userData = data['user'];
      final token = data['token'];

      final authState = AuthState(
        token: token,
        userId: userData['id'].toString(),
        phone: userData['phone'],
        isVerified: userData['is_verified'] ?? false,
        user: User.fromJson(userData),
      );

      await _saveAuthState(authState);
      ApiService().setAuthToken(token);
      state = AsyncData(authState);
      return {
        'userId': userData['id'].toString(),
        'phone': userData['phone'],
        'token': token,
        'isVerified': userData['is_verified'] ?? false
      };
    } catch (e) {
      state = AsyncError(e, StackTrace.current);
      rethrow;
    }
  }

  Future<Map<String, dynamic>> login({
    required String phone,
    required String password,
  }) async {
    state = const AsyncLoading();

    try {
      final data = await _authService.login(
        phone: phone,
        password: password,
      );

      final userData = data['user'];
      final token = data['token'];

      final authState = AuthState(
        token: token,
        userId: userData['id'].toString(),
        phone: userData['phone'],
        isVerified: userData['is_verified'] ?? false,
        user: User.fromJson(userData),
      );

      await _saveAuthState(authState);
      ApiService().setAuthToken(token);
      state = AsyncData(authState);
      return {
        'userId': userData['id'].toString(),
        'phone': userData['phone'],
        'token': token,
        'isVerified': userData['is_verified'] ?? false
      };
    } catch (e) {
      state = AsyncError(e, StackTrace.current);
      rethrow;
    }
  }

  Future<void> verifyPhone({
    required String phone,
    required String otp,
  }) async {
    state = const AsyncLoading();

    try {
      final data = await _authService.verifyPhone(
        phone: phone,
        otp: otp,
      );

      final userData = data['user'];

      final authState = AuthState(
        token: state.value?.token ?? '',
        userId: userData['id'].toString(),
        phone: userData['phone'],
        isVerified: true,
        user: User.fromJson(userData),
      );

      await _saveAuthState(authState);
      state = AsyncData(authState);
    } catch (e) {
      state = AsyncError(e, StackTrace.current);
      rethrow;
    }
  }

  Future<void> resendOtp({
    required String phone,
  }) async {
    try {
      await _authService.resendOtp(phone: phone);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updateProfile({
    String? name,
    String? email,
    String? profileImage,
  }) async {
    state = const AsyncLoading();

    try {
      final data = await _authService.updateProfile(
        name: name,
        email: email,
        profileImage: profileImage,
      );

      final userData = data['user'];

      final authState = AuthState(
        token: state.value?.token ?? '',
        userId: userData['id'].toString(),
        phone: userData['phone'],
        isVerified: userData['is_verified'] ?? false,
        user: User.fromJson(userData),
      );

      await _saveAuthState(authState);
      state = AsyncData(authState);
    } catch (e) {
      state = AsyncError(e, StackTrace.current);
      rethrow;
    }
  }

  Future<void> fetchUser() async {
    if (state.value == null || !state.value!.token.isNotEmpty) return;

    try {
      final data = await _authService.getUser();
      final userData = data['user'];

      final authState = AuthState(
        token: state.value?.token ?? '',
        userId: userData['id'].toString(),
        phone: userData['phone'],
        isVerified: userData['is_verified'] ?? false,
        user: User.fromJson(userData),
      );

      await _saveAuthState(authState);
      state = AsyncData(authState);
    } catch (e) {
      state = AsyncError(e, StackTrace.current);
      rethrow;
    }
  }

  Future<void> logout() async {
    try {
      await _authService.logout();
      await _clearAuthState();
      ApiService().clearAuthToken();
      state = const AsyncData(null);
    } catch (e) {
      rethrow;
    }
  }

  bool get isLoggedIn => state.value?.token.isNotEmpty ?? false;
  bool get isVerified => state.value?.isVerified ?? false;
  String? get userId => state.value?.userId;
  String? get phone => state.value?.phone;
  String? get token => state.value?.token;
  User? get user => state.value?.user;
}

class AuthState {
  final String token;
  final String userId;
  final String phone;
  final bool isVerified;
  final User? user;

  const AuthState({
    required this.token,
    required this.userId,
    required this.phone,
    required this.isVerified,
    this.user,
  });
}
