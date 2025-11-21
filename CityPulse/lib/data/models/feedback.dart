class FeedbackModel {
  final int cityId;
  final String user;
  final String message;
  final String category;

  FeedbackModel({
    required this.cityId,
    required this.user,
    required this.message,
    required this.category,
  });

  Map<String, dynamic> toJson() {
    return {
      'city_id': cityId,
      'user': user,
      'message': message,
      'category': category,
    };
  }
}
