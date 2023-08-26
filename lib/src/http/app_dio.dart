import 'dart:ffi';
import 'dart:io';

import 'package:dio/adapter.dart';
import 'package:dio/dio.dart';

mixin AppDio {
  static Future<Dio> getConnection({bool isAuth = false}) async {
    final Dio dio = Dio();

    final Map<String, String> headers = <String, String>{};

    String token = "";

    if (isAuth) {
      headers["Authorization"] = "Bearer $token";
    }

    dio.options = BaseOptions();
    dio.options.receiveTimeout = 30000;
    dio.options.sendTimeout = 15000;
    dio.options.headers = headers;

    (dio.httpClientAdapter as DefaultHttpClientAdapter).onHttpClientCreate =
        (HttpClient client) {
      client.badCertificateCallback =
          (X509Certificate cert, String host, int port) {
        return true;
      };
    };

    dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        await onRequest(options);
        handler.next(options);
      },
      onResponse: onResponse,
      onError: (error, handler) async {
        onError(dio, error, handler);
      },
    ));

    return dio;
  }

  static Future<void> onRequest(RequestOptions requestOptions) async {
    requestOptions.headers["Accept"] = 'application/json';
    requestOptions.headers["Content-Type"] = 'Application/json';

    print('---------- Request Log ----------');
    print(requestOptions.uri);
  }

  static void onResponse(
      Response<dynamic> response, ResponseInterceptorHandler handler) {
    print('---------- Response Log ----------');
    print(response.data);
    handler.next(response);
  }

  static void onError(
      Dio dio, DioError error, ErrorInterceptorHandler handler) {
    print('---------- Error Log ----------');
    print(error.response);
    handler.next(error);
  }
}
