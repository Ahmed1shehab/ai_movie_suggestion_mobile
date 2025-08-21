import 'package:ai_movie_suggestion/data/network/failure.dart';
import 'package:ai_movie_suggestion/data/network/requests.dart';
import 'package:ai_movie_suggestion/domain/model/models.dart';
import 'package:dartz/dartz.dart';

abstract class Repository {
  Future<Either<Failure, Auth>> login(LoginRequest loginRequest);
  Future<Either<Failure, RegisterModel>> register(
      RegisterRequest registerRequest);
  Future<Either<Failure, VerifyEmailModel>> verifyEmail(
      VerifyEmailRequest verifyEmailRequest);
  Future<Either<Failure, AddLikeModel>> addLike(AddLikeRequest addLIkeRequest);
  Future<Either<Failure, SendNotificationEntity>> sendNotifications(
      SendNotificationsRequest sendNotificationsRequest);
  Future<Either<Failure, MovieDetail>> sendPrompt(
      SendPromptRequest sendPrompt);
  Future<Either<Failure, UserProfileModel>> getUserData(
      );

  // Movie methods
  Future<Either<Failure, List<MovieEntity>>> nowPlaying(
      {int? page, String? language});
  Future<Either<Failure, List<MovieEntity>>> topRatedMovies(
      {int? page, String? language});
  Future<Either<Failure, List<MovieEntity>>> popularMovies(
      {int? page, String? language});
  Future<Either<Failure, List<MovieEntity>>> upcomingMovies(
      {int? page, String? language});
  Future<Either<Failure, MovieDetail>> movieDetails(int movieId,
      {String? language});
  Future<Either<Failure, List<MovieEntity>>> searchMovies(String query,
      {int? page, String? language});
  Future<Either<Failure, List<MovieEntity>>> similarMovies(int movieId,
      {int? page, String? language});
  Future<Either<Failure, List<MovieEntity>>> movieRecommendations(int movieId,
      {int? page, String? language});
}
