import 'dart:core';
import 'package:dio/dio.dart';

import 'api_response.dart';

abstract class WebClient{
  Future<ApiResponse<T>> request<T>({
    required String path,
    required MethodType method,
    FormData? payload,
    Map<String, dynamic>? queryParameters,
    T Function(Map<String, dynamic> json)? fromJson,
    bool? showLoader,
  });

  void setToken(String token);
  void removeToken();
  String handleException(Exception exception);

}
enum MethodType { get, post, put, delete, patch }