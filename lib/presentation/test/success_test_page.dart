import 'package:ai_movie_suggestion/domain/model/models.dart';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart'; // Make sure you have dio added to your pubspec.yaml

class MovieDetailWidget extends StatefulWidget {
  final int movieId;
  final String apiKey;

  const MovieDetailWidget({
    Key? key,
    required this.movieId,
    required this.apiKey,
  }) : super(key: key);

  @override
  _MovieDetailWidgetState createState() => _MovieDetailWidgetState();
}

class _MovieDetailWidgetState extends State<MovieDetailWidget> {
  MovieDetail? _movieDetail;
  bool _isLoading = true;
  String? _errorMessage;
  final Dio _dio = Dio();

  @override
  void initState() {
    super.initState();
    _fetchMovieDetails();
  }

  Future<void> _fetchMovieDetails() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final response = await _dio.get(
        'https://api.themoviedb.org/3/movie/${widget.movieId}',
        queryParameters: {
          'api_key': widget.apiKey,
        },
        options: Options(
          headers: {
            'accept': 'application/json',
            'language': 'en',
          },
          responseType: ResponseType.json,
          followRedirects: true,
          receiveTimeout: const Duration(minutes: 1),
        ),
      );

      if (response.statusCode == 200) {
        setState(() {
          _movieDetail = MovieDetail.fromJson(response.data);
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = 'Failed to load movie details: ${response.statusCode}';
          _isLoading = false;
        });
      }
    } on DioException catch (e) {
      setState(() {
        if (e.response != null) {
          _errorMessage = 'Error: ${e.response?.statusCode} - ${e.response?.statusMessage}';
        } else {
          _errorMessage = 'Network Error: ${e.message}';
        }
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'An unexpected error occurred: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return  Scaffold(
        appBar: AppBar(title: Text('Movie Details')),
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_errorMessage != null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Movie Details')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(_errorMessage!),
              ElevatedButton(
                onPressed: _fetchMovieDetails,
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    if (_movieDetail == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Movie Details')),
        body: const Center(
          child: Text('No movie details available.'),
        ),
      );
    }

    final movie = _movieDetail!;
    final String posterBaseUrl = 'https://image.tmdb.org/t/p/w500'; // TMDb image base URL

    return Scaffold(
      appBar: AppBar(
        title: Text(movie.title),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (movie.posterUrl != null)
              Center(
                child: Image.network(
                  '$posterBaseUrl${movie.posterUrl}',
                  height: 300,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return const Icon(Icons.broken_image, size: 300);
                  },
                ),
              ),
            const SizedBox(height: 16.0),
            Text(
              movie.title,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            if (movie.originalTitle != movie.title)
              Text(
                'Original Title: ${movie.originalTitle}',
                style: const TextStyle(fontSize: 16, fontStyle: FontStyle.italic),
              ),
            const SizedBox(height: 8.0),
            Text(
              'Release Date: ${movie.releaseDate}',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 8.0),
            Text(
              'Rating: ${movie.voteAverage.toStringAsFixed(1)} (${movie.voteCount} votes)',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 8.0),
            Text(
              'Runtime: ${movie.runtime} minutes',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16.0),
            const Text(
              'Overview:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8.0),
            Text(
              movie.overview.isNotEmpty ? movie.overview : 'No overview available.',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16.0),
            if (movie.genres.isNotEmpty) ...[
              const Text(
                'Genres:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8.0),
              Wrap(
                spacing: 8.0,
                runSpacing: 4.0,
                children: movie.genres
                    .map((genre) => Chip(label: Text(genre.name)))
                    .toList(),
              ),
              const SizedBox(height: 16.0),
            ],
            if (movie.productionCompanies.isNotEmpty) ...[
              const Text(
                'Production Companies:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8.0),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: movie.productionCompanies
                    .map((company) => Text('- ${company.name} (${company.originCountry})'))
                    .toList(),
              ),
              const SizedBox(height: 16.0),
            ],
            // Add more details as needed from the MovieDetail model
            // For example:
            if (movie.homepage.isNotEmpty) ...[
              const Text(
                'Homepage:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8.0),
              InkWell(
                onTap: () {
                  // You might want to launch the URL here
                  // For example, using the url_launcher package:
                  // launchUrl(Uri.parse(movie.homepage));
                },
                child: Text(
                  movie.homepage,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.blue,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
              const SizedBox(height: 16.0),
            ],
            if (movie.budget > 0) ...[
              Text(
                'Budget: \$${movie.budget.toStringAsFixed(0)}',
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 8.0),
            ],
            if (movie.revenue > 0) ...[
              Text(
                'Revenue: \$${movie.revenue.toStringAsFixed(0)}',
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 8.0),
            ],
          ],
        ),
      ),
    );
  }
}