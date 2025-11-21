class CitySummary {
  final double trafficGb;
  final double signalStrength;
  final double airQuality;
  final double paycellTransactions;
  final double ecoScore;

  CitySummary({
    required this.trafficGb,
    required this.signalStrength,
    required this.airQuality,
    required this.paycellTransactions,
    required this.ecoScore,
  });

  factory CitySummary.fromJson(Map<String, dynamic> json) {
    return CitySummary(
      trafficGb: (json['traffic_gb'] as num).toDouble(),
      signalStrength: (json['signal_strength'] as num).toDouble(),
      airQuality: (json['air_quality'] as num).toDouble(),
      paycellTransactions: (json['paycell_transactions'] as num).toDouble(),
      ecoScore: (json['eco_score'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'traffic_gb': trafficGb,
      'signal_strength': signalStrength,
      'air_quality': airQuality,
      'paycell_transactions': paycellTransactions,
      'eco_score': ecoScore,
    };
  }
}
