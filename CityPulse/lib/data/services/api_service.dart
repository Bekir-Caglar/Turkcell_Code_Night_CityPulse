import 'package:citypulse/core/network/api_client.dart';
import 'package:citypulse/data/models/alert.dart';
import 'package:citypulse/data/models/city_summary.dart';
import 'package:citypulse/data/models/feedback.dart';

class ApiService {
  final ApiClient _apiClient = ApiClient();

  Future<CitySummary> getCitySummary(int cityId) async {
    final response = await _apiClient.get('/cities/$cityId/summary');
    return CitySummary.fromJson(response.data);
  }

  Future<List<Alert>> getAlerts() async {
    final response = await _apiClient.get('/alerts');
    final List<dynamic> data = response.data;
    return data.map((json) => Alert.fromJson(json)).toList();
  }

  Future<void> postFeedback(FeedbackModel feedback) async {
    await _apiClient.post('/feedback', data: feedback.toJson());
  }
}
