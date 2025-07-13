import 'package:ai_movie_suggestion/data/network/failure.dart';
import 'package:ai_movie_suggestion/data/network/requests.dart';
import 'package:ai_movie_suggestion/domain/model/models.dart';
import 'package:ai_movie_suggestion/domain/repository/repository.dart';
import 'package:ai_movie_suggestion/domain/usecase/base_usecase.dart';
import 'package:dartz/dartz.dart';

class VerifyEmailUsecase
    extends BaseUseCase<VerifyEmailUsecaseInput, VerifyEmailModel> {
  final Repository _repository;

  VerifyEmailUsecase(this._repository);
  @override
  Future<Either<Failure, VerifyEmailModel>> execute(
      VerifyEmailUsecaseInput input) async {
    return await _repository
        .verifyEmail(VerifyEmailRequest(input.email, input.code));
  }
}

class VerifyEmailUsecaseInput {
  final String email;
  final String code;
  VerifyEmailUsecaseInput(this.email, this.code);
}
