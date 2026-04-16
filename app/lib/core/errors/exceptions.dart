import 'package:dio/dio.dart';

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

/// Convertit une DioException en AppException typée.
/// Utilisé par tous les repositories pour un error handling cohérent.
AppException handleDioException(DioException e) {
  if (e.type == DioExceptionType.connectionError ||
      e.type == DioExceptionType.connectionTimeout) {
    return NetworkException(message: 'Pas de connexion internet');
  }

  final errorMessage = e.response?.data?['error'] as String?;

  switch (e.response?.statusCode) {
    case 400:
      return ValidationException(
        message: errorMessage ?? 'Données invalides',
      );
    case 401:
      return UnauthorizedException(
        message: errorMessage ?? 'Non authentifié',
      );
    case 403:
      return ForbiddenException(
        message: errorMessage ?? 'Accès refusé',
      );
    case 404:
      return NotFoundException(
        message: errorMessage ?? 'Ressource introuvable',
      );
    case 409:
      return ValidationException(
        message: errorMessage ?? 'Conflit de données',
      );
    case 422:
      return ValidationException(
        message: errorMessage ?? 'Données invalides',
      );
    case 429:
      return ValidationException(
        message: errorMessage ?? 'Trop de requêtes',
      );
    default:
      return ServerException(
        message: errorMessage ?? 'Erreur serveur',
        statusCode: e.response?.statusCode,
      );
  }
}
