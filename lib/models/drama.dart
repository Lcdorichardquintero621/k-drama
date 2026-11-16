class Drama {
  final int id;
  final String name;
  final String overview;
  final String? posterPath;
  final String? backdropPath;
  final double rating;
  final String? firstAirDate;

  Drama({
    required this.id,
    required this.name,
    required this.overview,
    this.posterPath,
    this.backdropPath,
    required this.rating,
    this.firstAirDate,
  });

  factory Drama.fromJson(Map<String, dynamic> j) => Drama(
        id: j['id'] as int,
        name: (j['name'] ?? j['original_name'] ?? '') as String,
        overview: (j['overview'] ?? '') as String,
        posterPath: j['poster_path'] as String?,
        backdropPath: j['backdrop_path'] as String?,
        rating: ((j['vote_average'] ?? 0) as num).toDouble(),
        firstAirDate: j['first_air_date'] as String?,
      );

  String? get posterUrl =>
      posterPath == null ? null : 'https://image.tmdb.org/t/p/w500$posterPath';

  String? get backdropUrl => backdropPath == null
      ? null
      : 'https://image.tmdb.org/t/p/w780$backdropPath';

  String get year => (firstAirDate != null && firstAirDate!.length >= 4)
      ? firstAirDate!.substring(0, 4)
      : '';
}

class DramaDetail {
  final List<String> genres;
  final int? seasons;
  final int? episodes;
  final List<String> cast;

  DramaDetail({
    required this.genres,
    this.seasons,
    this.episodes,
    required this.cast,
  });

  factory DramaDetail.fromJson(Map<String, dynamic> j) {
    final credits = (j['credits']?['cast'] as List?) ?? [];
    return DramaDetail(
      genres: ((j['genres'] as List?) ?? [])
          .map((g) => g['name'] as String)
          .toList(),
      seasons: j['number_of_seasons'] as int?,
      episodes: j['number_of_episodes'] as int?,
      cast: credits.take(8).map((c) => c['name'] as String).toList(),
    );
  }
}

class WatchProvider {
  final String name;
  final String? logoPath;

  WatchProvider({required this.name, this.logoPath});

  factory WatchProvider.fromJson(Map<String, dynamic> j) => WatchProvider(
        name: (j['provider_name'] ?? '') as String,
        logoPath: j['logo_path'] as String?,
      );

  String? get logoUrl =>
      logoPath == null ? null : 'https://image.tmdb.org/t/p/w92$logoPath';
}

class WatchInfo {
  final String? link;
  final List<WatchProvider> subscription;
  final List<WatchProvider> free;
  final List<WatchProvider> rentBuy;

  WatchInfo({
    this.link,
    required this.subscription,
    required this.free,
    required this.rentBuy,
  });

  bool get isEmpty => subscription.isEmpty && free.isEmpty && rentBuy.isEmpty;

  factory WatchInfo.fromJson(Map<String, dynamic> j) {
    List<WatchProvider> read(List<String> keys) {
      final seen = <String>{};
      final out = <WatchProvider>[];
      for (final k in keys) {
        for (final e in (j[k] as List?) ?? const []) {
          final p = WatchProvider.fromJson(e as Map<String, dynamic>);
          if (seen.add(p.name)) out.add(p);
        }
      }
      return out;
    }

    return WatchInfo(
      link: j['link'] as String?,
      subscription: read(['flatrate']),
      free: read(['free', 'ads']),
      rentBuy: read(['rent', 'buy']),
    );
  }
}
