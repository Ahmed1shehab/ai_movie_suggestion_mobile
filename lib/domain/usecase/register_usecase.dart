import 'package:ai_movie_suggestion/data/network/failure.dart';
import 'package:ai_movie_suggestion/data/network/requests.dart';
import 'package:ai_movie_suggestion/domain/model/models.dart';
import 'package:ai_movie_suggestion/domain/repository/repository.dart';
import 'package:ai_movie_suggestion/domain/usecase/base_usecase.dart';
import 'package:dartz/dartz.dart';

class RegisterUsecase
    implements BaseUseCase<RegisterUsecaseInput, RegisterModel> {
  final Repository _repository;

  RegisterUsecase(this._repository);
  @override
  Future<Either<Failure, RegisterModel>> execute(
      RegisterUsecaseInput input) async {
    return await _repository.register(RegisterRequest(
        input.fullName, input.email, input.password, input.confirmPassword));
  }
}

@override
class RegisterUsecaseInput {
  final String fullName;
  final String email;
  final String password;
  final String confirmPassword;

  RegisterUsecaseInput(
      this.fullName, this.email, this.password, this.confirmPassword);
}
