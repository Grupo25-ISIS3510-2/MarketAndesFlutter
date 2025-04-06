class Rating {
  final int rating;
  final String comment;
  final DateTime timestamp;

  Rating({
    required this.rating,
    required this.comment,
    required this.timestamp,
  });

  Map<String, dynamic> toMap() {
    return {
      'rating': rating,
      'comment': comment,
      'timestamp': timestamp,
    };
  }
}
