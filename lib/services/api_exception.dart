class ApiException implements Exception {
  const ApiException(this.message,
      {this.statusCode, this.requiresVerification = false});

  final String message;
  final int? statusCode;
  final bool requiresVerification;

  @override
  String toString() => message;
}
