import 'package:ai_movie_suggestion/data/network/failure.dart';
import 'package:ai_movie_suggestion/domain/model/models.dart';
import 'package:ai_movie_suggestion/domain/repository/repository.dart';
import 'package:ai_movie_suggestion/domain/usecase/base_usecase.dart';
import 'package:dartz/dartz.dart';

class SearchMoviesUsecase
    implements BaseUseCase<SearchMoviesUsecaseInput, List<MovieEntity>> {
  final Repository _repository;

  SearchMoviesUsecase(this._repository);

  @override
  Future<Either<Failure, List<MovieEntity>>> execute(
      SearchMoviesUsecaseInput input) async {
    return await _repository.searchMovies(
      input.query,
      page: input.page,
      language: input.language,
    );
  }
}

class SearchMoviesUsecaseInput {
  final String query;
  final int? page;
  final String? language;

  SearchMoviesUsecaseInput(
    this.query, {
    this.page,
    this.language,
  });
}
