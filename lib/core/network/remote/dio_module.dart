import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';

import '../../constants/app_values.dart';
import '../../storage_helper/app_shared_preference_helper.dart';
import '../../storage_helper/secure_storage_helper.dart';
import '../retrofit/ain_api.dart';

class AuthInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    final token = await SharedPreferencesHelper.getString(AppValues.token);
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  @override
  void onError(DioError err, ErrorInterceptorHandler handler) async {
    // لو الرد Unauthorized
    if (err.response?.statusCode == 401) {
      // نحذف التوكن
      await SharedPreferencesHelper.removeData(key: AppValues.token);
    }

    handler.next(err); // استمر في الخطأ
  }
}

@module
abstract class DioModule {
  @lazySingleton
  Dio provideDio(
      PrettyDioLogger logger,
      AuthInterceptor authInterceptor,
      ) {
    final dio = Dio();

    dio.options = BaseOptions(
      connectTimeout: const Duration(seconds: 40),
      receiveTimeout: const Duration(seconds: 40),
    );

    dio.interceptors.addAll([
      authInterceptor,  // هنا التوكن هيتضاف
      logger,
    ]);

    return dio;
  }

  @lazySingleton
  PrettyDioLogger providerInterceptor() {
    return PrettyDioLogger(
      error: true,
      request: true,
      requestBody: true,
      requestHeader: true,
      responseBody: true,
      responseHeader: true,
    );
  }

  @lazySingleton
  AuthInterceptor provideAuthInterceptor() => AuthInterceptor();

  @lazySingleton
  AinApi provideAinApi(Dio dio) => AinApi(dio); // Retrofit جاهز
}
