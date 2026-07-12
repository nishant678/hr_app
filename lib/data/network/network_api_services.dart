import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:hr_app/data/network/base_api_services.dart';
import 'package:hr_app/services/session_manager/session_controller.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../exception/app_exceptions.dart';

/// Class for handling network API requests.
class NetworkApiService implements BaseApiServices {
  Map<String, String> _authHeaders([Map<String, String>? extra]) {
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    final token = SessionController.token;
    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }
    if (extra != null) {
      headers.addAll(extra);
    }
    return headers;
  }

  /// Sends a GET request to the specified [url] and returns the response.
  ///
  /// Throws a [NoInternetException] if there is no internet connection.
  /// Throws a [FetchDataException] if the network request times out.
  @override
  Future<dynamic> getApi(String url) async {
    if (kDebugMode) {
      print(url);
    }
    dynamic responseJson;
    try {
      final response = await http
          .get(Uri.parse(url), headers: _authHeaders())
          .timeout(const Duration(seconds: 20));
      responseJson = returnResponse(response);
    } on SocketException {
      throw NoInternetException('');
    } on TimeoutException {
      throw FetchDataException('Network Request time out');
    }

    if (kDebugMode) {
      print(responseJson);
    }
    return responseJson;
  }

  /// Sends a POST request to the specified [url] with the provided [data]
  /// and returns the response.
  ///
  /// Throws a [NoInternetException] if there is no internet connection.
  /// Throws a [FetchDataException] if the network request times out.
  @override
  Future<dynamic> postApi(String url, dynamic data) async {
    if (kDebugMode) {
      print(url);
      print(data);
    }

    dynamic responseJson;
    try {
      final Map<String, String>? headers;
      final Object body;
      if (data is String) {
        body = data;
        headers = _authHeaders();
      } else if (data is Map) {
        body = jsonEncode(data);
        headers = _authHeaders();
      } else {
        body = data.toString();
        headers = _authHeaders();
      }

      final http.Response response = await http
          .post(
            Uri.parse(url),
            headers: headers,
            body: body,
          )
          .timeout(const Duration(seconds: 10));
      responseJson = returnResponse(response);
    } on SocketException {
      throw NoInternetException('No Internet Connection');
    } on TimeoutException {
      throw FetchDataException('Network Request time out');
    }

    if (kDebugMode) {
      print(responseJson);
    }
    return responseJson;
  }

  dynamic _parseError(http.Response response) {
    try {
      final json = jsonDecode(response.body);
      if (json is Map && json.containsKey('error')) {
        return json;
      }
    } catch (_) {}
    return {'error': response.body};
  }

  dynamic returnResponse(http.Response response) {
    if (kDebugMode) {
      print(response.statusCode);
    }

    switch (response.statusCode) {
      case 200:
        return jsonDecode(response.body);
      case 400:
        return jsonDecode(response.body);
      case 401:
      case 404:
      case 500:
        return _parseError(response);
      default:
        return {'error': 'Error occurred while communicating with server'};
    }
  }
}
