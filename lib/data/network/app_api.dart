import 'package:ai_movie_suggestion/data/network/requests.dart';
import 'package:ai_movie_suggestion/data/response/movie_list_response.dart';
import 'package:ai_movie_suggestion/data/response/response.dart';
import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';
part 'app_api.g.dart';

@RestApi()
abstract class AppServiceClient {
  factory AppServiceClient(Dio dio, {String baseUrl}) = _AppServiceClient;
  @POST("/api/users/login")
  Future<LoginResponse> login(
    @Body() Map<String, dynamic> body,
  );
  @POST("/api/users/register")
  Future<RegisterResponse> register(
    @Body() Map<String, dynamic> body,
  );
  @POST("/api/users/verify-email")
  Future<VerifyEmailResponse> verifyEmail(
    @Body() Map<String, dynamic> body,
  );
  @POST("/api/data/likes")
  Future<AddLikeResponse> addLike(
    @Field("like") String movieId,
  );
  @POST("/api/data/notifications")
  Future<SendNotificationResponse> sendNotifications(
    @Body() SendNotificationsRequest body,
  );
  @POST("/api/get-movie-suggestion")
  Future<MovieDetailsResponse> sendPrompt(
    @Field("prompt") String prompt,
  );
  @GET("/api/users/profile")
  Future<UserProfileResponse> getUserData();
}
