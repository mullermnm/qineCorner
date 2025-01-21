class ApiError implements Exception {
  final String message;
  final int? statusCode;

  ApiError({
    required this.message,
    this.statusCode,
  });

  @override
  String toString() => message;
}
