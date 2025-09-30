import 'package:dio/dio.dart';
import 'package:one_up_app/api_service/api_end_points.dart';
import 'package:one_up_app/api_service/api_response.dart';
import 'package:one_up_app/api_service/web_client.dart';

abstract class RemoteDataSource {
  Future<ApiResponse<String>> getRegisterResponse(FormData data);
}

class RemoteDataSourceImpl implements RemoteDataSource {
  final WebClient apiClient;

  RemoteDataSourceImpl({required this.apiClient});

  @override
  Future<ApiResponse<String>> getRegisterResponse(FormData data) {
    return apiClient.request(
        path: ApiEndPoints.registrationEndPoint,
        method: MethodType.post,
      payload: data
    );
  }
}