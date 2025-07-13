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
}
