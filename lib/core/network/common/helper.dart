import 'package:dio/dio.dart';
import '../remote/app_exception.dart';

class Helper {
  static String getMessageFromException(Exception e) {
    final error = e.toString();
    final extracted =
        error.contains('-') ? error.split('-').sublist(1).join('-').trim() : error;
    return extracted;
  }
}

Exception handleExceptions(e) {
  if (e is DioException) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.sendTimeout:
        return ApiTimeoutException(message: e.message ?? 'Request Timeout');
      case DioExceptionType.connectionError:
        return InternetConnectionException(message: 'Please check your internet connection');
      case DioExceptionType.badResponse:
        final statusCode = e.response?.statusCode ?? 0;
        final data = e.response?.data;
        String message = 'Something went wrong';
        if (data is Map && data['message'] is String) message = data['message'] as String;
        if (statusCode == 400) return BadRequestException(message: message, statusCode: statusCode);
        if (statusCode == 401) return UnauthorizedException(message: message, statusCode: statusCode);
        if (statusCode == 403) return ForbiddenException(message: message, statusCode: statusCode);
        if (statusCode == 404) return NotFoundException(message: message, statusCode: statusCode);
        if (statusCode >= 500) return InternalServerErrorException(message: message, statusCode: statusCode);
        return UnknownApiException(message: message);
      case DioExceptionType.cancel:
        return const RequestCancelledException(message: 'Request cancelled');
      case DioExceptionType.badCertificate:
        return CertificateException(message: e.message ?? 'Bad certificate');
      case DioExceptionType.unknown:
        return UnknownApiException(message: e.message ?? 'Unknown error');
    }
  }
  return UnknownApiException(message: e.toString());
}
