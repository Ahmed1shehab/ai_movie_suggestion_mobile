import 'package:ai_movie_suggestion/data/network/failure.dart';
import 'package:ai_movie_suggestion/data/network/requests.dart';
import 'package:ai_movie_suggestion/domain/model/models.dart';
import 'package:ai_movie_suggestion/domain/repository/repository.dart';
import 'package:ai_movie_suggestion/domain/usecase/base_usecase.dart';
import 'package:dartz/dartz.dart';

class AddLikeUsecase implements BaseUseCase<AddLikeUsecaseInput, AddLikeModel> {
  final Repository _repository;

  AddLikeUsecase(this._repository);
  @override
  Future<Either<Failure, AddLikeModel>> execute(
      AddLikeUsecaseInput input) async {
    return await _repository.addLike(AddLikeRequest(input.movieId));
  }
}

@override
class AddLikeUsecaseInput {
  String movieId;
  AddLikeUsecaseInput(this.movieId);
}
