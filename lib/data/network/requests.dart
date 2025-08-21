class LoginRequest {
  final String email;
  final String password;

  LoginRequest(this.email, this.password);

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'password': password,
    };
  }
}

class RegisterRequest {
  final String fullName;
  final String email;
  final String password;
  final String confirmPassword;

  RegisterRequest(
      this.fullName, this.email, this.password, this.confirmPassword);

  Map<String, dynamic> toJson() {
    return {
      'fullName': fullName,
      'email': email,
      'password': password,
      'confirmPassword': confirmPassword,
    };
  }
}

class VerifyEmailRequest {
  final String email;
  final String code;

  VerifyEmailRequest(this.email, this.code);
  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'code': code,
    };
  }
}

class AddLikeRequest {
  final String movieId;
  AddLikeRequest(this.movieId);
}

class SendNotificationsRequest {
  String message;
  String date;

  SendNotificationsRequest(this.message, DateTime dateTime)
      : date = dateTime.toIso8601String();

  Map<String, dynamic> toJson() => {
        'message': message,
        'date': date,
      };
}

class SendPromptRequest {
  String prompt;
  SendPromptRequest(this.prompt);
  Map<String, dynamic> toJson() => {
        'prompt': prompt,
      };
}
