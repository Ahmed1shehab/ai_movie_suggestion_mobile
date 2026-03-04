// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BaseResponse _$BaseResponseFromJson(Map<String, dynamic> json) => BaseResponse()
  ..statusCode = (json['status'] as num?)?.toInt()
  ..message = json['message'] as String?;

Map<String, dynamic> _$BaseResponseToJson(BaseResponse instance) =>
    <String, dynamic>{
      'status': instance.statusCode,
      'message': instance.message,
    };

LoginResponse _$LoginResponseFromJson(Map<String, dynamic> json) =>
    LoginResponse(
      json['token'] as String?,
      json['user'] == null
          ? null
          : UserLogin.fromJson(json['user'] as Map<String, dynamic>),
    )
      ..statusCode = (json['status'] as num?)?.toInt()
      ..message = json['message'] as String?;

Map<String, dynamic> _$LoginResponseToJson(LoginResponse instance) =>
    <String, dynamic>{
      'status': instance.statusCode,
      'message': instance.message,
      'token': instance.token,
      'user': instance.user,
    };

UserLogin _$UserLoginFromJson(Map<String, dynamic> json) => UserLogin(
      json['id'] as String?,
      json['fullName'] as String?,
      json['email'] as String?,
    );

Map<String, dynamic> _$UserLoginToJson(UserLogin instance) => <String, dynamic>{
      'id': instance.id,
      'fullName': instance.name,
      'email': instance.email,
    };

RegisterResponse _$RegisterResponseFromJson(Map<String, dynamic> json) =>
    RegisterResponse()
      ..statusCode = (json['status'] as num?)?.toInt()
      ..message = json['message'] as String?;

Map<String, dynamic> _$RegisterResponseToJson(RegisterResponse instance) =>
    <String, dynamic>{
      'status': instance.statusCode,
      'message': instance.message,
    };

VerifyEmailResponse _$VerifyEmailResponseFromJson(Map<String, dynamic> json) =>
    VerifyEmailResponse()
      ..statusCode = (json['status'] as num?)?.toInt()
      ..message = json['message'] as String?;

Map<String, dynamic> _$VerifyEmailResponseToJson(
        VerifyEmailResponse instance) =>
    <String, dynamic>{
      'status': instance.statusCode,
      'message': instance.message,
    };

AddLikeResponse _$AddLikeResponseFromJson(Map<String, dynamic> json) =>
    AddLikeResponse(
      message: json['message'] as String?,
    )..statusCode = (json['status'] as num?)?.toInt();

Map<String, dynamic> _$AddLikeResponseToJson(AddLikeResponse instance) =>
    <String, dynamic>{
      'status': instance.statusCode,
      'message': instance.message,
    };

MovieRecommendation _$MovieRecommendationFromJson(Map<String, dynamic> json) =>
    MovieRecommendation(
      title: json['title'] as String,
      overview: json['overview'] as String,
      posterUrl: json['poster_url'] as String,
      imdbLink: json['imdb_link'] as String,
      trailer: json['trailer'] as String,
      genres: (json['genres'] as List<dynamic>)
          .map((e) => GenreItem.fromJson(e as Map<String, dynamic>))
          .toList(),
      releaseDate: json['release_date'] as String,
      spokenLanguages: (json['spoken_languages'] as List<dynamic>)
          .map((e) => SpokenLanguageItem.fromJson(e as Map<String, dynamic>))
          .toList(),
      voteAverage: (json['vote_average'] as num).toDouble(),
    );

Map<String, dynamic> _$MovieRecommendationToJson(
        MovieRecommendation instance) =>
    <String, dynamic>{
      'title': instance.title,
      'overview': instance.overview,
      'poster_url': instance.posterUrl,
      'imdb_link': instance.imdbLink,
      'trailer': instance.trailer,
      'genres': instance.genres,
      'release_date': instance.releaseDate,
      'spoken_languages': instance.spokenLanguages,
      'vote_average': instance.voteAverage,
    };

GenreItem _$GenreItemFromJson(Map<String, dynamic> json) => GenreItem(
      id: (json['id'] as num).toInt(),
      name: json['name'] as String,
    );

Map<String, dynamic> _$GenreItemToJson(GenreItem instance) => <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
    };

SpokenLanguageItem _$SpokenLanguageItemFromJson(Map<String, dynamic> json) =>
    SpokenLanguageItem(
      englishName: json['english_name'] as String,
      iso6391: json['iso_639_1'] as String,
      name: json['name'] as String,
    );

Map<String, dynamic> _$SpokenLanguageItemToJson(SpokenLanguageItem instance) =>
    <String, dynamic>{
      'english_name': instance.englishName,
      'iso_639_1': instance.iso6391,
      'name': instance.name,
    };

SendNotificationResponse _$SendNotificationResponseFromJson(
        Map<String, dynamic> json) =>
    SendNotificationResponse(
      (json['notifications'] as List<dynamic>)
          .map((e) => NotificationResponse.fromJson(e as Map<String, dynamic>))
          .toList(),
    )
      ..statusCode = (json['status'] as num?)?.toInt()
      ..message = json['message'] as String?;

Map<String, dynamic> _$SendNotificationResponseToJson(
        SendNotificationResponse instance) =>
    <String, dynamic>{
      'status': instance.statusCode,
      'message': instance.message,
      'notifications': instance.notifications,
    };

NotificationResponse _$NotificationResponseFromJson(
        Map<String, dynamic> json) =>
    NotificationResponse(
      json['message'] as String,
      DateTime.parse(json['date'] as String),
      json['isRead'] as bool,
      json['_id'] as String,
    );

Map<String, dynamic> _$NotificationResponseToJson(
        NotificationResponse instance) =>
    <String, dynamic>{
      'message': instance.message,
      'date': instance.date.toIso8601String(),
      'isRead': instance.isRead,
      '_id': instance.id,
    };

UserProfileResponse _$UserProfileResponseFromJson(Map<String, dynamic> json) =>
    UserProfileResponse(
      user: UserProfileData.fromJson(json['user'] as Map<String, dynamic>),
      likes: (json['likes'] as List<dynamic>).map((e) => e as String).toList(),
      notifications: (json['notifications'] as List<dynamic>)
          .map((e) => NotificationResponse.fromJson(e as Map<String, dynamic>))
          .toList(),
      credits: (json['credits'] as num).toInt(),
      chatHistory: (json['chatHistory'] as List<dynamic>)
          .map((e) => ChatHistoryItem.fromJson(e as Map<String, dynamic>))
          .toList(),
    )
      ..statusCode = (json['status'] as num?)?.toInt()
      ..message = json['message'] as String?;

Map<String, dynamic> _$UserProfileResponseToJson(
        UserProfileResponse instance) =>
    <String, dynamic>{
      'status': instance.statusCode,
      'message': instance.message,
      'user': instance.user,
      'likes': instance.likes,
      'notifications': instance.notifications,
      'credits': instance.credits,
      'chatHistory': instance.chatHistory,
    };

UserProfileData _$UserProfileDataFromJson(Map<String, dynamic> json) =>
    UserProfileData(
      id: json['_id'] as String,
      isVerified: json['isVerified'] as bool,
      fullName: json['fullName'] as String,
      email: json['email'] as String,
      createdAt: json['createdAt'] as String,
      updatedAt: json['updatedAt'] as String,
      version: (json['__v'] as num).toInt(),
    );

Map<String, dynamic> _$UserProfileDataToJson(UserProfileData instance) =>
    <String, dynamic>{
      '_id': instance.id,
      'isVerified': instance.isVerified,
      'fullName': instance.fullName,
      'email': instance.email,
      'createdAt': instance.createdAt,
      'updatedAt': instance.updatedAt,
      '__v': instance.version,
    };

ChatHistoryItem _$ChatHistoryItemFromJson(Map<String, dynamic> json) =>
    ChatHistoryItem(
      role: json['role'] as String,
      message: json['message'],
      id: json['_id'] as String,
      timestamp: json['timestamp'] as String,
    );

Map<String, dynamic> _$ChatHistoryItemToJson(ChatHistoryItem instance) =>
    <String, dynamic>{
      'role': instance.role,
      'message': instance.message,
      '_id': instance.id,
      'timestamp': instance.timestamp,
    };
