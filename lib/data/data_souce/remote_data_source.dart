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
  Future<AddLikeResponse> addLike(AddLikeRequest addLIkeRequest);
  Future<SendNotificationResponse> sendNotifications(
      SendNotificationsRequest sendNotificationsRequest);
  Future<MovieDetailsResponse> sendPrompt(SendPromptRequest sendPrompt);
  Future<UserProfileResponse> getUserData();

  Future<MovieListResponse> nowPlaying({int? page, String? language});
  Future<MovieListResponse> topRatedMovies({int? page, String? language});
  Future<MovieListResponse> popularMovies({int? page, String? language});
  Future<MovieListResponse> upcomingMovies({int? page, String? language});
  Future<MovieDetailsResponse> movieDetails(int movieId, {String? language});

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

  /////////////////////////////////// Get Movie////////////////////////////////////
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
  Future<MovieListResponse> popularMovies({int? page, String? language}) async {
    return await _movieServiceClient.getPopularMovies(_apiKey, page, language);
  }

  @override
  Future<MovieListResponse> upcomingMovies(
      {int? page, String? language}) async {
    return await _movieServiceClient.getUpcomingMovies(_apiKey, page, language);
  }

  @override
  Future<MovieDetailsResponse> movieDetails(int movieId,
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

////////////////////////////////Movie Operations////////////////////////////////////
  @override
  Future<AddLikeResponse> addLike(AddLikeRequest addLIkeRequest) async {
    return await _appServiceClient.addLike(addLIkeRequest.movieId);
  }

  @override
  Future<SendNotificationResponse> sendNotifications(
      ///////////Send Notification
      SendNotificationsRequest sendNotificationsRequest) async {
    return await _appServiceClient.sendNotifications(sendNotificationsRequest);
  }

  @override
  Future<MovieDetailsResponse> sendPrompt(SendPromptRequest sendPrompt) async {
    return await _appServiceClient.sendPrompt(sendPrompt.prompt);
  }
  
  @override
  Future<UserProfileResponse> getUserData() async{
    return await _appServiceClient.getUserData();
  }
}
