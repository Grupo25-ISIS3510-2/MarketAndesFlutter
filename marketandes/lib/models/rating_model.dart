class Rating {
  final int rating;
  final String comment;
  final DateTime timestamp;

  Rating({
    required this.rating,
    required this.comment,
    required this.timestamp,
  });

  // Nuevo factory para crear Rating desde un Map
  factory Rating.fromMap(Map<String, dynamic> map) {
    return Rating(
      rating: (map['rating'] as num).toInt(),
      comment: map['comment'] ?? '',
      timestamp: DateTime.parse(map['timestamp'] as String),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'rating': rating,
      'comment': comment,
      'timestamp': timestamp.toIso8601String(),  // Mejor guardar el timestamp como String ISO8601
    };
  }
}
