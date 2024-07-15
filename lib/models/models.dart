class ApiRequest {
  Map<String, dynamic> toJson() => {};
}

class ApiResponse<T> {
  List<T>? data;
  ApiResponse({this.data});
  factory ApiResponse.fromJson(
      List<dynamic> json, T Function(Map<String, dynamic>) create) {
    return ApiResponse<T>(
      data: json.map((item) => create(item)).toList(),
    );
  }
}
