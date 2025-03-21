import '../api/api_config.dart';

class AppConfig {
  // Base URL from ApiConfig
  static String get apiBaseUrl => ApiConfig.baseUrl;

  // Helper method to get full URL for assets
  static String getAssetUrl(String? path) {
    if (path == null || path.isEmpty) return '';
    if (path.startsWith('http')) return path;
    return '$apiBaseUrl$path';
  }

  // Helper method specifically for PDF files
  static String getPdfUrl(String filePath) {
    if (filePath.startsWith('http')) return filePath;
    final cleanPath = filePath.startsWith('/') ? filePath.substring(1) : filePath;
    return '$apiBaseUrl/$cleanPath';
  }

  // API endpoints
  static const String apiPrefix = '/api/v1';
  
  // Helper method to get full API URL
  static String getApiUrl(String endpoint) {
    return '$apiBaseUrl$apiPrefix$endpoint';
  }
}
