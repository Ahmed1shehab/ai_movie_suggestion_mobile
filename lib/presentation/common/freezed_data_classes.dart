import 'package:freezed_annotation/freezed_annotation.dart';
part 'freezed_data_classes.freezed.dart';

@freezed
class LoginObject with _$LoginObject {
  factory LoginObject(
    String email,
    String password,
  ) = _LoginObject;
}

@freezed
class RegisterObject with _$RegisterObject {
  factory RegisterObject(
    String fullName,
    String email,
    String password,
    String confirmPassword,
  ) = _RegisterObject;
}

@freezed
class VerifyEmailObject with _$VerifyEmailObject {
  factory VerifyEmailObject(String email, String code) = _VerifyEmailObject;
}
