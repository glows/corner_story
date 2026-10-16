import 'dart:convert';
import 'dart:typed_data';

import 'package:http/http.dart' as http;

import 'corner_auth_service.dart';

/// Cloudflare Edge API Client for Corner v2.0
/// Connects to `corner_api` (Cloudflare Workers + Hono + D1 + R2 + Vectorize + Workers AI)
class CornerApiClient {
  final String baseUrl;
  final String currentUserId;
  final http.Client _http;

  CornerApiClient({
    String? baseUrl,
    this.currentUserId = 'usr_clara',
    http.Client? httpClient,
  }) : baseUrl = baseUrl ?? CornerAuthService.instance.baseUrl,
       _http = httpClient ?? http.Client();

  Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    ...CornerAuthService.instance.authHeaders,
  };

  /// 1. Explore Feed (Dispatch Hero + Curated Spots)
  Future<Map<String, dynamic>> fetchExploreFeed({
    String city = 'New York',
    String category = 'For You',
    String query = '',
  }) async {
    final uri = Uri.parse('$baseUrl/api/v1/explore/feed').replace(
      queryParameters: {
        'city': city,
        'category': category,
        if (query.isNotEmpty) 'q': query,
      },
    );
    final res = await _http.get(uri, headers: _headers);
    return jsonDecode(res.body) as Map<String, dynamic>;
  }

  /// 2. Ask Corner AI (Workers AI + Vectorize / D1 Vibe Matcher)
  Future<List<dynamic>> askCornerAi({
    required String prompt,
    String city = 'New York',
  }) async {
    final uri = Uri.parse('$baseUrl/api/v1/explore/ask-ai');
    final res = await _http.post(
      uri,
      headers: _headers,
      body: jsonEncode({'prompt': prompt, 'city': city}),
    );
    final data = jsonDecode(res.body) as Map<String, dynamic>;
    return (data['spots'] as List<dynamic>?) ?? const [];
  }

  /// 3. Map Viewport Spots + Friend IRL Endorsements
  Future<List<dynamic>> fetchMapSpots({
    required String city,
    double? minLat,
    double? maxLat,
    double? minLng,
    double? maxLng,
    bool friendsOnly = false,
  }) async {
    final uri = Uri.parse('$baseUrl/api/v1/map/spots').replace(
      queryParameters: {
        'city': city,
        'friendsOnly': friendsOnly.toString(),
        if (minLat != null) 'minLat': minLat.toString(),
        if (maxLat != null) 'maxLat': maxLat.toString(),
        if (minLng != null) 'minLng': minLng.toString(),
        if (maxLng != null) 'maxLng': maxLng.toString(),
      },
    );
    final res = await _http.get(uri, headers: _headers);
    final data = jsonDecode(res.body) as Map<String, dynamic>;
    return (data['spots'] as List<dynamic>?) ?? const [];
  }

  /// 4. Vibes Community Field Notes Feed
  Future<Map<String, dynamic>> fetchVibesFeed({
    String scope = 'Friends IRL',
  }) async {
    final uri = Uri.parse('$baseUrl/api/v1/vibes/feed')
        .replace(queryParameters: {'scope': scope});
    final res = await _http.get(uri, headers: _headers);
    return jsonDecode(res.body) as Map<String, dynamic>;
  }

  /// 5. Publish a new Field Note
  Future<Map<String, dynamic>> publishFieldNote({
    required String spotName,
    required String quote,
    List<String> sensoryTags = const ['Field Note', 'Zero Sponsored'],
    String scope = 'Taste Network',
    List<Map<String, String>> photos = const [],
  }) async {
    final uri = Uri.parse('$baseUrl/api/v1/vibes/notes');
    final res = await _http.post(
      uri,
      headers: _headers,
      body: jsonEncode({
        'spot_name': spotName,
        'quote': quote,
        'sensory_tags': sensoryTags,
        'scope': scope,
        'photos': photos,
      }),
    );
    final data = _checkedJson(res);
    if (data['status'] != 'published' || data['id'] == null) {
      throw const FormatException('The note was not confirmed by the server.');
    }
    return data;
  }

  /// 6. Toggle Reaction ('agreed' | 'cozy' | 'saved')
  Future<String> uploadPhoto(
    Uint8List bytes, {
    String contentType = 'image/jpeg',
  }) async {
    final key = 'field-note-${DateTime.now().microsecondsSinceEpoch}';
    final response = await _http.put(
      Uri.parse('$baseUrl/api/v1/media/$key'),
      headers: {..._headers, 'Content-Type': contentType},
      body: bytes,
    );
    final data = _checkedJson(response);
    final url = data['url'];
    if (url is! String || url.isEmpty) {
      throw const FormatException('Missing photo URL');
    }
    return url.startsWith('/') ? '$baseUrl$url' : url;
  }

  Future<Map<String, dynamic>> reactToFieldNote({
    required String noteId,
    required String type,
    int delta = 1,
  }) async {
    final uri = Uri.parse('$baseUrl/api/v1/vibes/notes/$noteId/react');
    final res = await _http.post(
      uri,
      headers: _headers,
      body: jsonEncode({'type': type, 'delta': delta}),
    );
    return jsonDecode(res.body) as Map<String, dynamic>;
  }

  /// 7. Tastemaker Profile, Curated Collections & Candid Moments
  Future<Map<String, dynamic>> fetchProfile({
    String handle = 'claravance',
    String city = 'all',
  }) async {
    final uri = Uri.parse('$baseUrl/api/v1/profile/$handle')
        .replace(queryParameters: {'city': city});
    final res = await _http.get(uri, headers: _headers);
    return jsonDecode(res.body) as Map<String, dynamic>;
  }

  /// 8. Toggle Spot Bookmark in D1
  Future<bool> toggleSpotBookmark(String spotId) async {
    final uri = Uri.parse('$baseUrl/api/v1/profile/bookmarks/$spotId');
    final res = await _http.post(uri, headers: _headers);
    final data = _checkedJson(res);
    return data['saved'] == true;
  }

  Map<String, dynamic> _checkedJson(http.Response response) {
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw http.ClientException('Request failed (${response.statusCode}).');
    }
    return jsonDecode(response.body) as Map<String, dynamic>;
  }
}
