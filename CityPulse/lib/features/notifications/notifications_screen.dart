import 'package:flutter/material.dart';
import 'package:citypulse/core/theme/app_theme.dart';
import 'package:citypulse/core/network/api_service.dart';
import 'package:citypulse/core/state/city_state.dart';
import 'package:gap/gap.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final ApiService _apiService = ApiService();
  Map<String, dynamic>? _cityStatistics;
  bool _isLoading = true;

  // CityState'den şehir bilgilerini al
  String get _currentCity => CityState().currentCity;
  Map<String, int> get _turkishCitiesMap => CityState().turkishCitiesMap;

  @override
  void initState() {
    super.initState();
    _loadCityStatistics();
  }

  Future<void> _loadCityStatistics() async {
    try {
      final cityId = CityState().getCurrentCityId();
      if (cityId != null) {
        final cityIdStr = cityId.toString().padLeft(2, '0');
        final response = await _apiService.getCityStatisticsSummary(cityIdStr);
        setState(() {
          _cityStatistics = response;
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Şehir istatistikleri yüklenirken hata: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('$_currentCity Uyarıları'),
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
                    'Şehir Verileri',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: AppColors.primaryBlue,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Gap(12),
                  ..._buildMetricCards(),
                  const Gap(24),
                  Text(
                    'Uyarılar',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: AppColors.primaryBlue,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Gap(12),
                  ..._buildAlerts(),
                ],
              ),
            ),
    );
  }

  List<Widget> _buildMetricCards() {
    if (_cityStatistics == null) {
      return [const Text('Şehir verileri yüklenemedi')];
    }

    final data = _cityStatistics!['data'] as Map<String, dynamic>?;
    if (data == null) {
      return [const Text('Şehir verileri bulunamadı')];
    }

    final trafficValue = data['avg_internet_usage_gb'] as double? ?? 0.0;
    final signalValue = data['avg_signal_strength'] as double? ?? 0.0;
    final airQualityValue = data['avg_air_quality'] as double? ?? 0.0;
    final paycellValue = data['avg_daily_transactions'] as double? ?? 0.0;

    return [
      _buildMetricCard(
        title: 'İnternet Trafiği',
        value: trafficValue,
        unit: 'GB',
        maxValue: 200.0,
        color: _getColorForTraffic(trafficValue),
      ),
      const Gap(12),
      _buildMetricCard(
        title: 'Sinyal Gücü',
        value: signalValue,
        unit: '%',
        maxValue: 100.0,
        color: _getColorForSignal(signalValue),
      ),
      const Gap(12),
      _buildMetricCard(
        title: 'Hava Kalitesi',
        value: airQualityValue,
        unit: 'AQI',
        maxValue: 150.0,
        color: _getColorForAirQuality(airQualityValue),
      ),
      const Gap(12),
      _buildMetricCard(
        title: 'Günlük İşlemler',
        value: paycellValue,
        unit: 'adet',
        maxValue: 5000.0,
        color: _getColorForPaycell(paycellValue),
      ),
    ];
  }

  List<Widget> _buildAlerts() {
    if (_cityStatistics == null) {
      return [const Text('Uyarılar yüklenemedi')];
    }

    final data = _cityStatistics!['data'] as Map<String, dynamic>?;
    if (data == null) {
      return [const Text('Uyarı verileri bulunamadı')];
    }

    final signalValue = data['avg_signal_strength'] as double? ?? 0.0;
    final trafficValue = data['avg_internet_usage_gb'] as double? ?? 0.0;
    final airQualityValue = data['avg_air_quality'] as double? ?? 0.0;

    final alerts = <Widget>[];

    // Sinyal gücü < 40 → bağlantı sorunu uyarısı
    if (signalValue < 40) {
      alerts.add(
        _buildRecommendationCard(
          icon: Icons.signal_cellular_connected_no_internet_4_bar,
          title: 'Bağlantı Sorunu Uyarısı',
          description:
              'Sinyal gücü çok düşük (${signalValue.toStringAsFixed(1)}%). Bağlantı sorunları yaşayabilirsiniz.',
          color: AppColors.alertRed,
        ),
      );
      alerts.add(const Gap(12));
    }

    // İnternet trafiği > 120GB → yoğunluk bildirimi
    if (trafficValue > 120) {
      alerts.add(
        _buildRecommendationCard(
          icon: Icons.traffic,
          title: 'Yoğunluk Bildirimi',
          description:
              'İnternet trafiği yüksek (${trafficValue.toStringAsFixed(1)}GB). Ağ yoğunluğu nedeniyle yavaşlamalar olabilir.',
          color: AppColors.primaryYellow,
        ),
      );
      alerts.add(const Gap(12));
    }

    // Hava kalitesi < 50 → 'Yeşil Alan Önerisi'
    if (airQualityValue < 50) {
      alerts.add(
        _buildRecommendationCard(
          icon: Icons.park,
          title: 'Yeşil Alan Önerisi',
          description:
              'Hava kalitesi düşük (${airQualityValue.toStringAsFixed(1)} AQI). Daha fazla yeşil alan ve temiz hava için şehir planlaması önerilir.',
          color: AppColors.successGreen,
        ),
      );
      alerts.add(const Gap(12));
    }

    if (alerts.isEmpty) {
      alerts.add(const Text('Şu anda aktif uyarı bulunmuyor'));
    }

    return alerts;
  }

  Color _getColorForTraffic(double value) {
    if (value > 150) return AppColors.alertRed;
    if (value > 100) return AppColors.primaryYellow;
    return AppColors.successGreen;
  }

  Color _getColorForSignal(double value) {
    if (value < 50) return AppColors.alertRed;
    if (value < 80) return AppColors.primaryYellow;
    return AppColors.successGreen;
  }

  Color _getColorForAirQuality(double value) {
    if (value > 100) return AppColors.alertRed;
    if (value > 50) return AppColors.primaryYellow;
    return AppColors.successGreen;
  }

  Color _getColorForPaycell(double value) {
    if (value > 70) return AppColors.alertRed;
    if (value > 40) return AppColors.primaryYellow;
    return AppColors.successGreen;
  }

  Widget _buildMetricCard({
    required String title,
    required double value,
    required String unit,
    required double maxValue,
    required Color color,
  }) {
    double percentage = (value / maxValue).clamp(0.0, 1.0);
    // Bar'ın pointer'ının rengini belirle
    Color barColor;
    if (percentage < 0.33) {
      barColor = AppColors.alertRed;
    } else if (percentage < 0.66) {
      barColor = AppColors.primaryYellow;
    } else {
      barColor = AppColors.successGreen;
    }
    return Container(
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
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  '${value.toStringAsFixed(1)} $unit',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: barColor,
                  ),
                ),
              ],
            ),
            const Gap(12),
            LayoutBuilder(
              builder: (context, constraints) {
                return SizedBox(
                  height: 20,
                  child: Stack(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            flex: 1,
                            child: Container(
                              decoration: BoxDecoration(
                                color: AppColors.alertRed,
                                borderRadius: const BorderRadius.only(
                                  topLeft: Radius.circular(10),
                                  bottomLeft: Radius.circular(10),
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 1,
                            child: Container(color: AppColors.primaryYellow),
                          ),
                          Expanded(
                            flex: 1,
                            child: Container(
                              decoration: BoxDecoration(
                                color: AppColors.successGreen,
                                borderRadius: const BorderRadius.only(
                                  topRight: Radius.circular(10),
                                  bottomRight: Radius.circular(10),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      Positioned(
                        left: percentage * constraints.maxWidth - 1,
                        top: 0,
                        bottom: 0,
                        child: Container(width: 2, color: Colors.black),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecommendationCard({
    required IconData icon,
    required String title,
    required String description,
    required Color color,
  }) {
    return Container(
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
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            const Gap(16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const Gap(4),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.textPrimary.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
