class ApiConstants {
  // Base URLs
  static const String baseUrl = 'http://localhost:8000';
  static const String apiVersion = '/api';

  // Root endpoint
  static const String root = '/';

  // Cities endpoints
  static const String cities = '$apiVersion/cities';
  static const String citiesById = '$apiVersion/cities/{city_id}';

  // Stats endpoints
  static const String stats = '$apiVersion/stats';
  static const String statsByCity = '$apiVersion/stats/{city_id}';
  static const String statsByCityDate = '$apiVersion/stats/{city_id}/{date}';

  // Feedback endpoints
  static const String feedbackSubmit = '$apiVersion/feedback/submit';
  static const String feedback = '$apiVersion/feedback';
  static const String feedbackById = '$apiVersion/feedback/{feedback_id}';
  static const String feedbackByCity = '$apiVersion/feedback/city/{city_id}';

  // Categories endpoints
  static const String categories = '$apiVersion/categories';
  static const String categoriesByName =
      '$apiVersion/categories/{category_name}';

  // Weather endpoints
  static const String weather = '$apiVersion/weather';
  static const String weatherByCity = '$apiVersion/weather/{city_id}';
  static const String weatherByCityDate =
      '$apiVersion/weather/{city_id}/{date}';

  // Paycell endpoints
  static const String paycell = '$apiVersion/paycell';
  static const String paycellByCity = '$apiVersion/paycell/{city_id}';
  static const String paycellByCityDate =
      '$apiVersion/paycell/{city_id}/{date}';

  // Scores endpoints
  static const String scores = '$apiVersion/scores';
  static const String scoresByCity = '$apiVersion/scores/{city_id}';
  static const String scoresByCityDate = '$apiVersion/scores/{city_id}/{date}';

  // City Statistics endpoints
  static const String cityStatistics = '$apiVersion/city-statistics/{city_id}';
  static const String cityStatisticsSummary =
      '$apiVersion/city-statistics/{city_id}/summary';
  static const String cityStatisticsSustainability =
      '$apiVersion/city-statistics/{city_id}/sustainability-score';
  static const String topGreenCities =
      '$apiVersion/city-statistics/leaderboard/green-cities';

  // Location endpoints
  static const String locationFindCityPost = '$apiVersion/location/find-city';
  static const String locationFindCityGet = '$apiVersion/location/find-city';
  static const String locationCityCoordinates =
      '$apiVersion/location/city-coordinates/{city_id}';
  static const String locationTestCoordinates =
      '$apiVersion/location/test-coordinates';

  // Legacy endpoints (from original)
  static const String cityMetrics = '$apiVersion/cities/{id}/metrics';
  static const String notifications = '$apiVersion/notifications';

  // HTTP Methods
  static const String get = 'GET';
  static const String post = 'POST';
  static const String put = 'PUT';
  static const String delete = 'DELETE';

  // Headers
  static const String contentType = 'Content-Type';
  static const String applicationJson = 'application/json';
  static const String authorization = 'Authorization';

  // Response Keys
  static const String success = 'success';
  static const String message = 'message';
  static const String data = 'data';
  static const String error = 'error';
}
