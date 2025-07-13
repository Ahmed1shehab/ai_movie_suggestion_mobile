import 'package:ai_movie_suggestion/data/network/failure.dart';
import 'package:ai_movie_suggestion/data/network/requests.dart';
import 'package:ai_movie_suggestion/domain/model/models.dart';
import 'package:ai_movie_suggestion/domain/repository/repository.dart';
import 'package:ai_movie_suggestion/domain/usecase/base_usecase.dart';
import 'package:dartz/dartz.dart';

class LoginUsecase implements BaseUseCase<LoginUsecaseInput, Auth> {
  final Repository _repository;

  LoginUsecase(this._repository);
  @override
  Future<Either<Failure, Auth>> execute(LoginUsecaseInput input) async {
    return await _repository.login(LoginRequest(input.email, input.password));
  }
}

@override
class LoginUsecaseInput {
  String email;
  String password;

  LoginUsecaseInput(this.email, this.password);
}
