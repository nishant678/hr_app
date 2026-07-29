import 'dart:async';
import 'dart:developer';

import 'package:dio/dio.dart';
import 'base_api_services.dart';
import '../exception/app_exceptions.dart';
import '../../services/session_manager/session_controller.dart';

class _LogInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    log('[REQ] ${options.method} ${options.uri}', name: 'API');
    if (options.data != null && options.data is! FormData) {
      log('[REQ] Body: ${options.data}', name: 'API');
    }
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    log('[RES] ${response.statusCode} ${response.requestOptions.uri}',
        name: 'API');
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    log('[ERR] ${err.response?.statusCode} ${err.requestOptions.uri}',
        name: 'API');
    log('[ERR] ${err.message}', name: 'API', error: err.error, stackTrace: err.stackTrace);
    handler.next(err);
  }
}

class NetworkApiService implements BaseApiServices {
  late final Dio _dio;

  NetworkApiService() {
    _dio = Dio(BaseOptions(
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 15),
      sendTimeout: const Duration(seconds: 30),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ));
    _dio.interceptors.add(_LogInterceptor());
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) {
        final token = SessionController.token;
        if (token != null && token.isNotEmpty) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        handler.next(options);
      },
    ));
  }

  @override
  Future<dynamic> getApi(String url) async {
    try {
      final response = await _dio.get(url);
      return _returnResponse(response);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  @override
  Future<dynamic> postApi(String url, dynamic data) async {
    try {
      final response = await _dio.post(url, data: data);
      return _returnResponse(response);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  @override
  Future<dynamic> putApi(String url, dynamic data) async {
    try {
      final response = await _dio.put(url, data: data);
      return _returnResponse(response);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  @override
  Future<dynamic> multipartPostApi(
    String url, {
    required String filePath,
    required String fileField,
    Map<String, String>? fields,
  }) async {
    try {
      final formData = FormData.fromMap({
        fileField: await MultipartFile.fromFile(filePath),
        if (fields != null) ...fields,
      });
      final response = await _dio.post(url, data: formData);
      return _returnResponse(response);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  dynamic _returnResponse(Response response) {
    switch (response.statusCode) {
      case 200:
      case 201:
      case 400:
        return response.data;
      case 401:
        throw UnauthorisedException(
          response.data?.toString() ?? 'Unauthorized',
        );
      case 404:
        throw FetchDataException(
          'Not found: ${response.requestOptions.uri}',
        );
      case 500:
        throw FetchDataException(
          'Server error: ${response.data?.toString() ?? 'Internal server error'}',
        );
      default:
        throw FetchDataException(
          'Error ${response.statusCode}: ${response.data?.toString() ?? 'Unknown error'}',
        );
    }
  }

  AppException _handleDioError(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return FetchDataException('Network Request time out');
      case DioExceptionType.connectionError:
        return NoInternetException('');
      case DioExceptionType.badResponse:
        if (e.response != null) {
          return _returnResponse(e.response!) as AppException;
        }
        return FetchDataException('Bad response: ${e.message}');
      case DioExceptionType.cancel:
        return FetchDataException('Request cancelled');
      default:
        return NoInternetException('No Internet Connection');
    }
  }
}
