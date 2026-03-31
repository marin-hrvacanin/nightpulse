import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/club.dart';

class ApiService {
  static const String appVersion = '1.0.0';

  // 10.0.2.2 = host machine from Android emulator
  static const String baseUrl = String.fromEnvironment(
    'API_URL',
    defaultValue: 'http://10.0.2.2:8000',
  );

  /// Returns null if up to date, or the update URL if a forced update is needed.
  static Future<String?> checkForUpdate() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/version'));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final minVersion = data['min_version'] as String;
        if (_compareVersions(appVersion, minVersion) < 0) {
          return data['update_url'] as String? ?? '';
        }
      }
    } catch (_) {}
    return null;
  }

  static int _compareVersions(String a, String b) {
    final aParts = a.split('.').map(int.parse).toList();
    final bParts = b.split('.').map(int.parse).toList();
    for (int i = 0; i < 3; i++) {
      final av = i < aParts.length ? aParts[i] : 0;
      final bv = i < bParts.length ? bParts[i] : 0;
      if (av < bv) return -1;
      if (av > bv) return 1;
    }
    return 0;
  }

  static const _storage = FlutterSecureStorage();
  static String? _accessToken;
  static String? _refreshToken;

  // --- Token Management ---

  static Future<void> _saveTokens(String access, String refresh) async {
    _accessToken = access;
    _refreshToken = refresh;
    await _storage.write(key: 'access_token', value: access);
    await _storage.write(key: 'refresh_token', value: refresh);
  }

  static Future<void> loadTokens() async {
    _accessToken = await _storage.read(key: 'access_token');
    _refreshToken = await _storage.read(key: 'refresh_token');
  }

  static Future<void> clearTokens() async {
    _accessToken = null;
    _refreshToken = null;
    await _storage.deleteAll();
  }

  static bool get isLoggedIn => _accessToken != null;

  static Map<String, String> get _authHeaders => {
        'Content-Type': 'application/json',
        if (_accessToken != null) 'Authorization': 'Bearer $_accessToken',
      };

  static Future<http.Response> _authGet(String path) async {
    var response = await http.get(Uri.parse('$baseUrl$path'), headers: _authHeaders);
    if (response.statusCode == 401 && _refreshToken != null) {
      final refreshed = await _tryRefresh();
      if (refreshed) {
        response = await http.get(Uri.parse('$baseUrl$path'), headers: _authHeaders);
      }
    }
    return response;
  }

  static Future<http.Response> _authPost(String path, Map<String, dynamic> body) async {
    var response = await http.post(
      Uri.parse('$baseUrl$path'),
      headers: _authHeaders,
      body: jsonEncode(body),
    );
    if (response.statusCode == 401 && _refreshToken != null) {
      final refreshed = await _tryRefresh();
      if (refreshed) {
        response = await http.post(
          Uri.parse('$baseUrl$path'),
          headers: _authHeaders,
          body: jsonEncode(body),
        );
      }
    }
    return response;
  }

  static Future<http.Response> _authDelete(String path) async {
    var response = await http.delete(Uri.parse('$baseUrl$path'), headers: _authHeaders);
    if (response.statusCode == 401 && _refreshToken != null) {
      final refreshed = await _tryRefresh();
      if (refreshed) {
        response = await http.delete(Uri.parse('$baseUrl$path'), headers: _authHeaders);
      }
    }
    return response;
  }

  static Future<bool> _tryRefresh() async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/refresh'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'refresh_token': _refreshToken}),
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        await _saveTokens(data['access_token'], data['refresh_token']);
        return true;
      }
    } catch (_) {}
    await clearTokens();
    return false;
  }

  // --- Auth ---

  static Future<Map<String, dynamic>> register(String email, String password, String fullName) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/register'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password, 'full_name': fullName}),
    );
    final data = jsonDecode(response.body);
    if (response.statusCode == 201) {
      await _saveTokens(data['access_token'], data['refresh_token']);
      return {'success': true};
    }
    return {'success': false, 'error': data['detail'] ?? 'Registration failed'};
  }

  static Future<Map<String, dynamic>> login(String email, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );
    final data = jsonDecode(response.body);
    if (response.statusCode == 200) {
      await _saveTokens(data['access_token'], data['refresh_token']);
      return {'success': true};
    }
    return {'success': false, 'error': data['detail'] ?? 'Login failed'};
  }

  static Future<Map<String, dynamic>?> getMe() async {
    final response = await _authGet('/auth/me');
    if (response.statusCode == 200) return jsonDecode(response.body);
    return null;
  }

  // --- Clubs ---

  static Future<List<Club>> getClubs({String? genre, String? search}) async {
    var path = '/clubs';
    final params = <String>[];
    if (genre != null && genre.isNotEmpty) params.add('genre=$genre');
    if (search != null && search.isNotEmpty) params.add('search=$search');
    if (params.isNotEmpty) path += '?${params.join('&')}';

    final response = await http.get(
      Uri.parse('$baseUrl$path'),
      headers: {'Content-Type': 'application/json'},
    );
    if (response.statusCode == 200) {
      final list = jsonDecode(response.body) as List;
      return list.map((j) => Club.fromJson(j)).toList();
    }
    return [];
  }

  static Future<List<Club>> getNearbyClubs(double lat, double lng, {int radius = 300}) async {
    final response = await http.get(
      Uri.parse('$baseUrl/clubs/nearby?lat=$lat&lng=$lng&radius=$radius'),
      headers: {'Content-Type': 'application/json'},
    );
    if (response.statusCode == 200) {
      final list = jsonDecode(response.body) as List;
      return list.map((j) => Club.fromJson(j)).toList();
    }
    return [];
  }

  // --- Reviews ---

  static Future<Map<String, dynamic>> submitReview({
    required int clubId,
    required int crowdRating,
    required int atmosphereRating,
    required String musicGenre,
    required int waitMinutes,
    required double latitude,
    required double longitude,
  }) async {
    final response = await _authPost('/reviews', {
      'club_id': clubId,
      'crowd_rating': crowdRating,
      'atmosphere_rating': atmosphereRating,
      'music_genre': musicGenre,
      'wait_minutes': waitMinutes,
      'latitude': latitude,
      'longitude': longitude,
    });
    final data = jsonDecode(response.body);
    if (response.statusCode == 201) return {'success': true};
    return {'success': false, 'error': data['detail'] ?? 'Submit failed'};
  }

  // --- Favourites ---

  static Future<List<Club>> getFavourites() async {
    final response = await _authGet('/favourites');
    if (response.statusCode == 200) {
      final list = jsonDecode(response.body) as List;
      return list.map((j) => Club.fromJson(j)).toList();
    }
    return [];
  }

  static Future<bool> addFavourite(int clubId) async {
    final response = await _authPost('/favourites/$clubId', {});
    return response.statusCode == 201;
  }

  static Future<bool> removeFavourite(int clubId) async {
    final response = await _authDelete('/favourites/$clubId');
    return response.statusCode == 204;
  }

  // --- User ---

  static Future<bool> updatePreferences(List<String> genres) async {
    final response = await http.put(
      Uri.parse('$baseUrl/users/me/preferences'),
      headers: _authHeaders,
      body: jsonEncode({'genres': genres}),
    );
    return response.statusCode == 200;
  }

  static Future<bool> deleteAccount() async {
    final response = await _authDelete('/users/me');
    if (response.statusCode == 204) {
      await clearTokens();
      return true;
    }
    return false;
  }
}
