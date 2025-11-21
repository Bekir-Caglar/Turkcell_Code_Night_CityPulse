import 'package:flutter/material.dart';
import 'package:citypulse/core/theme/app_theme.dart';
import 'package:citypulse/widgets/city_map_widget.dart';
import 'package:citypulse/widgets/score_card_widget.dart';
import 'package:citypulse/features/feedback/feedback_screen.dart';
import 'package:citypulse/core/network/api_service.dart';
import 'package:citypulse/core/models/top_green_cities.dart';
import 'package:citypulse/core/state/city_state.dart';
import 'package:gap/gap.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:math';
import 'package:dio/dio.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _currentCity = 'İstanbul'; // Default city
  Position? _currentPosition;
  bool _isLoadingLocation = false;
  LocationPermission? _permissionStatus;
  bool _hasInitializedLocation = false;

  final GlobalKey<CityMapWidgetState> _mapKey = GlobalKey<CityMapWidgetState>();

  final ApiService _apiService = ApiService();
  TopGreenCitiesResponse? _topGreenCitiesResponse;
  bool _isLoadingTopCities = false;
  Map<String, dynamic>? _cityStatistics;
  bool _isLoadingStatistics = false;

  Map<String, int> _cities = {}; // API'den yüklenen şehirler
  Map<String, int> _cityAlerts = {}; // Şehir uyarıları

  final Map<String, int> _turkishCities = {
    'Adana': 1,
    'Adıyaman': 2,
    'Afyonkarahisar': 3,
    'Ağrı': 4,
    'Amasya': 5,
    'Ankara': 6,
    'Antalya': 7,
    'Artvin': 8,
    'Aydın': 9,
    'Balıkesir': 10,
    'Bilecik': 11,
    'Bingöl': 12,
    'Bitlis': 13,
    'Bolu': 14,
    'Burdur': 15,
    'Bursa': 16,
    'Çanakkale': 17,
    'Çankırı': 18,
    'Çorum': 19,
    'Denizli': 20,
    'Diyarbakır': 21,
    'Edirne': 22,
    'Elazığ': 23,
    'Erzincan': 24,
    'Erzurum': 25,
    'Eskişehir': 26,
    'Gaziantep': 27,
    'Giresun': 28,
    'Gümüşhane': 29,
    'Hakkari': 30,
    'Hatay': 31,
    'Isparta': 32,
    'Mersin': 33,
    'İstanbul': 34,
    'İzmir': 35,
    'Kars': 36,
    'Kastamonu': 37,
    'Kayseri': 38,
    'Kırklareli': 39,
    'Kırşehir': 40,
    'Kocaeli': 41,
    'Konya': 42,
    'Kütahya': 43,
    'Malatya': 44,
    'Manisa': 45,
    'Kahramanmaraş': 46,
    'Mardin': 47,
    'Muğla': 48,
    'Muş': 49,
    'Nevşehir': 50,
    'Niğde': 51,
    'Ordu': 52,
    'Rize': 53,
    'Sakarya': 54,
    'Samsun': 55,
    'Siirt': 56,
    'Sinop': 57,
    'Sivas': 58,
    'Tekirdağ': 59,
    'Tokat': 60,
    'Trabzon': 61,
    'Tunceli': 62,
    'Şanlıurfa': 63,
    'Uşak': 64,
    'Van': 65,
    'Yozgat': 66,
    'Zonguldak': 67,
    'Aksaray': 68,
    'Bayburt': 69,
    'Karaman': 70,
    'Kırıkkale': 71,
    'Batman': 72,
    'Şırnak': 73,
    'Bartın': 74,
    'Ardahan': 75,
    'Iğdır': 76,
    'Yalova': 77,
    'Karabük': 78,
    'Kilis': 79,
    'Osmaniye': 80,
    'Düzce': 81,
  };

  // Bazı büyük şehirlerin koordinatları
  final Map<String, List<double>> _cityCoordinates = {
    'İstanbul': [41.0082, 28.9784],
    'Ankara': [39.9334, 32.8597],
    'İzmir': [38.4192, 27.1287],
    'Bursa': [40.1885, 29.0610],
    'Antalya': [36.8969, 30.7133],
    'Adana': [37.0000, 35.3213],
    'Konya': [37.8714, 32.4846],
    'Gaziantep': [37.0662, 37.3833],
    'Şanlıurfa': [37.1591, 38.7969],
    'Kayseri': [38.7312, 35.4787],
    'Mersin': [36.8121, 34.6415],
    'Eskişehir': [39.7767, 30.5206],
    'Diyarbakır': [37.9144, 40.2306],
    'Samsun': [41.2867, 36.3300],
    'Denizli': [37.7765, 29.0864],
    'Trabzon': [41.0027, 39.7168],
    'Erzurum': [39.9000, 41.2700],
    'Malatya': [38.3552, 38.3095],
    'Kahramanmaraş': [37.5858, 36.9371],
    'Van': [38.4891, 43.4089],
  };

  @override
  void initState() {
    super.initState();
    // Şehir map'ini singleton'a set et
    CityState().setTurkishCitiesMap(_turkishCities);
    CityState().setCurrentCity(_currentCity);
    // Konum iznini hemen isteme, widget build edildikten sonra iste
    _loadTopGreenCities();
  }

  Future<void> _loadTopGreenCities() async {
    setState(() {
      _isLoadingTopCities = true;
    });

    try {
      final response = await _apiService.getTopGreenCities();
      setState(() {
        _topGreenCitiesResponse = response;
        _isLoadingTopCities = false;
      });
    } catch (e) {
      print('❌ Top green cities API hatası: $e');
      if (e is DioException) {
        print('🔍 Dio Error Type: ${e.type}');
        print('🔍 Dio Error Message: ${e.message}');
        if (e.response != null) {
          print('🔍 Response Status Code: ${e.response?.statusCode}');
          print('🔍 Response Headers: ${e.response?.headers}');
          print('🔍 Response Data: ${e.response?.data}');
        } else {
          print('🔍 No response received');
        }
      }
      setState(() {
        _isLoadingTopCities = false;
      });
    }
  }

  Future<void> _onCitySelected(String city) async {
    setState(() {
      _currentCity = city;
    });
    CityState().setCurrentCity(city);

    // Haritayı şehir koordinatlarına götür
    _mapKey.currentState?.moveToCity(city);

    // Şehir istatistiklerini yükle
    await _loadCityStatistics(city);
  }

  Future<void> _loadCityStatistics(String cityName) async {
    setState(() {
      _isLoadingStatistics = true;
    });
    try {
      // Şehir adından plaka kodunu bul
      final cityPlate = _cities[cityName];
      if (cityPlate != null) {
        print('Şehir: $cityName, Plaka Kodu: $cityPlate');
        final cityId = cityPlate.toString().padLeft(2, '0');
        final response = await _apiService.getCityStatisticsSummary(cityId);
        print('API Response: $response');
        setState(() {
          _cityStatistics = response;
          _isLoadingStatistics = false;
        });
      } else {
        print('Şehir bulunamadı: $cityName');
        setState(() {
          _isLoadingStatistics = false;
        });
      }
    } catch (e) {
      print('Şehir istatistikleri yüklenirken hata: $e');
      // Hata durumunda null olarak bırak
      setState(() {
        _cityStatistics = null;
        _isLoadingStatistics = false;
      });
    }
  }

  Future<void> _loadCities() async {
    try {
      final response = await _apiService.getCities();
      final data = response['data'] as List<dynamic>;
      _cities = {
        for (var city in data) city['name'] as String: city['id'] as int,
      };
      print('Şehirler API\'den yüklendi: $_cities');
      setState(() {});
    } catch (e) {
      print('Şehirler API\'den yüklenemedi, hardcoded kullanılıyor: $e');
      // Fallback to hardcoded
      _cities = Map.from(_turkishCities);
      setState(() {});
    }
  }

  Future<void> _loadCityAlerts() async {
    for (final city in _turkishCities.keys) {
      final cityId = _turkishCities[city]!.toString().padLeft(2, '0');
      try {
        final scores = await _apiService.getCityScores(cityId);
        if (scores.isNotEmpty) {
          final lastScore = scores.last;
          final alerts = lastScore['alerts_count'] as int;
          if (alerts > 0) {
            _cityAlerts[city] = alerts;
          }
        }
      } catch (e) {
        print('Skor alınamadı $city: $e');
      }
    }
    print('Şehir uyarıları yüklendi: $_cityAlerts');
    setState(() {});
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Widget build edildikten sonra konum izni iste (sadece ilk kez)
    if (!_hasInitializedLocation) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _initializeLocation();
        _loadCities();
        _loadCityAlerts();
        _hasInitializedLocation = true;
      });
    }
  }

  Future<void> _initializeLocation() async {
    setState(() {
      _isLoadingLocation = true;
    });

    try {
      // Tüm platformlarda Geolocator kullanarak izin yönetimi
      LocationPermission permission = await Geolocator.checkPermission();
      setState(() {
        _permissionStatus = permission;
      });
      print('Konum izni durumu: $permission');

      if (permission == LocationPermission.denied) {
        print('Konum izni isteniyor...');
        permission = await Geolocator.requestPermission();
        setState(() {
          _permissionStatus = permission;
        });
        print('İzin sonucu: $permission');

        if (permission == LocationPermission.denied ||
            permission == LocationPermission.deniedForever) {
          setState(() {
            _isLoadingLocation = false;
          });
          if (permission == LocationPermission.deniedForever) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text('Konum izni kalıcı olarak reddedildi.'),
                action: SnackBarAction(
                  label: 'Ayarlar',
                  onPressed: () async => await Geolocator.openAppSettings(),
                ),
              ),
            );
          }
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        setState(() {
          _isLoadingLocation = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Konum izni kalıcı olarak reddedildi.'),
            action: SnackBarAction(
              label: 'Ayarlar',
              onPressed: () async => await Geolocator.openAppSettings(),
            ),
          ),
        );
        return;
      }

      // Konum servisi açık mı kontrolü
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      print('Konum servisi açık: $serviceEnabled');

      if (!serviceEnabled) {
        // Konum servisi kapalı, kullanıcıya dialog göster
        print('Konum servisi kapalı');
        setState(() {
          _isLoadingLocation = false;
        });
        _showLocationServiceDialog();
        return;
      }

      // Konum alma
      print('Konum alınıyor...');

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      print('Konum alındı: ${position.latitude}, ${position.longitude}');

      setState(() {
        _currentPosition = position;
      });

      // En yakın şehri bulma
      String? nearestCity = await _findNearestCity(
        position.latitude,
        position.longitude,
      );
      print('En yakın şehir: $nearestCity');

      if (nearestCity != null) {
        setState(() {
          _currentCity = nearestCity;
          _isLoadingLocation = false;
        });
        // Şehir bulunduğunda singleton'a set et ve istatistikleri yükle
        CityState().setCurrentCity(nearestCity);
        await _loadCityStatistics(nearestCity);
      } else {
        setState(() {
          _isLoadingLocation = false;
        });
      }
    } catch (e) {
      print('Konum alma hatası: $e');
      setState(() {
        _isLoadingLocation = false;
      });
      // Hata durumunda sessizce devam et
    }
  }

  Future<String?> _findNearestCity(double latitude, double longitude) async {
    try {
      final response = await _apiService.findCityByLocation(
        latitude,
        longitude,
      );
      // API response'dan şehir adını çıkar
      if (response['success'] == true && response['data'] != null) {
        return response['data']['city_name'] as String?;
      }
      return null;
    } catch (e) {
      print('Şehir arama hatası: $e');
      // API başarısız olursa fallback olarak eski metodu kullan
      return _findNearestCityFallback(latitude, longitude);
    }
  }

  String? _findNearestCityFallback(double latitude, double longitude) {
    String? nearestCity;
    double minDistance = double.infinity;

    _cityCoordinates.forEach((city, coords) {
      double distance = _calculateDistance(
        latitude,
        longitude,
        coords[0],
        coords[1],
      );
      if (distance < minDistance) {
        minDistance = distance;
        nearestCity = city;
      }
    });

    return nearestCity;
  }

  double _calculateDistance(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    const double earthRadius = 6371; // km
    double dLat = _degreesToRadians(lat2 - lat1);
    double dLon = _degreesToRadians(lon2 - lon1);
    double a =
        sin(dLat / 2) * sin(dLat / 2) +
        cos(_degreesToRadians(lat1)) *
            cos(_degreesToRadians(lat2)) *
            sin(dLon / 2) *
            sin(dLon / 2);
    double c = 2 * atan2(sqrt(1 - a), sqrt(a));
    return earthRadius * c;
  }

  double _degreesToRadians(double degrees) {
    return degrees * pi / 180;
  }

  void _showCitySelectionBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: Colors.grey, width: 0.5),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text(
                      'İptal',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),
                  const Text(
                    'Şehir Seçin',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryBlue,
                    ),
                  ),
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text(
                      'Tamam',
                      style: TextStyle(color: AppColors.primaryBlue),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: _cities.length,
                itemBuilder: (context, index) {
                  final city = _cities.keys.elementAt(index);
                  final isSelected = city == _currentCity;
                  return ListTile(
                    title: Text(city),
                    trailing: isSelected
                        ? const Icon(Icons.check, color: AppColors.primaryBlue)
                        : null,
                    onTap: () {
                      setState(() {
                        _currentCity = city;
                      });
                      // Şehir seçildiğinde koordinat al, haritayı götür ve istatistikleri yükle
                      _onCitySelected(city);
                      Navigator.pop(context);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Özel modal izin diyalogları kaldırıldı. Kalıcı reddedilme durumunda SnackBar ile 'Ayarlar' açılacak.

  void _showLocationServiceDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Konum Servisleri Kapalı'),
          content: const Text(
            'Haritada konumunuzu göstermek için konum servislerinin açık olması gerekir. '
            'Lütfen konum servislerini etkinleştirin.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Daha Sonra'),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(context);
                await Geolocator.openLocationSettings();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryBlue,
                foregroundColor: Colors.white,
              ),
              child: const Text('Konum Ayarları'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        title: const Text('Şehrin Nabzı'),
        actions: [
          Flexible(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Flexible(
                  child: TextButton.icon(
                    onPressed: _showCitySelectionBottomSheet,
                    icon: const Icon(Icons.location_on, color: Colors.white),
                    label: Text(
                      _currentCity,
                      style: const TextStyle(color: Colors.white),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                    ),
                  ),
                ),
                if (_isLoadingLocation)
                  Container(
                    width: 22,
                    height: 22,
                    margin: const EdgeInsets.only(right: 8),
                    child: const CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2.0,
                    ),
                  ),
                const Gap(4),
                // Permission indicator / action
                if (_permissionStatus == null ||
                    _permissionStatus == LocationPermission.denied)
                  IconButton(
                    icon: const Icon(
                      Icons.location_searching,
                      color: Colors.white,
                    ),
                    tooltip: 'Konum izni iste',
                    onPressed: () async => await _initializeLocation(),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                if (_permissionStatus == LocationPermission.deniedForever)
                  IconButton(
                    icon: const Icon(Icons.settings, color: Colors.white),
                    tooltip: 'Ayarlar',
                    onPressed: () async => await Geolocator.openAppSettings(),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.feedback, color: Colors.white),
            tooltip: 'Geri Bildirimler',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const FeedbackScreen()),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // City Selector in Top Bar removed from body because we have AppBar selector

            // Map Section
            CityMapWidget(
              key: _mapKey,
              currentCity: _currentCity,
              userPosition: _currentPosition,
              alerts: _cityAlerts,
            ),

            const Gap(16),

            // Top Green Cities Section
            _buildTopGreenCities(),

            const Gap(16),

            // Scores Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Şehir Skorları',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: AppColors.primaryBlue,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Gap(12),
                  _buildScoreCards(),
                ],
              ),
            ),

            const Gap(24),

            const Gap(24),
          ],
        ),
      ),
    );
  }

  Widget _buildScoreCards() {
    // İstatistikler yükleniyorsa loading göster
    if (_isLoadingStatistics) {
      return const Center(child: CircularProgressIndicator());
    }

    // İstatistik verisi yoksa hiçbir şey gösterme
    if (_cityStatistics == null) {
      return const SizedBox.shrink();
    }

    // API verilerini kullan (data objesi içinden)
    final data = _cityStatistics!['data'] as Map<String, dynamic>?;
    if (data == null) {
      return const SizedBox.shrink();
    }

    final trafficValue = data['avg_internet_usage_gb'] as double? ?? 0.0;
    final signalValue = data['avg_signal_strength'] as double? ?? 0.0;
    final airQualityValue = data['avg_air_quality'] as double? ?? 0.0;
    final paycellValue = data['avg_daily_transactions'] as double? ?? 0.0;

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: ScoreCardWidget(
                title: 'Trafik',
                value: trafficValue,
                unit: 'GB',
                icon: Icons.traffic,
                color: AppColors.primaryBlue,
              ),
            ),
            const Gap(12),
            Expanded(
              child: ScoreCardWidget(
                title: 'Sinyal',
                value: signalValue,
                unit: '%',
                icon: Icons.signal_cellular_alt,
                color: AppColors.accentBlue,
              ),
            ),
          ],
        ),
        const Gap(12),
        Row(
          children: [
            Expanded(
              child: ScoreCardWidget(
                title: 'Hava Kalitesi',
                value: airQualityValue,
                unit: 'AQI',
                icon: Icons.air,
                color: AppColors.successGreen,
              ),
            ),
            const Gap(12),
            Expanded(
              child: ScoreCardWidget(
                title: 'Paycell Kullanımı',
                value: paycellValue,
                unit: 'GB',
                icon: Icons.account_balance_wallet,
                color: AppColors.primaryYellow,
              ),
            ),
          ],
        ),
        const Gap(16),
        // Ek bilgi kartları
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: const Text(
            'Bugün fiber hat sayesinde 2.4 kg CO₂ tasarrufu yapıldı.',
            style: TextStyle(
              fontSize: 14,
              color: AppColors.primaryBlue,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ),
        const Gap(12),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: const Text(
            'TV+ yerine mobil bağlantı tercih eden kullanıcı sayısı: 1,200.',
            style: TextStyle(
              fontSize: 14,
              color: AppColors.primaryBlue,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }

  Widget _buildTopGreenCities() {
    // API verisi yükleniyorsa loading göster
    if (_isLoadingTopCities) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.eco, color: AppColors.successGreen, size: 24),
                const Gap(8),
                Text(
                  'Haftanın Yeşil Şehirleri',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: AppColors.primaryBlue,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const Gap(12),
            const Center(child: CircularProgressIndicator()),
          ],
        ),
      );
    }

    // API verisi varsa onu kullan, yoksa boş liste
    final cities = _topGreenCitiesResponse?.data.top3GreenCities ?? [];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.eco, color: AppColors.successGreen, size: 24),
              const Gap(8),
              Text(
                'Haftanın Yeşil Şehirleri',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: AppColors.primaryBlue,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const Gap(12),
          SizedBox(
            height: 140, // Slightly taller for better visibility
            child: cities.isEmpty
                ? const Center(
                    child: Text(
                      'Şu anda veri yüklenemiyor',
                      style: TextStyle(color: Colors.grey),
                    ),
                  )
                : ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: cities.length,
                    itemBuilder: (context, index) {
                      final city = cities[index];
                      final rank = city.rank;
                      Color cardColor;
                      Color textColor = Colors
                          .black; // Changed to black for better readability
                      IconData rankIcon;

                      switch (rank) {
                        case 1:
                          cardColor = const Color(0xFFFFD700); // Gold
                          rankIcon = Icons.emoji_events;
                          break;
                        case 2:
                          cardColor = const Color(0xFFC0C0C0); // Silver
                          rankIcon = Icons.emoji_events;
                          break;
                        case 3:
                          cardColor = const Color(0xFFCD7F32); // Bronze
                          rankIcon = Icons.emoji_events;
                          break;
                        default:
                          cardColor = AppColors.primaryBlue;
                          rankIcon = Icons.star;
                      }

                      return Container(
                        width: 180,
                        margin: const EdgeInsets.only(right: 12),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [cardColor.withOpacity(0.8), cardColor],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: cardColor.withOpacity(0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(rankIcon, color: textColor, size: 20),
                                  const Spacer(),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.black.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      '${city.sustainabilityScore.toStringAsFixed(1)}',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: textColor,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const Spacer(),
                              Text(
                                city.cityName,
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: textColor,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const Gap(4),
                              Text(
                                city.region,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: textColor.withOpacity(0.8),
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const Gap(8),
                              Container(
                                height: 4,
                                decoration: BoxDecoration(
                                  color: Colors.black.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(2),
                                ),
                                child: FractionallySizedBox(
                                  alignment: Alignment.centerLeft,
                                  widthFactor: city.sustainabilityScore / 100,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: Colors.black.withOpacity(0.8),
                                      borderRadius: BorderRadius.circular(2),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
          const Gap(16),
          // Ek bilgi kartları taşındı
        ],
      ),
    );
  }
}
