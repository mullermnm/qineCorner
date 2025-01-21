class AppConfig {
  // Base URL for API
  static const String apiBaseUrl = 'http://192.168.137.1:8000'; // Current server IP
  // static const String apiBaseUrl = 'http://10.0.2.2:8000'; // For Android Emulator
  // static const String apiBaseUrl = 'http://localhost:8000'; // For Web
  // static const String apiBaseUrl = 'http://192.168.137.31:8000'; // For Physical Device

  // Helper method to get full URL for assets
  static String getAssetUrl(String? path) {
    if (path == null || path.isEmpty) return '';
    if (path.startsWith('http')) return path; // Return as is if already a full URL
    return '$apiBaseUrl$path';
  }

  // API endpoints
  static const String apiPrefix = '/api/v1';
  
  // Helper method to get full API URL
  static String getApiUrl(String endpoint) {
    return '$apiBaseUrl$apiPrefix$endpoint';
  }
}
