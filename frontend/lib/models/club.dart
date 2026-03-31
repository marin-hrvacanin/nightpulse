import 'dart:ui' show Color;

class LiveStats {
  final double? crowdAvg;
  final double? atmosphereAvg;
  final String? topGenre;
  final double? waitMinutesAvg;
  final int reviewCount;
  final String? lastUpdated;

  const LiveStats({
    this.crowdAvg,
    this.atmosphereAvg,
    this.topGenre,
    this.waitMinutesAvg,
    this.reviewCount = 0,
    this.lastUpdated,
  });

  factory LiveStats.fromJson(Map<String, dynamic> json) {
    return LiveStats(
      crowdAvg: (json['crowd_avg'] as num?)?.toDouble(),
      atmosphereAvg: (json['atmosphere_avg'] as num?)?.toDouble(),
      topGenre: json['top_genre'] as String?,
      waitMinutesAvg: (json['wait_minutes_avg'] as num?)?.toDouble(),
      reviewCount: json['review_count'] as int? ?? 0,
      lastUpdated: json['last_updated'] as String?,
    );
  }
}

class Club {
  final int id;
  final String name;
  final String? slug;
  final String? description;
  final String? address;
  final double latitude;
  final double longitude;
  final String? photoUrl;
  final List<String> genres;
  final LiveStats? liveStats;

  // Local-only display fields
  final List<Color> gradientColors;
  final String? imageAsset;

  const Club({
    required this.id,
    required this.name,
    this.slug,
    this.description,
    this.address,
    required this.latitude,
    required this.longitude,
    this.photoUrl,
    required this.genres,
    this.liveStats,
    this.gradientColors = const [Color(0xFF7C4DFF), Color(0xFF448AFF)],
    this.imageAsset,
  });

  // Computed display fields from live stats
  double get crowdRating => liveStats?.crowdAvg ?? 0;
  String get currentGenre => liveStats?.topGenre ?? (genres.isNotEmpty ? genres.first : '');
  int get queueMinutes => liveStats?.waitMinutesAvg?.round() ?? 0;
  String get lastUpdated {
    if (liveStats?.lastUpdated == null) return 'Nema podataka';
    try {
      final dt = DateTime.parse(liveStats!.lastUpdated!);
      final diff = DateTime.now().toUtc().difference(dt);
      if (diff.inMinutes < 1) return 'Upravo';
      if (diff.inMinutes < 60) return '${diff.inMinutes} min';
      if (diff.inHours < 24) return '${diff.inHours}h';
      return '${diff.inDays}d';
    } catch (_) {
      return 'Nema podataka';
    }
  }

  static const _gradientMap = {
    0: [Color(0xFF7C4DFF), Color(0xFF448AFF)],
    1: [Color(0xFFE040FB), Color(0xFFFF5252)],
    2: [Color(0xFF00BCD4), Color(0xFF00E676)],
    3: [Color(0xFFFF6D00), Color(0xFFFFAB00)],
    4: [Color(0xFFD50000), Color(0xFF7C4DFF)],
    5: [Color(0xFF448AFF), Color(0xFF00E5FF)],
    6: [Color(0xFF00E676), Color(0xFF7C4DFF)],
    7: [Color(0xFFE040FB), Color(0xFF448AFF)],
  };

  static const _imageMap = {
    0: 'assets/clubs/club1.jpg',
    1: 'assets/clubs/club2.jpg',
    2: 'assets/clubs/club3.jpg',
  };

  factory Club.fromJson(Map<String, dynamic> json) {
    final id = json['id'] as int;
    final genreList = (json['genres'] as List?)
        ?.map((g) => g is Map ? g['name'] as String : g as String)
        .toList() ?? [];

    return Club(
      id: id,
      name: json['name'] as String,
      slug: json['slug'] as String?,
      description: json['description'] as String?,
      address: json['address'] as String?,
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      photoUrl: json['photo_url'] as String?,
      genres: genreList,
      liveStats: json['live_stats'] != null
          ? LiveStats.fromJson(json['live_stats'] as Map<String, dynamic>)
          : null,
      gradientColors: _gradientMap[id % _gradientMap.length]!,
      imageAsset: _imageMap[id % _imageMap.length],
    );
  }
}
