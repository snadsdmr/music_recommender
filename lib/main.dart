import 'package:flutter/material.dart';
import 'spotify_service.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Spotify Search',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key}) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final TextEditingController _genreController = TextEditingController();
  final SpotifyService _spotifyService = SpotifyService(
    clientId: '598b7a101a9b4aabbb368ee7c090890a',
    clientSecret: 'd418ecc29a0f4c44844d4a7cd7ceb59a',
  );

  List<Map<String, dynamic>> _recommendationResults = [];
  double _energy = 0.5;
  double _danceability = 0.5;

  // Define a list of genres
  List<String> _genres = [
    'pop',
    'rock',
    'hip-hop',
    'jazz',
    // Add more genres as needed
  ];

  String _selectedGenre = 'pop'; // Default genre
  String _selectedMood = 'happy'; // Default mood
  double _selectedTempo = 0.5; // Default tempo
  double _selectedValence = 0.5; // Default valence
  String _selectedDecade = '2020s'; // Default decade/year
  bool _explicitFilter = false; // Default explicit content filter
  void _recommend() async {
    final genre = _selectedGenre; // Use the selected genre

    final results = await _spotifyService.recommendTracks(
      genre,
      _energy,
      _danceability,
      _selectedValence, // Add this line
      mood: _selectedMood,
      tempo: _selectedTempo,
      decade: _selectedDecade,
      explicitFilter: _explicitFilter,
    );
    setState(() {
      _recommendationResults = results;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Spotify Recommendations'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            DropdownButton<String>(
              value: _selectedGenre,
              onChanged: (String? newValue) {
                setState(() {
                  _selectedGenre = newValue!;
                });
              },
              items: _genres.map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
            DropdownButton<String>(
              value: _selectedMood,
              onChanged: (String? newValue) {
                setState(() {
                  _selectedMood = newValue!;
                });
              },
              items: ['happy', 'sad', 'energetic', 'relaxing']
                  .map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
            Slider(
              value: _selectedTempo,
              onChanged: (double value) {
                setState(() {
                  _selectedTempo = value;
                });
              },
              label: 'Tempo: $_selectedTempo',
              min: 0,
              max: 1,
            ),
            DropdownButton<String>(
              value: _selectedDecade,
              onChanged: (String? newValue) {
                setState(() {
                  _selectedDecade = newValue!;
                });
              },
              items: [
                '1960s',
                '1970s',
                '1980s',
                '1990s',
                '2000s',
                '2010s',
                '2020s'
              ].map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
            Checkbox(
              value: _explicitFilter,
              onChanged: (bool? value) {
                setState(() {
                  _explicitFilter = value ?? false;
                });
              },
            ),
            ElevatedButton(
              onPressed: _recommend,
              child: Text('Recommend'),
            ),
            SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: _recommendationResults.length,
                itemBuilder: (context, index) {
                  return _buildRecommendationTile(index);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecommendationTile(int index) {
    final String trackName = _recommendationResults[index]['name'] ?? '';
    final String artistName = _getArtistName(index);
    final String albumCoverUrl = _getAlbumCoverUrl(index);
    final String releaseDate =
        _recommendationResults[index]['album']['release_date'] ?? '';
    final String decade = _getDecade(releaseDate);

    return ListTile(
      title: Text(trackName),
      subtitle: Text('$artistName - $decade'),
      leading: albumCoverUrl.isNotEmpty
          ? Image.network(albumCoverUrl,
              width: 50, height: 50, fit: BoxFit.cover)
          : Icon(Icons.music_note),
      trailing: IconButton(
        icon: Icon(Icons.favorite),
        onPressed: () {
          // Handle favorite button press
        },
      ),
    );
  }

  String _getArtistName(int index) {
    final List<dynamic> artists =
        _recommendationResults[index]['artists'] ?? [];
    return artists.isNotEmpty ? artists[0]['name'] ?? '' : '';
  }

  String _getAlbumCoverUrl(int index) {
    final Map<String, dynamic> album =
        _recommendationResults[index]['album'] ?? {};
    final List<dynamic> images = album['images'] ?? [];
    return images.isNotEmpty ? images[0]['url'] ?? '' : '';
  }
}

String _getDecade(String releaseDate) {
  try {
    int year = int.parse(releaseDate.substring(0, 4)); // Cover the entire year

    if (year >= 1960 && year < 1970) {
      return '1960s';
    } else if (year >= 1970 && year < 1980) {
      return '1970s';
    } else if (year >= 1980 && year < 1990) {
      return '1980s';
    } else if (year >= 1990 && year < 2000) {
      return '1990s';
    } else if (year >= 2000 && year < 2010) {
      return '2000s';
    } else if (year >= 2010 && year < 2020) {
      return '2010s';
    } else if (year >= 2020) {
      return '2020s';
    } else {
      // Default to empty string or another appropriate value
      return '';
    }
  } catch (e) {
    // Handle parsing error, return a default value or an empty string
    return '';
  }
}
