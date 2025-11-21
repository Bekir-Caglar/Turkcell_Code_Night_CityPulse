class Alert {
  final String title;
  final String message;
  final String severity;
  final DateTime timestamp;

  Alert({
    required this.title,
    required this.message,
    required this.severity,
    required this.timestamp,
  });

  factory Alert.fromJson(Map<String, dynamic> json) {
    return Alert(
      title: json['title'] as String,
      message: json['message'] as String,
      severity: json['severity'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'message': message,
      'severity': severity,
      'timestamp': timestamp.toIso8601String(),
    };
  }
}
