class ApiResponse<T> {
  T? data;
  String? status;
  String? message;
  List<String>? errors;

  ApiResponse({
    this.data,
    this.status,
    this.errors,
    this.message,
  });

  @override
  String toString() {
    return 'ApiResponse<$T>{data: $data, statusCode: $status, errors: $errors, statusMessage: $message}';
  }

  factory ApiResponse.fromError(String msg, String statusCode) {
    return ApiResponse(
      status: statusCode,
      message: msg,
    );
  }
}
