import 'package:ai_movie_suggestion/data/network/app_api.dart';
import 'package:ai_movie_suggestion/data/network/movieServiceClient.dart';
import 'package:ai_movie_suggestion/data/network/requests.dart';
import 'package:ai_movie_suggestion/data/response/movie_list_response.dart';
import 'package:ai_movie_suggestion/data/response/response.dart';

abstract class RemoteDataSource {
  Future<LoginResponse> login(LoginRequest loginRequest);
  Future<RegisterResponse> register(RegisterRequest registerRequest);
  Future<VerifyEmailResponse> verifyEmail(
      VerifyEmailRequest verifyEmailRequest);

  // Remove apiKey parameters since it will be handled internally
  Future<MovieListResponse> nowPlaying({int? page, String? language});
  Future<MovieListResponse> topRatedMovies({int? page, String? language});
  Future<MovieListResponse> popularMovies({int? page, String? language});
  Future<MovieListResponse> upcomingMovies({int? page, String? language});
  Future<MovieDetailResponse> movieDetails(int movieId, {String? language});
  Future<MovieListResponse> searchMovies(String query,
      {int? page, String? language});
  Future<MovieListResponse> similarMovies(int movieId,
      {int? page, String? language});
  Future<MovieListResponse> movieRecommendations(int movieId,
      {int? page, String? language});
}

class RemoteDataSourceImpl implements RemoteDataSource {
  final AppServiceClient _appServiceClient;
  final MovieServiceClient _movieServiceClient;
  final String _apiKey; // Add API key field

  RemoteDataSourceImpl(
      this._appServiceClient, this._movieServiceClient, this._apiKey);

  @override
  Future<LoginResponse> login(LoginRequest loginRequest) async {
    return await _appServiceClient.login(loginRequest.toJson());
  }

  @override
  Future<RegisterResponse> register(RegisterRequest registerRequest) async {
    return await _appServiceClient.register(registerRequest.toJson());
  }

  @override
  Future<VerifyEmailResponse> verifyEmail(
      VerifyEmailRequest verifyEmailRequest) async {
    return await _appServiceClient.verifyEmail(verifyEmailRequest.toJson());
  }

  ///////////////////////////////////Movie////////////////////////////////////
  @override
  Future<MovieListResponse> nowPlaying({int? page, String? language}) async {
    return await _movieServiceClient.getNowPlayingMovies(
        _apiKey, page, language);
  }

  @override
  Future<MovieListResponse> topRatedMovies(
      {int? page, String? language}) async {
    return await _movieServiceClient.getTopRatedMovies(_apiKey, page, language);
  }

  @override
  Future<MovieListResponse> popularMovies(
      {int? page, String? language}) async {
    return await _movieServiceClient.getPopularMovies(_apiKey, page, language);
  }

  @override
  Future<MovieListResponse> upcomingMovies(
      {int? page, String? language}) async {
    return await _movieServiceClient.getUpcomingMovies(_apiKey, page, language);
  }

  @override
  Future<MovieDetailResponse> movieDetails(int movieId,
      {String? language}) async {
    return await _movieServiceClient.getMovieDetails(
        movieId, _apiKey, language);
  }

  @override
  Future<MovieListResponse> movieRecommendations(int movieId,
      {int? page, String? language}) async {
    return await _movieServiceClient.getMovieRecommendations(
        movieId, _apiKey, page, language);
  }

  @override
  Future<MovieListResponse> searchMovies(String query,
      {int? page, String? language}) async {
    return await _movieServiceClient.searchMovies(
        query, _apiKey, page, language);
  }

  @override
  Future<MovieListResponse> similarMovies(int movieId,
      {int? page, String? language}) async {
    return await _movieServiceClient.getSimilarMovies(
        movieId, _apiKey, page, language);
  }
}
