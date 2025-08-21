import 'package:ai_movie_suggestion/data/network/failure.dart';
import 'package:ai_movie_suggestion/domain/model/models.dart';
import 'package:ai_movie_suggestion/domain/repository/repository.dart';
import 'package:ai_movie_suggestion/domain/usecase/base_usecase.dart';
import 'package:dartz/dartz.dart';

class GetUserDataUsecase extends BaseUseCase<void, UserProfileModel> {
  final Repository _repository;

  GetUserDataUsecase(this._repository);

  @override
  Future<Either<Failure, UserProfileModel>> execute(void input) async {
    return await _repository.getUserData();
  }
}
