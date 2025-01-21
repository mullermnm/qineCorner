import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qine_corner/core/services/api_service.dart';

final apiServiceProvider = Provider<ApiService>((ref) {
  return ApiService(
    baseUrl: 'https://api.qinecorner.com/v1', // Replace with your actual API URL
  );
});
