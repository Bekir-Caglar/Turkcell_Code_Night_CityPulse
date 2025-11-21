class TopGreenCitiesResponse {
  final bool success;
  final String message;
  final TopGreenCitiesData data;

  TopGreenCitiesResponse({
    required this.success,
    required this.message,
    required this.data,
  });

  factory TopGreenCitiesResponse.fromJson(Map<String, dynamic> json) {
    return TopGreenCitiesResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data: TopGreenCitiesData.fromJson(json['data'] ?? {}),
    );
  }
}

class TopGreenCitiesData {
  final WeekPeriod weekPeriod;
  final List<GreenCity> top3GreenCities;
  final int allCitiesCount;
  final int evaluatedCitiesCount;

  TopGreenCitiesData({
    required this.weekPeriod,
    required this.top3GreenCities,
    required this.allCitiesCount,
    required this.evaluatedCitiesCount,
  });

  factory TopGreenCitiesData.fromJson(Map<String, dynamic> json) {
    return TopGreenCitiesData(
      weekPeriod: WeekPeriod.fromJson(json['week_period'] ?? {}),
      top3GreenCities:
          (json['top_3_green_cities'] as List<dynamic>?)
              ?.map((city) => GreenCity.fromJson(city))
              .toList() ??
          [],
      allCitiesCount: json['all_cities_count'] ?? 0,
      evaluatedCitiesCount: json['evaluated_cities_count'] ?? 0,
    );
  }
}

class WeekPeriod {
  final String startDate;
  final String endDate;

  WeekPeriod({required this.startDate, required this.endDate});

  factory WeekPeriod.fromJson(Map<String, dynamic> json) {
    return WeekPeriod(
      startDate: json['start_date'] ?? '',
      endDate: json['end_date'] ?? '',
    );
  }
}

class GreenCity {
  final String cityId;
  final String cityName;
  final String region;
  final int population;
  final double sustainabilityScore;
  final ScoreBreakdown scoreBreakdown;
  final int rank;
  final String badge;

  GreenCity({
    required this.cityId,
    required this.cityName,
    required this.region,
    required this.population,
    required this.sustainabilityScore,
    required this.scoreBreakdown,
    required this.rank,
    required this.badge,
  });

  factory GreenCity.fromJson(Map<String, dynamic> json) {
    return GreenCity(
      cityId: json['city_id'] ?? '',
      cityName: json['city_name'] ?? '',
      region: json['region'] ?? '',
      population: json['population'] ?? 0,
      sustainabilityScore: (json['sustainability_score'] ?? 0.0).toDouble(),
      scoreBreakdown: ScoreBreakdown.fromJson(json['score_breakdown'] ?? {}),
      rank: json['rank'] ?? 0,
      badge: json['badge'] ?? '',
    );
  }
}

class ScoreBreakdown {
  final double signalStrength;
  final double airQuality;
  final double internetTraffic;
  final double ecoFeedbackRatio;

  ScoreBreakdown({
    required this.signalStrength,
    required this.airQuality,
    required this.internetTraffic,
    required this.ecoFeedbackRatio,
  });

  factory ScoreBreakdown.fromJson(Map<String, dynamic> json) {
    return ScoreBreakdown(
      signalStrength: (json['signal_strength'] ?? 0.0).toDouble(),
      airQuality: (json['air_quality'] ?? 0.0).toDouble(),
      internetTraffic: (json['internet_traffic'] ?? 0.0).toDouble(),
      ecoFeedbackRatio: (json['eco_feedback_ratio'] ?? 0.0).toDouble(),
    );
  }
}
