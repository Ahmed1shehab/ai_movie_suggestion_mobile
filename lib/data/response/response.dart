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
  RegisterResponse(); // Empty constructor is fine

  factory RegisterResponse.fromJson(Map<String, dynamic> json) =>
      _$RegisterResponseFromJson(json);

  Map<String, dynamic> toJson() => _$RegisterResponseToJson(this);
}

///////////////////////////////////////verify email response/////////////////////////////////////////
@JsonSerializable()
class VerifyEmailResponse extends BaseResponse {
  VerifyEmailResponse(); // Empty constructor is fine

  factory VerifyEmailResponse.fromJson(Map<String, dynamic> json) =>
      _$VerifyEmailResponseFromJson(json);

  Map<String, dynamic> toJson() => _$VerifyEmailResponseToJson(this);
}



