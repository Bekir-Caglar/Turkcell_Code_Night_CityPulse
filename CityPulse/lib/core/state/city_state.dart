class CityState {
  static final CityState _instance = CityState._internal();

  factory CityState() {
    return _instance;
  }

  CityState._internal();

  String _currentCity = 'İstanbul';
  Map<String, int> _turkishCitiesMap = {};

  String get currentCity => _currentCity;
  Map<String, int> get turkishCitiesMap => _turkishCitiesMap;

  void setCurrentCity(String city) {
    _currentCity = city;
  }

  void setTurkishCitiesMap(Map<String, int> citiesMap) {
    _turkishCitiesMap = citiesMap;
  }

  int? getCurrentCityId() {
    return _turkishCitiesMap[_currentCity];
  }
}
