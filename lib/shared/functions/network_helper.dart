import 'dart:io';

import 'package:dio/dio.dart';
import 'package:std_attendance/models/models.dart';
import 'package:std_attendance/shared/settings.dart';

Future<Response<dynamic>> sendPost<T>(T object,
    {String controller = '', String action = "Create"}) {
  var dio = Dio();
  dio.options.headers['Authorization'] = 'Bearer ${user!.token}';
  dio.options.headers['Content-Type'] = 'application/json';
  dio.options.headers['Accept'] = 'application/json; charset=utf-8';
  return dio.post("$host$controller/$action", data: object);
}

Future<List<T>> fetchFromServer<T>(
    {String controller = '',
    required T Function(Map<String, dynamic>) fromJson,
    ApiRequest? headers,
    String action = "List"}) async {
  var dio = Dio();
  dio.options.headers['Content-Type'] = 'application/json; charset=utf-8';
  dio.options.headers['Accept'] = 'application/json; charset=utf-8';
  dio.options.headers['Authorization'] = 'Bearer ${user!.token}';

  var response = await dio.get("$host$controller/$action",
      queryParameters: headers?.toJson());
  var data = ApiResponse.fromJson(response.data, fromJson);
  return data.data!;
}

Future<Response<dynamic>> sendPut<T>(String controller, dynamic object) {
  var dio = Dio();
  dio.options.headers['Authorization'] = 'Bearer ${user!.token}';
  dio.options.headers['Content-Type'] = 'application/json';
  dio.options.headers['Accept'] = 'application/json; charset=utf-8';

  return dio.put("$host$controller/Update/${object.id}", data: object);
}

Future<bool> checkInternetConnection() async {
  try {
    final result = await InternetAddress.lookup('stdattdc.bsite.net');
    if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
      return true;
    } else {
      return false;
    }
  } catch (_) {
    return false;
  }
}
