import 'package:ai_movie_suggestion/data/network/failure.dart';
import 'package:ai_movie_suggestion/domain/model/models.dart';
import 'package:ai_movie_suggestion/domain/usecase/movies/get_top_rated_movies_usecase.dart';
import 'package:ai_movie_suggestion/presentation/base/base_movie_viewmodel.dart';
import 'package:dartz/dartz.dart';

class TopRatedViewModel extends BaseMovieViewModel {
  final GetTopRatedMoviesUseCase _getTopRatedMoviesUseCase;

  TopRatedViewModel(this._getTopRatedMoviesUseCase);

  @override
  Future<Either<Failure, List<MovieEntity>>> executeUseCase(
      BaseMovieUseCaseInput input) async {
    return await _getTopRatedMoviesUseCase
        .execute(input as GetTopRatedMoviesUseCaseInput);
  }

  @override
  BaseMovieUseCaseInput createUseCaseInput(int page) {
    return GetTopRatedMoviesUseCaseInput(page: page);
  }
}
