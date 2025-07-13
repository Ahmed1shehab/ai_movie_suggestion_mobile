import 'package:ai_movie_suggestion/data/network/failure.dart';
import 'package:ai_movie_suggestion/domain/model/models.dart';
import 'package:ai_movie_suggestion/domain/repository/repository.dart';
import 'package:ai_movie_suggestion/domain/usecase/base_usecase.dart';
import 'package:dartz/dartz.dart';

class SimilarMoviesUsecase
    implements BaseUseCase<SimilarMoviesUsecaseInput, List<MovieEntity>> {
  final Repository _repository;

  SimilarMoviesUsecase(this._repository);

  @override
  Future<Either<Failure, List<MovieEntity>>> execute(
      SimilarMoviesUsecaseInput input) async {
    return await _repository.similarMovies(
      input.movieId,
      page: input.page,
      language: input.language,
    );
  }
}

class SimilarMoviesUsecaseInput {
   final int movieId;
  final int? page;
  final String? language;

  SimilarMoviesUsecaseInput(
    this.movieId, {
    this.page,
    this.language,
  });
}
