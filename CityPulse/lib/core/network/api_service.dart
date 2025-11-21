import 'package:citypulse/core/constants/api_constants.dart';
import 'package:citypulse/core/network/api_client.dart';
import 'package:citypulse/core/models/top_green_cities.dart';
import 'package:dio/dio.dart';

class ApiService {
  final ApiClient _apiClient = ApiClient();

  // Find City by Location API
  Future<Map<String, dynamic>> findCityByLocation(
    double latitude,
    double longitude,
  ) async {
    try {
      final response = await _apiClient.get(
        ApiConstants.locationFindCityGet,
        queryParameters: {'latitude': latitude, 'longitude': longitude},
      );
      return response.data;
    } catch (e) {
      if (e is DioException) {
        print('Dio Error: ${e.type} - ${e.message}');
        if (e.response != null) {
          print('Response status: ${e.response?.statusCode}');
          print('Response data: ${e.response?.data}');
        }
      }
      throw Exception('Failed to find city by location: $e');
    }
  }

  // Top Green Cities API
  Future<TopGreenCitiesResponse> getTopGreenCities() async {
    try {
      final response = await _apiClient.get(ApiConstants.topGreenCities);
      return TopGreenCitiesResponse.fromJson(response.data);
    } catch (e) {
      if (e is DioException) {
        print('Dio Error: ${e.type} - ${e.message}');
        if (e.response != null) {
          print('Response status: ${e.response?.statusCode}');
          print('Response data: ${e.response?.data}');
        }
      }
      throw Exception('Failed to load top green cities: $e');
    }
  }

  Future<Map<String, dynamic>> getCityMetrics(String cityId) async {
    try {
      final endpoint = ApiConstants.cityMetrics.replaceAll('{id}', cityId);
      final response = await _apiClient.get(endpoint);
      return response.data;
    } catch (e) {
      throw Exception('Failed to load city metrics: $e');
    }
  }

  // All Cities API
  Future<Map<String, dynamic>> getCities() async {
    try {
      final response = await _apiClient.get(ApiConstants.cities);
      return response.data;
    } catch (e) {
      throw Exception('Failed to load cities: $e');
    }
  }

  // Submit Feedback API
  Future<Map<String, dynamic>> submitFeedback({
    required String cityId,
    required String userId,
    required String message,
    required String timestamp,
  }) async {
    try {
      final endpoint = ApiConstants.feedbackSubmit;
      final data = {
        'city_id': cityId,
        'user_id': userId,
        'message': message,
        'timestamp': timestamp,
      };
      print('Submitting feedback: $data');
      final response = await _apiClient.post(endpoint, data: data);
      print('Feedback submit response: ${response.data}');
      return response.data;
    } catch (e) {
      if (e is DioException) {
        print('Dio Error: ${e.type} - ${e.message}');
        if (e.response != null) {
          print('Response status: ${e.response?.statusCode}');
          print('Response data: ${e.response?.data}');
        }
      }
      throw Exception('Failed to submit feedback: $e');
    }
  }

  // Get Notifications API
  Future<Map<String, dynamic>> getNotifications() async {
    try {
      final response = await _apiClient.get(ApiConstants.notifications);
      return response.data;
    } catch (e) {
      throw Exception('Failed to load notifications: $e');
    }
  }

  // City Statistics Summary API
  Future<Map<String, dynamic>> getCityStatisticsSummary(String cityId) async {
    try {
      final endpoint = ApiConstants.cityStatisticsSummary.replaceAll(
        '{city_id}',
        cityId,
      );
      print('API Endpoint: $endpoint');
      final response = await _apiClient.get(endpoint);
      print('Raw API Response: ${response.data}');
      return response.data;
    } catch (e) {
      if (e is DioException) {
        print('Dio Error: ${e.type} - ${e.message}');
        if (e.response != null) {
          print('Response status: ${e.response?.statusCode}');
          print('Response data: ${e.response?.data}');
        }
      }
      throw Exception('Failed to load city statistics: $e');
    }
  }

  // Get City Scores API
  Future<List<Map<String, dynamic>>> getCityScores(String cityId) async {
    try {
      final endpoint = ApiConstants.scoresByCity.replaceAll(
        '{city_id}',
        cityId,
      );
      print('City Scores API Endpoint: $endpoint');
      final response = await _apiClient.get(endpoint);
      print('City Scores API Response: ${response.data}');
      final data = response.data['data'] as List<dynamic>;
      return data.map((e) => e as Map<String, dynamic>).toList();
    } catch (e) {
      if (e is DioException) {
        print('Dio Error: ${e.type} - ${e.message}');
        if (e.response != null) {
          print('Response status: ${e.response?.statusCode}');
          print('Response data: ${e.response?.data}');
        }
      }
      throw Exception('Failed to load city scores: $e');
    }
  }

  // Location City Coordinates API
  Future<Map<String, dynamic>> getLocationCityCoordinates(String cityId) async {
    try {
      final endpoint = ApiConstants.locationCityCoordinates.replaceAll(
        '{city_id}',
        cityId,
      );
      print('Location City Coordinates API Endpoint: $endpoint');
      final response = await _apiClient.get(endpoint);
      print('Location City Coordinates API Response: ${response.data}');
      return response.data;
    } catch (e) {
      if (e is DioException) {
        print('Dio Error: ${e.type} - ${e.message}');
        if (e.response != null) {
          print('Response status: ${e.response?.statusCode}');
          print('Response data: ${e.response?.data}');
        }
      }
      throw Exception('Failed to load city coordinates: $e');
    }
  }

  Future<Map<String, dynamic>> getFeedback() async {
    try {
      final response = await _apiClient.get(ApiConstants.feedback);
      print('Feedback API Response: ${response.data}');
      return response.data;
    } catch (e) {
      if (e is DioException) {
        print('Dio Error: ${e.type} - ${e.message}');
        if (e.response != null) {
          print('Response status: ${e.response?.statusCode}');
          print('Response data: ${e.response?.data}');
        }
      }
      throw Exception('Failed to load feedback: $e');
    }
  }
}
