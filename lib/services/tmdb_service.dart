import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config.dart';
import '../models/drama.dart';

class TmdbService {
  static const _base = 'https://api.themoviedb.org/3';

  Future<Map<String, dynamic>> _get(String path,
      [Map<String, String> params = const {}]) async {
    if (tmdbApiKey.isEmpty) {
      throw Exception('Falta la API key: usa --dart-define=TMDB_API_KEY=...');
    }
    final uri = Uri.parse('$_base$path').replace(queryParameters: {
      'api_key': tmdbApiKey,
      'language': 'es-ES',
      ...params,
    });
    final res = await http.get(uri);
    if (res.statusCode != 200) {
      throw Exception('Error TMDB ${res.statusCode}');
    }
    return json.decode(res.body) as Map<String, dynamic>;
  }

  List<Drama> _parse(List results) => results
      .map((e) => Drama.fromJson(e as Map<String, dynamic>))
      .where((d) => d.posterPath != null)
      .toList();

  Future<List<Drama>> popular({int page = 1}) async {
    final data = await _get('/discover/tv', {
      'with_original_language': 'ko',
      'sort_by': 'popularity.desc',
      'page': '$page',
    });
    return _parse(data['results'] as List);
  }

  Future<List<Drama>> airingNow() async {
    final d = DateTime.now().subtract(const Duration(days: 14));
    final since =
        '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
    final data = await _get('/discover/tv', {
      'with_original_language': 'ko',
      'air_date.gte': since,
      'sort_by': 'popularity.desc',
    });
    return _parse(data['results'] as List);
  }

  Future<List<Drama>> topRated() async {
    final data = await _get('/discover/tv', {
      'with_original_language': 'ko',
      'vote_count.gte': '200',
      'sort_by': 'vote_average.desc',
    });
    return _parse(data['results'] as List);
  }

  Future<List<Drama>> search(String query) async {
    final data = await _get('/search/tv', {'query': query});
    final onlyKorean = (data['results'] as List)
        .where((e) => e['original_language'] == 'ko')
        .toList();
    return _parse(onlyKorean);
  }

  /// Disponibilidad por país (datos de JustWatch vía TMDB).
  Future<Map<String, WatchInfo>> watchProviders(int id) async {
    final data = await _get('/tv/$id/watch/providers');
    final results = (data['results'] as Map<String, dynamic>?) ?? {};
    return results.map((country, v) =>
        MapEntry(country, WatchInfo.fromJson(v as Map<String, dynamic>)));
  }

  Future<DramaDetail> detail(int id) async {
    final data = await _get('/tv/$id', {'append_to_response': 'credits'});
    return DramaDetail.fromJson(data);
  }
}
