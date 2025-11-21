class CityDataSubmission {
  final String city;
  final String name;
  final String message;
  final DateTime timestamp;

  CityDataSubmission({
    required this.city,
    required this.name,
    required this.message,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() {
    return {
      'city': city,
      'name': name,
      'message': message,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  factory CityDataSubmission.fromJson(Map<String, dynamic> json) {
    return CityDataSubmission(
      city: json['city'] as String,
      name: json['name'] as String,
      message: json['message'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
    );
  }
}
