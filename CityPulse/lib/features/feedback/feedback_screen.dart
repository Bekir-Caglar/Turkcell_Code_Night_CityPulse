import 'package:flutter/material.dart';
import 'package:citypulse/core/theme/app_theme.dart';
import 'package:citypulse/core/network/api_service.dart';
import 'package:citypulse/core/state/city_state.dart';
import 'package:gap/gap.dart';

class FeedbackScreen extends StatefulWidget {
  const FeedbackScreen({super.key});

  @override
  State<FeedbackScreen> createState() => _FeedbackScreenState();
}

class _FeedbackScreenState extends State<FeedbackScreen> {
  final ApiService _apiService = ApiService();
  List<Map<String, dynamic>> _feedbacks = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadFeedback();
  }

  Future<void> _loadFeedback() async {
    try {
      final response = await _apiService.getFeedback();
      if (response['success'] == true && response['data'] != null) {
        setState(() {
          _feedbacks = List<Map<String, dynamic>>.from(response['data']);
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Feedback yüklenirken hata: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  String _getCityNameFromId(String cityId) {
    final cityMap = CityState().turkishCitiesMap;
    // city_id string, map'te int olarak tutuyoruz, o yüzden parse etmem gerekiyor
    final cityIdInt = int.tryParse(cityId);
    if (cityIdInt != null) {
      // Map'te value'dan key'i bulmam gerekiyor
      for (final entry in cityMap.entries) {
        if (entry.value == cityIdInt) {
          return entry.key;
        }
      }
    }
    return 'Bilinmeyen Şehir';
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'Trafik':
        return AppColors.alertRed;
      case 'Çevre':
        return AppColors.successGreen;
      case 'Bağlantı':
        return AppColors.primaryBlue;
      case 'Öneri':
        return AppColors.primaryYellow;
      default:
        return AppColors.textPrimary;
    }
  }

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'Trafik':
        return Icons.traffic;
      case 'Çevre':
        return Icons.air;
      case 'Bağlantı':
        return Icons.signal_cellular_alt;
      case 'Öneri':
        return Icons.lightbulb;
      default:
        return Icons.message;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Vatandaş Geri Bildirimleri'),
        backgroundColor: AppColors.primaryBlue,
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'BiP Vatandaş Bildirimleri',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: AppColors.primaryBlue,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Gap(8),
                  Text(
                    'Şehir sakinlerinin geri bildirimleri ve önerileri',
                    style: TextStyle(
                      color: AppColors.textPrimary.withOpacity(0.7),
                      fontSize: 14,
                    ),
                  ),
                  const Gap(16),
                  ..._feedbacks.map((feedback) => _buildFeedbackCard(feedback)),
                  const Gap(24),
                  _buildWordCloudSection(),
                ],
              ),
            ),
    );
  }

  Widget _buildFeedbackCard(Map<String, dynamic> feedback) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: _getCategoryColor(
                      feedback['category'],
                    ).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    _getCategoryIcon(feedback['category']),
                    color: _getCategoryColor(feedback['category']),
                    size: 20,
                  ),
                ),
                const Gap(12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        feedback['user'],
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      Text(
                        _getCityNameFromId(feedback['city_id']),
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textPrimary.withOpacity(0.6),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: _getCategoryColor(
                      feedback['category'],
                    ).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    feedback['category'],
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: _getCategoryColor(feedback['category']),
                    ),
                  ),
                ),
              ],
            ),
            const Gap(12),
            Text(
              feedback['message'],
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textPrimary,
              ),
            ),
            const Gap(8),
            Text(
              _formatTimestamp(feedback['timestamp']),
              style: TextStyle(
                fontSize: 12,
                color: AppColors.textPrimary.withOpacity(0.5),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWordCloudSection() {
    // Simple word frequency analysis
    final words = <String, int>{};
    for (final feedback in _feedbacks) {
      final message = feedback['message'] as String;
      final wordList = message.toLowerCase().split(RegExp(r'\s+'));
      for (final word in wordList) {
        if (word.length > 3) {
          // Filter short words
          words[word] = (words[word] ?? 0) + 1;
        }
      }
    }

    final sortedWords = words.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'En Çok Konuşulan Konular',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppColors.primaryBlue,
          ),
        ),
        const Gap(12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: sortedWords.take(10).map((entry) {
            final fontSize = 12.0 + (entry.value * 2.0);
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.primaryBlue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                '${entry.key} (${entry.value})',
                style: TextStyle(
                  fontSize: fontSize.clamp(12, 20),
                  color: AppColors.primaryBlue,
                  fontWeight: FontWeight.w500,
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  String _formatTimestamp(String timestamp) {
    try {
      final dateTime = DateTime.parse(timestamp);
      return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return timestamp;
    }
  }
}
