import 'package:qine_corner/core/api/api_service.dart';
import 'package:qine_corner/core/api/api_config.dart';
import 'package:qine_corner/core/models/user.dart';
import 'package:qine_corner/core/models/auth_response.dart';

class AuthService {
  final ApiService _apiService;

  AuthService(this._apiService);

  Future<Map<String, dynamic>> register({
    required String name,
    required String phone,
    required String password,
    String? email,
    String? profileImage,
  }) async {
    final body = {
      'name': name,
      'phone': phone,
      'password': password,
    };
    if (email != null) body['email'] = email;
    if (profileImage != null) body['profile_image'] = profileImage;

    final response = await _apiService.post('/auth/register', body: body);

    if (response['status'] != 'success') {
      throw Exception(response['message'] ?? 'Registration failed');
    }

    return response['data'];
  }

  Future<Map<String, dynamic>> login({
    required String phone,
    required String password,
  }) async {
    final body = {
      'phone': phone,
      'password': password,
    };
    final response = await _apiService.post('/auth/login', body: body);

    if (response['status'] != 'success') {
      throw Exception(response['message'] ?? 'Login failed');
    }

    return response['data'];
  }

  Future<Map<String, dynamic>> verifyPhone({
    required String phone,
    required String otp,
  }) async {
    final body = {
      'phone': phone,
      'otp': otp,
    };
    final response = await _apiService.post('/auth/verify-phone', body: body);

    if (response['status'] != 'success') {
      throw Exception(response['message'] ?? 'Verification failed');
    }

    return response['data'];
  }

  Future<void> resendOtp({
    required String phone,
  }) async {
    final body = {
      'phone': phone,
    };
    final response = await _apiService.post('/auth/resend-otp', body: body);

    if (response['status'] != 'success') {
      throw Exception(response['message'] ?? 'Failed to resend OTP');
    }
  }

  Future<Map<String, dynamic>> updateProfile({
    String? name,
    String? email,
    String? profileImage,
  }) async {
    final body = {
      if (name != null) 'name': name,
      if (email != null) 'email': email,
      if (profileImage != null) 'profile_image': profileImage,
    };
    final response = await _apiService.post('/auth/profile', body: body);

    if (response['status'] != 'success') {
      throw Exception(response['message'] ?? 'Profile update failed');
    }

    return response['data'];
  }

  Future<Map<String, dynamic>> getUser() async {
    final response = await _apiService.get('/auth/user');

    if (response['status'] != 'success') {
      throw Exception(response['message'] ?? 'Failed to get user data');
    }

    return response['data'];
  }

  Future<void> logout() async {
    final response = await _apiService.post('/auth/logout');

    if (response['status'] != 'success') {
      throw Exception(response['message'] ?? 'Logout failed');
    }
  }

  Future<User> getCurrentUser() async {
    final response = await _apiService.get(ApiConfig.user);
    return User.fromJson(ApiConfig.extractData(response));
  }

  Future<User> updateUserProfile({
    required String name,
  }) async {
    final response = await _apiService.put(
      ApiConfig.profile,
      body: {
        'name': name,
      },
    );

    return User.fromJson(response['user']);
  }
}
