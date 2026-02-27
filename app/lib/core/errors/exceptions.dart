// Infrastructure layer exceptions
// These are thrown by datasources and caught by repositories

abstract class AppException implements Exception {
  final String message;
  final int? statusCode;

  AppException({required this.message, this.statusCode});

  @override
  String toString() => message;
}

class ServerException extends AppException {
  ServerException({required super.message, super.statusCode});

  @override
  String toString() => 'ServerException: $message (status: $statusCode)';
}

class NetworkException extends AppException {
  NetworkException({required super.message}) : super(statusCode: null);
  @override
  String toString() => 'NetworkException: $message (status: $statusCode)';
}

class ValidationException extends AppException {
  ValidationException({required super.message}) : super(statusCode: 400);
  @override
  String toString() => 'ValidationException: $message (status: $statusCode)';
}

class NotFoundException extends AppException {
  NotFoundException({required super.message}) : super(statusCode: 404);
  @override
  String toString() => 'NotFoundException: $message (status: $statusCode)';
}

class ForbiddenException extends AppException {
  ForbiddenException({required super.message}) : super(statusCode: 403);
  @override
  String toString() => 'ForbiddenException: $message (status: $statusCode)';
}

class UnauthorizedException extends AppException {
  UnauthorizedException({required super.message}) : super(statusCode: 401);
  @override
  String toString() => 'UnauthorizedException: $message (status: $statusCode)';
}

class UnknownException extends AppException {
  UnknownException({required super.message}) : super(statusCode: null);
  @override
  String toString() => 'UnknownException: $message (status: $statusCode)';
}
