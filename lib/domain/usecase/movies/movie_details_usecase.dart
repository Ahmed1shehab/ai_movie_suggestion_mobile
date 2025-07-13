import 'package:ai_movie_suggestion/data/network/failure.dart';
import 'package:ai_movie_suggestion/domain/model/models.dart';
import 'package:ai_movie_suggestion/domain/repository/repository.dart';
import 'package:ai_movie_suggestion/domain/usecase/base_usecase.dart';
import 'package:ai_movie_suggestion/presentation/base/base_movie_viewmodel.dart';
import 'package:dartz/dartz.dart';

class MovieDetailsUseCase
    implements BaseUseCase<MovieDetailsUseCaseInput, List<MovieDetail>> {
  final Repository _repository;

  MovieDetailsUseCase(this._repository);

  @override
  Future<Either<Failure, List<MovieDetail>>> execute(
      MovieDetailsUseCaseInput input) async {
    return await _repository.movieDetails(
      input.movieId,
      language: input.language,
    );
  }
}

class MovieDetailsUseCaseInput extends BaseMovieUseCaseInput {
  final int movieId;

  MovieDetailsUseCaseInput(
    this.movieId, {
    super.language,
  });
}
