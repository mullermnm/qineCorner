class ApiConfig {
  // Use your PC's IP address instead of localhost when testing on mobile
  static const String baseUrl =
      'http://192.168.137.12:8000/api/v1'; // Update this with your PC's IP address

  // Auth endpoints
  static const String register = '/auth/register';
  static const String verifyPhone = '/auth/verify-phone';
  static const String login = '/auth/login';
  static const String user = '/auth/user';
  static const String profile = '/auth/profile';
  static const String logout = '/auth/logout';
  static const String forgotPassword = '/auth/forgot-password';
  static const String resetPassword = '/auth/reset-password';

  // API Endpoints
  static const String books = '/books';
  static const String categories = '/categories';
  static const String authors = '/authors';
  static const String recentBooks = '/books/recent';
  static const String bookRequests = '/books/request';

  // Endpoint builders
  static String booksByCategory(String categoryId) =>
      '/books/category/$categoryId';
  static String booksByAuthor(String authorId) => '/books/author/$authorId';
  static String bookDetails(String id) => '/books/$id';
  static String bookRecommendationsByCategory(String id) =>
      '/books/$id/recommendations/category';
  static String bookRecommendationsByAuthor(String id) =>
      '/books/$id/recommendations/author';
  static String bookProgress(String id) => '/books/$id/progress';

  // Default headers
  static Map<String, String> get headers => {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };

  // Response structure
  static dynamic extractData(Map<String, dynamic> response) {
    if (response['status'] == 'success') {
      if (!response.containsKey('data')) return null;

      final data = response['data'];
      if (data == null) return null;

      // Return the data object directly
      return data;
    }

    throw Exception('Invalid response format or error: ${response.toString()}');
  }

  static String? extractMessage(Map<String, dynamic> response) {
    return response['message'] as String?;
  }

  static String? extractError(Map<String, dynamic> response) {
    if (response.containsKey('error')) {
      return response['error'] as String;
    }
    if (response.containsKey('message')) {
      return response['message'] as String;
    }
    return null;
  }

  // Pagination defaults
  static const int defaultPageSize = 20;
  static const int defaultPage = 1;
}
