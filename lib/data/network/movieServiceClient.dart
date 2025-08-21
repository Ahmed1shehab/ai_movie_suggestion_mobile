import 'package:ai_movie_suggestion/data/response/movie_list_response.dart';
import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

part 'movieServiceClient.g.dart';

@RestApi()
abstract class MovieServiceClient {
  factory MovieServiceClient(Dio dio, {String baseUrl}) = _MovieServiceClient;

  // Get now playing movies
  @GET("/movie/now_playing")
  Future<MovieListResponse> getNowPlayingMovies(@Query("api_key") String apiKey,
      [@Query("page") int? page, @Query("language") String? language]);

  // Get top rated movies
  @GET("/movie/top_rated")
  Future<MovieListResponse> getTopRatedMovies(@Query("api_key") String apiKey,
      [@Query("page") int? page, @Query("language") String? language]);
  // Get top rated movies

  @GET("/movie/popular")
  Future<MovieListResponse> getPopularMovies(@Query("api_key") String apiKey,
      [@Query("page") int? page, @Query("language") String? language]);

        // Get top rated movies

  @GET("/movie/upcoming")
  Future<MovieListResponse> getUpcomingMovies(@Query("api_key") String apiKey,
      [@Query("page") int? page, @Query("language") String? language]);

  // Get movie details
  @GET("/movie/{movie_id}")
  Future<MovieDetailsResponse> getMovieDetails(
      @Path("movie_id") int movieId, @Query("api_key") String apiKey,
      [@Query("language") String? language]);

  // Search movies
  @GET("/search/movie")
  Future<MovieListResponse> searchMovies(
      @Query("query") String query, @Query("api_key") String apiKey,
      [@Query("page") int? page, @Query("language") String? language]);

  // Get similar movies
  @GET("/movie/{movie_id}/similar")
  Future<MovieListResponse> getSimilarMovies(
      @Path("movie_id") int movieId, @Query("api_key") String apiKey,
      [@Query("page") int? page, @Query("language") String? language]);

  // Get movie recommendations
  @GET("/movie/{movie_id}/recommendations")
  Future<MovieListResponse> getMovieRecommendations(
      @Path("movie_id") int movieId, @Query("api_key") String apiKey,
      [@Query("page") int? page, @Query("language") String? language]);
}


  // // Get movie genres
  // @GET("/genre/movie/list")
  // Future<GenreListResponse> getMovieGenres(
  //   @Query("api_key") String apiKey,
  //   [@Query("language") String? language]
  // );
