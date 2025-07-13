import 'package:ai_movie_suggestion/data/network/failure.dart';
import 'package:ai_movie_suggestion/domain/model/models.dart';
import 'package:ai_movie_suggestion/domain/repository/repository.dart';
import 'package:ai_movie_suggestion/domain/usecase/base_usecase.dart';
import 'package:dartz/dartz.dart';

class MovieRecommendationsUseCase
    implements BaseUseCase<MovieRecommendationsUseCaseInput, List<MovieEntity>> {
  final Repository _repository;

  MovieRecommendationsUseCase(this._repository);

  @override
  Future<Either<Failure, List<MovieEntity>>> execute(
      MovieRecommendationsUseCaseInput input) async {
    return await _repository.movieRecommendations(
      input.movieId,
      page: input.page,
      language: input.language,
    );
  }
}

class MovieRecommendationsUseCaseInput {
  final int movieId;
  final int? page;
  final String? language;

  MovieRecommendationsUseCaseInput(
    this.movieId, {
    this.page,
    this.language,
  });
}
