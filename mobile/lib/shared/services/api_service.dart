import 'package:dio/dio.dart';
import 'package:tirta/core/config/env_config.dart';
import 'package:tirta/shared/services/supabase_service.dart';

class ApiService {
  ApiService._();

  static final ApiService _instance = ApiService._();
  factory ApiService() => _instance;

  static Dio? _dio;

  Dio get dio {
    if (_dio != null) return _dio!;

    _dio = Dio(BaseOptions(
      baseUrl: EnvConfig.vpsApiBaseUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 120),
      headers: {
        'Content-Type': 'application/json',
      },
    ));

    _dio!.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) {
        final token = SupabaseService.accessToken;
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        handler.next(options);
      },
      onError: (error, handler) {
        if (error.type == DioExceptionType.connectionTimeout ||
            error.type == DioExceptionType.receiveTimeout) {
          handler.next(DioException(
            requestOptions: error.requestOptions,
            message: 'Koneksi timeout. Coba lagi.',
          ));
        } else if (error.type == DioExceptionType.connectionError) {
          handler.next(DioException(
            requestOptions: error.requestOptions,
            message: 'Tidak ada koneksi internet.',
          ));
        } else {
          handler.next(error);
        }
      },
    ));

    return _dio!;
  }
}
