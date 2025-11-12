import 'package:chucker_flutter/chucker_flutter.dart';
import 'package:dio/dio.dart';
import 'package:get/get.dart' hide Response;

import '../../config/app_config.dart';


class ApiService extends GetxService {
  ApiService({Dio? dio}) : _dio = dio ?? Dio(_defaultOptions);

  final Dio _dio;

  static BaseOptions get _defaultOptions {
    return BaseOptions(
      baseUrl: AppConfig.newsApiBaseUrl,
      connectTimeout: const Duration(seconds: 20),
      receiveTimeout: const Duration(seconds: 20),
      responseType: ResponseType.json,
      headers: {
        'X-Api-Key': AppConfig.newsApiKey,
      },
    );
  }

  static ApiService get to => Get.find<ApiService>();
  Dio get client => _dio;

  void setHeaderToken(String bearerToken) {
    _dio.options.headers.addAll({"Authorization" : "Bearer $bearerToken"});
  }

  Future<ApiService> init() async {
    _dio.interceptors.add(ChuckerDioInterceptor());
    return this;
  }

  Future<Response<T>> get<T>({
    String path = '',
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) {
    return _dio.get<T>(
      path,
      queryParameters: queryParameters,
      options: options,
    );
  }

  Future<Response<T>> post<T>({
    String path = '',
    Object? data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) {
    return _dio.post<T>(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
    );
  }

  Future<Response<T>> put<T>({
    String path = '',
    Object? data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) {
    return _dio.put<T>(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
    );
  }

  Future<Response<T>> delete<T>({
    String path = '',
    Object? data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) {
    return _dio.delete<T>(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
    );
  }
}
