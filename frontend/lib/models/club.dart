import 'dart:ui' show Color;

class Club {
  final String id;
  final String name;
  final double crowdRating;
  final String currentGenre;
  final double entryPrice;
  final int queueMinutes;
  final double latitude;
  final double longitude;
  final String lastUpdated;
  final List<String> genres;
  final List<Color> gradientColors;

  const Club({
    required this.id,
    required this.name,
    required this.crowdRating,
    required this.currentGenre,
    required this.entryPrice,
    required this.queueMinutes,
    required this.latitude,
    required this.longitude,
    required this.lastUpdated,
    required this.genres,
    required this.gradientColors,
  });
}
