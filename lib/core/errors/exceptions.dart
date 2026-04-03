class AppException implements Exception {
  final String message;
  const AppException(this.message);
  @override
  String toString() => 'AppException: $message';
}

class NetworkException extends AppException {
  const NetworkException([super.message = 'No internet connection']);
}

class ServerException extends AppException {
  final int? statusCode;
  const ServerException([super.message = 'Server error', this.statusCode]);
}

class AuthException extends AppException {
  const AuthException([super.message = 'Authentication failed']);
}

class CacheException extends AppException {
  const CacheException([super.message = 'Cache error']);
}

class UploadException extends AppException {
  const UploadException([super.message = 'Upload failed']);
}
