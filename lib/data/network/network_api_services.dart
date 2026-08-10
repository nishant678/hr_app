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
    _dio.interceptors.add(_AuthInterceptor());
    _dio.interceptors.add(_RefreshTokenInterceptor(_dio));
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

class _AuthInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final token = SessionController.token;
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }
}

class _RefreshTokenInterceptor extends Interceptor {
  final Dio dio;
  bool _refreshing = false;

  _RefreshTokenInterceptor(this.dio);

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode != 401 || _refreshing) {
      handler.next(err);
      return;
    }

    final rt = SessionController.refreshToken;
    if (rt == null || rt.isEmpty) {
      handler.next(err);
      return;
    }

    _refreshing = true;
    try {
      final baseUrl = err.requestOptions.baseUrl.isNotEmpty
          ? err.requestOptions.baseUrl
          : '${err.requestOptions.uri.scheme}://${err.requestOptions.uri.host}:${err.requestOptions.uri.port}';
      final refreshDio = Dio(BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: const Duration(seconds: 10),
      ));
      final refreshResp = await refreshDio.post(
        '/api/auth/refresh',
        data: {'refreshToken': rt},
      );

      if (refreshResp.statusCode == 200 && refreshResp.data is Map) {
        final data = refreshResp.data;
        final newAccess = data['token']?.toString() ?? '';
        final newRefresh = data['refreshToken']?.toString() ?? '';
        final newExpires = data['expiresAt'] is int ? data['expiresAt'] as int : 0;
        await SessionController().updateTokens(newAccess, newRefresh, newExpires);

        err.requestOptions.headers['Authorization'] = 'Bearer $newAccess';
        final response = await dio.fetch(err.requestOptions);
        handler.resolve(response);
      } else {
        await SessionController().clearSession();
        handler.next(err);
      }
    } catch (_) {
      await SessionController().clearSession();
      handler.next(err);
    } finally {
      _refreshing = false;
    }
  }
}
