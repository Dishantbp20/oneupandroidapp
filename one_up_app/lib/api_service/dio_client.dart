import 'dart:developer';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:one_up_app/api_service/api_end_points.dart';
import 'package:one_up_app/api_service/api_response.dart';
import 'package:one_up_app/api_service/web_client.dart';
import 'package:one_up_app/utils/app_preferences.dart';

import '../auth/login_screen.dart';
import '../main.dart';

class DioClient implements WebClient {
  late Dio _client;
  String? _token ;

  DioClient() {
    AppPreferences.init();
    _token = AppPreferences.getToken();
    _client = Dio(BaseOptions(
      baseUrl: ApiEndPoints.baseUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      sendTimeout: const Duration(seconds: 30),
    ));

    // Interceptors for logging and headers
    _client.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) {
        // Set headers
        if(MethodType.post == "post"){
          options.headers["Content-Type"] = "multipart/form-data";
        }
        if (_token != null && _token!.isNotEmpty) {
          options.headers["authorization"] = "$_token";
        }

        log("➡ ${options.method} ${options.uri}");
        if (options.data != null) {
          log("Request Body: ${options.data}");
        }
        log("🚀 Sending request with headers: ${options.headers}");
        handler.next(options);
      },
      onResponse: (response, handler) {
        log("✅ Response: ${response.statusCode} ${response.data}");
        handler.next(response);
      },
      onError: (DioError e, handler) {
        log("❌ DioError: ${e.message}");
        log("❌ Type: ${e.type}");

        if (e.response != null) {
          log("❌ Response: ${e.response?.data}");
        } else if (e.error != null) {
          log("❌ Raw error: ${e.error}");
        }
        handler.next(e);
      },
    ));
  }

  @override
  void setToken(String token) {
    _token = token;
  }

  @override
  void removeToken() {
    _token = null;
  }

  @override
  String handleException(Exception exception) {
    if (exception is DioError) {
      if (exception.type == DioErrorType.connectionTimeout) {
        return "Connection timed out.";
      } else if (exception.type == DioErrorType.receiveTimeout) {
        return "Receive timed out.";
      } else if (exception.type == DioErrorType.badResponse) {
        return "Bad response: ${exception.response?.statusCode}";
      } else {
        return "Unexpected error: ${exception.message}";
      }
    }
    return "Something went wrong.";
  }

  @override
  Future<ApiResponse<T>> request<T>({
    required String path,
    required MethodType method,
    dynamic payload,
    Map<String, dynamic>? queryParameters,
    T Function(Map<String, dynamic> json)? fromJson,
    bool? showLoader,
  }) async {
    try {
      Response response;

      switch (method) {
        case MethodType.get:
          response = await _client.get(path, queryParameters: queryParameters);
          break;

        case MethodType.post:
          response = await _client.post(path, data: payload ?? queryParameters);
          break;

        case MethodType.put:
          response = await _client.put(path, data: payload ?? queryParameters);
          break;

        case MethodType.delete:
          response = await _client.delete(path, data: queryParameters);
          break;
        case MethodType.patch:
          response = await _client.patch(path, data: payload);
         break;
      }

      if (response.statusCode != null && response.statusCode! >= 200 && response.statusCode! < 300) {
        final data = response.data;

        // If fromJson function provided, parse the response
        if (fromJson != null && data is Map<String, dynamic>) {
          return ApiResponse<T>(
            data: fromJson(data),
            status: response.statusCode.toString(),
            message: data['message'] ?? 'Success',
          );
        }

        return ApiResponse<T>(
          data: data,
          status: response.statusCode.toString(),
          message: data['message'] ?? 'Success',
        );
      }else if(response.statusCode == 401){
        navigatorKey.currentState?.pushReplacementNamed('/login');

        return ApiResponse.fromError(
          "Unauthorized. Please login again.",
          response.statusCode.toString(),
        );
      }else {
        return ApiResponse.fromError(
          "Server error: ${response.statusCode}",
          response.statusCode.toString(),
        );
      }
    } catch (e) {
      log("Error: ${e.toString()}");
    }
    throw UnimplementedError("Unhandled code path in request<T>()");
  }
}

