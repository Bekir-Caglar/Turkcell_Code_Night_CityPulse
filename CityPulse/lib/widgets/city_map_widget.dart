import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:citypulse/core/theme/app_theme.dart';
import 'package:geolocator/geolocator.dart';

class CityMapWidget extends StatefulWidget {
  final String currentCity;
  final Position? userPosition;
  final Map<String, int>? alerts;

  const CityMapWidget({
    super.key,
    required this.currentCity,
    this.userPosition,
    this.alerts,
  });
  @override
  CityMapWidgetState createState() => CityMapWidgetState();
}

class CityMapWidgetState extends State<CityMapWidget> {
  late final MapController _mapController;

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
  }

  @override
  void didUpdateWidget(covariant CityMapWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    // If userPosition changed, move map center to user position
    if (widget.userPosition != null &&
        widget.userPosition != oldWidget.userPosition) {
      _moveToUserPosition(widget.userPosition!);
    }
  }

  void _moveToUserPosition(Position pos) {
    _mapController.move(LatLng(pos.latitude, pos.longitude), 13.0);
  }

  // Public method to move map to a city's coordinates
  void moveToCity(String cityName) {
    final coords = _getCityCoordinates(cityName);
    if (coords != null) {
      _mapController.move(LatLng(coords[0], coords[1]), 13.0);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Kullanıcının konumuna göre başlangıç merkezi belirle
    LatLng initialCenter;
    double initialZoom = 10.0;

    if (widget.userPosition != null) {
      initialCenter = LatLng(
        widget.userPosition!.latitude,
        widget.userPosition!.longitude,
      );
    } else {
      // Şehir koordinatlarına göre merkez belirle
      final cityCoords = _getCityCoordinates(widget.currentCity);
      if (cityCoords != null) {
        initialCenter = LatLng(cityCoords[0], cityCoords[1]);
      } else {
        initialCenter = const LatLng(39.0, 35.0); // Turkey center
        initialZoom = 6.0;
      }
    }

    return Container(
      height: 200,
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: FlutterMap(
          mapController: _mapController,
          options: MapOptions(
            initialCenter: initialCenter,
            initialZoom: initialZoom,
          ),
          children: [
            TileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              userAgentPackageName: 'com.example.citypulse',
            ),
            MarkerLayer(
              markers: [
                // Kullanıcı konumu markeri
                if (widget.userPosition != null)
                  Marker(
                    point: LatLng(
                      widget.userPosition!.latitude,
                      widget.userPosition!.longitude,
                    ),
                    width: 80,
                    height: 80,
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppColors.primaryBlue,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primaryBlue.withOpacity(0.5),
                                blurRadius: 8,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.my_location,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.2),
                                blurRadius: 4,
                              ),
                            ],
                          ),
                          child: const Text(
                            'Konumunuz',
                            style: TextStyle(
                              fontSize: 8,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primaryBlue,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                // Istanbul - Good status
                _buildMarker(
                  position: const LatLng(41.0082, 28.9784),
                  label: 'İstanbul',
                  status: CityStatus.good,
                ),
                // Ankara - Warning status
                _buildMarker(
                  position: const LatLng(39.9334, 32.8597),
                  label: 'Ankara',
                  status: CityStatus.warning,
                ),
                // Izmir - Excellent status
                _buildMarker(
                  position: const LatLng(38.4192, 27.1287),
                  label: 'İzmir',
                  status: CityStatus.excellent,
                ),
                // Antalya - Good status
                _buildMarker(
                  position: const LatLng(36.8969, 30.7133),
                  label: 'Antalya',
                  status: CityStatus.good,
                ),
                // Bursa - Critical status
                _buildMarker(
                  position: const LatLng(40.1826, 29.0665),
                  label: 'Bursa',
                  status: CityStatus.critical,
                ),
                // Uyarı marker'ları
                ...?widget.alerts?.entries.map((entry) {
                  final city = entry.key;
                  final count = entry.value;
                  final coords = _getCityCoordinates(city);
                  if (coords != null) {
                    return _buildMarker(
                      position: LatLng(coords[0], coords[1]),
                      label: '$city\nUyarı: $count',
                      status: CityStatus.warning,
                    );
                  }
                  return null;
                }).whereType<Marker>(),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Marker _buildMarker({
    required LatLng position,
    required String label,
    required CityStatus status,
  }) {
    Color markerColor;
    IconData markerIcon;

    switch (status) {
      case CityStatus.excellent:
        markerColor = AppColors.successGreen;
        markerIcon = Icons.check_circle;
        break;
      case CityStatus.good:
        markerColor = AppColors.accentBlue;
        markerIcon = Icons.circle;
        break;
      case CityStatus.warning:
        markerColor = AppColors.primaryYellow;
        markerIcon = Icons.warning;
        break;
      case CityStatus.critical:
        markerColor = AppColors.alertRed;
        markerIcon = Icons.error;
        break;
    }

    return Marker(
      point: position,
      width: 80,
      height: 80,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: markerColor,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: markerColor.withOpacity(0.5),
                  blurRadius: 8,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Icon(markerIcon, color: Colors.white, size: 20),
          ),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 4),
              ],
            ),
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<double>? _getCityCoordinates(String cityName) {
    final Map<String, List<double>> cityCoordinates = {
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

    return cityCoordinates[cityName];
  }
}

enum CityStatus { excellent, good, warning, critical }
