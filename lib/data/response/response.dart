import 'package:freezed_annotation/freezed_annotation.dart';

part 'response.g.dart';

@JsonSerializable()
class BaseResponse {
  @JsonKey(name: "status")
  int? statusCode;

  @JsonKey(name: "message")
  String? message;
}

///////////////////////////////////////login response/////////////////////////////////////////
@JsonSerializable()
class LoginResponse extends BaseResponse {
  @JsonKey(name: "token")
  String? token;

  @JsonKey(name: "user")
  UserLogin? user;

  LoginResponse(this.token, this.user);

  factory LoginResponse.fromJson(Map<String, dynamic> json) =>
      _$LoginResponseFromJson(json);

  Map<String, dynamic> toJson() => _$LoginResponseToJson(this);
}

@JsonSerializable()
class UserLogin {
  @JsonKey(name: "id")
  String? id;

  @JsonKey(name: "fullName")
  String? name;

  @JsonKey(name: "email")
  String? email;

  UserLogin(this.id, this.name, this.email);

  factory UserLogin.fromJson(Map<String, dynamic> json) =>
      _$UserLoginFromJson(json);

  Map<String, dynamic> toJson() => _$UserLoginToJson(this);
}

///////////////////////////////////////register response/////////////////////////////////////////
@JsonSerializable()
class RegisterResponse extends BaseResponse {
  RegisterResponse();

  factory RegisterResponse.fromJson(Map<String, dynamic> json) =>
      _$RegisterResponseFromJson(json);

  Map<String, dynamic> toJson() => _$RegisterResponseToJson(this);
}

///////////////////////////////////////verify email response/////////////////////////////////////////
@JsonSerializable()
class VerifyEmailResponse extends BaseResponse {
  VerifyEmailResponse();

  factory VerifyEmailResponse.fromJson(Map<String, dynamic> json) =>
      _$VerifyEmailResponseFromJson(json);

  Map<String, dynamic> toJson() => _$VerifyEmailResponseToJson(this);
}

///////////////////////////////////////ADD Like response/////////////////////////////////////////
@JsonSerializable()
class AddLikeResponse extends BaseResponse {
  AddLikeResponse({required String message});

  factory AddLikeResponse.fromJson(Map<String, dynamic> json) =>
      _$AddLikeResponseFromJson(json);

  Map<String, dynamic> toJson() => _$AddLikeResponseToJson(this);
}

@JsonSerializable()
class MovieRecommendation {
  final String title;
  final String overview;
  @JsonKey(name: 'poster_url')
  final String posterUrl;
  @JsonKey(name: 'imdb_link')
  final String imdbLink;
  final String trailer;
  final List<GenreItem> genres;
  @JsonKey(name: 'release_date')
  final String releaseDate;
  @JsonKey(name: 'spoken_languages')
  final List<SpokenLanguageItem> spokenLanguages;
  @JsonKey(name: 'vote_average')
  final double voteAverage;

  MovieRecommendation({
    required this.title,
    required this.overview,
    required this.posterUrl,
    required this.imdbLink,
    required this.trailer,
    required this.genres,
    required this.releaseDate,
    required this.spokenLanguages,
    required this.voteAverage,
  });

  factory MovieRecommendation.fromJson(Map<String, dynamic> json) =>
      _$MovieRecommendationFromJson(json);

  Map<String, dynamic> toJson() => _$MovieRecommendationToJson(this);
}

@JsonSerializable()
class GenreItem {
  final int id;
  final String name;

  GenreItem({required this.id, required this.name});

  factory GenreItem.fromJson(Map<String, dynamic> json) =>
      _$GenreItemFromJson(json);

  Map<String, dynamic> toJson() => _$GenreItemToJson(this);
}

@JsonSerializable()
class SpokenLanguageItem {
  @JsonKey(name: 'english_name')
  final String englishName;
  @JsonKey(name: 'iso_639_1')
  final String iso6391;
  final String name;

  SpokenLanguageItem({
    required this.englishName,
    required this.iso6391,
    required this.name,
  });

  factory SpokenLanguageItem.fromJson(Map<String, dynamic> json) =>
      _$SpokenLanguageItemFromJson(json);

  Map<String, dynamic> toJson() => _$SpokenLanguageItemToJson(this);
}

/////////////////////////////////////////Send Notification response/////////////////////////////////////////
@JsonSerializable()
class SendNotificationResponse extends BaseResponse {
  @JsonKey(name: 'notifications')
  final List<NotificationResponse> notifications;
  SendNotificationResponse(this.notifications);

  factory SendNotificationResponse.fromJson(Map<String, dynamic> json) =>
      _$SendNotificationResponseFromJson(json);

  Map<String, dynamic> toJson() => _$SendNotificationResponseToJson(this);
}

@JsonSerializable()
class NotificationResponse {
  final String message;
  final DateTime date;
  final bool isRead;
  @JsonKey(name: '_id')
  final String id;

  NotificationResponse(this.message, this.date, this.isRead, this.id);

  factory NotificationResponse.fromJson(Map<String, dynamic> json) =>
      _$NotificationResponseFromJson(json);

  Map<String, dynamic> toJson() => _$NotificationResponseToJson(this);
}

/////////////////////////////////////User Profile Response/////////////////////////////////////////
@JsonSerializable()
class UserProfileResponse extends BaseResponse {
  @JsonKey(name: 'user')
  final UserProfileData user;

  @JsonKey(name: 'likes')
  final List<String> likes;

  @JsonKey(name: 'notifications')
  final List<NotificationResponse> notifications;

  @JsonKey(name: 'credits')
  final int credits;

  @JsonKey(name: 'chatHistory')
  final List<ChatHistoryItem> chatHistory;

  UserProfileResponse({
    required this.user,
    required this.likes,
    required this.notifications,
    required this.credits,
    required this.chatHistory,
  });

  factory UserProfileResponse.fromJson(Map<String, dynamic> json) =>
      _$UserProfileResponseFromJson(json);

  Map<String, dynamic> toJson() => _$UserProfileResponseToJson(this);
}

@JsonSerializable()
class UserProfileData {
  @JsonKey(name: '_id')
  final String id;

  @JsonKey(name: 'isVerified')
  final bool isVerified;

  @JsonKey(name: 'fullName')
  final String fullName;

  @JsonKey(name: 'email')
  final String email;

  @JsonKey(name: 'createdAt')
  final String createdAt;

  @JsonKey(name: 'updatedAt')
  final String updatedAt;

  @JsonKey(name: '__v')
  final int version;

  UserProfileData({
    required this.id,
    required this.isVerified,
    required this.fullName,
    required this.email,
    required this.createdAt,
    required this.updatedAt,
    required this.version,
  });

  factory UserProfileData.fromJson(Map<String, dynamic> json) =>
      _$UserProfileDataFromJson(json);

  Map<String, dynamic> toJson() => _$UserProfileDataToJson(this);
}

@JsonSerializable()
class ChatHistoryItem {
  @JsonKey(name: 'role')
  final String role;

  @JsonKey(name: 'message')
  final dynamic message; // Can be String or complex object

  @JsonKey(name: '_id')
  final String id;

  @JsonKey(name: 'timestamp')
  final String timestamp;

  ChatHistoryItem({
    required this.role,
    required this.message,
    required this.id,
    required this.timestamp,
  });

  factory ChatHistoryItem.fromJson(Map<String, dynamic> json) =>
      _$ChatHistoryItemFromJson(json);

  Map<String, dynamic> toJson() => _$ChatHistoryItemToJson(this);

  // Helper method to get DateTime from timestamp
  DateTime get timestampDateTime => DateTime.parse(timestamp);
}
