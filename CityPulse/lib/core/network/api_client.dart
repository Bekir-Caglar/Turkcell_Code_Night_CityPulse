import 'package:dio/dio.dart';
import 'package:citypulse/core/constants/api_constants.dart';

class ApiClient {
  static const String baseUrl = ApiConstants.baseUrl;

  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(
        seconds: 30,
      ), // Increased from 10 to 30 seconds
      receiveTimeout: const Duration(
        seconds: 30,
      ), // Increased from 10 to 30 seconds
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        // CORS headers
        'Access-Control-Allow-Origin': '*',
        'Access-Control-Allow-Methods': 'GET, POST, PUT, DELETE, OPTIONS',
        'Access-Control-Allow-Headers': 'Origin, Content-Type, X-Auth-Token',
      },
    ),
  );

  ApiClient() {
    _dio.interceptors.add(
      LogInterceptor(requestBody: true, responseBody: true),
    );
  }

  Future<Response> get(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) async {
    return await _dio.get(path, queryParameters: queryParameters);
  }

  Future<Response> post(String path, {dynamic data}) async {
    return await _dio.post(path, data: data);
  }
}
