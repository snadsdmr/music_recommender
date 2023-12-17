import 'dart:convert';
import 'package:http/http.dart' as http;

class SpotifyService {
  final String clientId;
  final String clientSecret;
  final String base64Encoded;

  SpotifyService({required this.clientId, required this.clientSecret})
      : base64Encoded = base64.encode(utf8.encode('$clientId:$clientSecret'));

  Future<String> _getAccessToken() async {
    final response = await http.post(
      Uri.parse('https://accounts.spotify.com/api/token'),
      headers: {
        'Authorization': 'Basic $base64Encoded',
        'Content-Type': 'application/x-www-form-urlencoded',
      },
      body: {'grant_type': 'client_credentials'},
    );

    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);
      return jsonResponse['access_token'];
    } else {
      throw Exception('Failed to get access token');
    }
  }

  Future<List<Map<String, dynamic>>> recommendTracks(
    String genre,
    double energy,
    double danceability,
    double valence, // Added parameter
    {
    String? mood,
    double? tempo,
    String? decade,
    bool explicitFilter = false,
  }) async {
    final accessToken = await _getAccessToken();

    // Map valence to mood
    if (valence > 0.7) {
      mood = 'happy';
    } else if (energy < 0.3 && valence < 0.3) {
      mood = 'sad';
    }
    if (energy > 0.7) {
      mood = 'energetic';
    } else if (energy < 0.5 && valence < 0.6 && 0.4 < valence) {
      mood = 'relaxing';
    }

    // Construct the recommendation endpoint URL with additional parameters
    final recommendationUrl =
        'https://api.spotify.com/v1/recommendations?seed_genres=$genre&energy=$energy&danceability=$danceability&mood=$mood';

    final List<String> filters = [];
    if (tempo != null) filters.add('tempo=$tempo');
    if (decade != null) filters.add('release_date=$decade');
    if (explicitFilter) filters.add('explicit=false');

    final String filtersString =
        filters.isNotEmpty ? '&${filters.join('&')}' : '';

    final response = await http.get(
      Uri.parse('$recommendationUrl$filtersString'),
      headers: {'Authorization': 'Bearer $accessToken'},
    );

    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);
      final tracks = jsonResponse['tracks'] as List<dynamic>;

      return tracks.map((track) {
        return {
          'name': track['name'] as String,
          'artists': track['artists'] as List<dynamic>,
          'album': {
            'images': track['album']['images'] as List<dynamic>,
          },
        };
      }).toList();
    } else {
      throw Exception('Failed to recommend tracks');
    }
  }
}
