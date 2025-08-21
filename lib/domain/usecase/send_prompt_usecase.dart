import 'package:ai_movie_suggestion/data/network/failure.dart';
import 'package:ai_movie_suggestion/data/network/requests.dart';
import 'package:ai_movie_suggestion/domain/model/models.dart';
import 'package:ai_movie_suggestion/domain/repository/repository.dart';
import 'package:ai_movie_suggestion/domain/usecase/base_usecase.dart';
import 'package:dartz/dartz.dart';

class SendPromptUsecase
    implements BaseUseCase<SendPromptUsecaseInput, MovieDetail> {
  final Repository _repository;

  SendPromptUsecase(this._repository);
  @override
  Future<Either<Failure, MovieDetail>> execute(
      SendPromptUsecaseInput input) async {
    return await _repository.sendPrompt(SendPromptRequest(input.prompt));
  }
}

class SendPromptUsecaseInput {
  String prompt;
  SendPromptUsecaseInput(this.prompt);
}
